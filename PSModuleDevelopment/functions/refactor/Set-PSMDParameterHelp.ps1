function Set-PSMDParameterHelp
{
	<#
		.SYNOPSIS
			Sets the content of a CBH parameter help.
		
		.DESCRIPTION
			Sets the content of a CBH parameter help.
			This command will enumerate all files in the specified folder and subfolders.
			Then scan all files with extension .ps1 and .psm1.
			In each of these files it will check out function definitions, see whether the name matches, then update the help for the specified parameter if present.
	
			In order for this to work, a few rules must be respected:
			- It will not work with help XML, only with CBH xml
			- It will not work if the help block is above the function. It must be placed within.
			- It will not ADD a CBH, if none is present yet. If there is no help for the specified parameter, it will simply do nothing, but report the fact.
		
		.PARAMETER Path
			The base path where all the files are in.
		
		.PARAMETER CommandName
			The name of the command to update.
			Uses wildcard matching to match, so you can do a global update using "*"
		
		.PARAMETER ParameterName
			The name of the parameter to update.
			Must be an exact match, but is not case sensitive.
		
		.PARAMETER HelpText
			The text to insert.
			- Do not include indents. It will pick up the previous indents and reuse them
			- Do not include an extra line, it will automatically add a separating line to the next element
		
		.PARAMETER DisableCache
			By default, this command caches the results of its execution in the PSFramework result cache.
			This information can then be retrieved for the last command to do so by running Get-PSFResultCache.
			Setting this switch disables the caching of data in the cache.
		
		.EXAMPLE
			Set-PSMDParameterHelp -Path "C:\PowerShell\Projects\MyModule" -CommandName "*" -ParameterName "Foo" -HelpText @"
			This is some foo text
			For a truly foo-some result
			"@
	
			Scans all files in the specified path.
			- Considers every function found
			- Will only process the parameter 'Foo'
			- And replace the current text with the one specified
	#>

	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$Path,
		
		[Parameter(Mandatory = $true)]
		[string]
		$CommandName,
		
		[Parameter(Mandatory = $true)]
		[string]
		$ParameterName,
		
		[Parameter(Mandatory = $true)]
		[string]
		$HelpText,
		
		[switch]
		$DisableCache
	)
	
	# Global Store for pending file updates
	# Exempt from Scope Boundary violation rule, since only accessed using dedicated helper function
	$globalFunctionHash = @{ }
	
	#region Utility Functions
	function Invoke-AstWalk
	{
		[CmdletBinding()]
		Param (
			$Ast,
			
			[string]
			$CommandName,
			
			[string]
			$ParameterName,
			
			[string]
			$HelpText
		)
		
		#Write-PSFMessage -Level Host -Message "Processing $($Ast.Extent.StartLineNumber) | $($Ast.Extent.File) | $($Ast.GetType().FullName)"
		$typeName = $Ast.GetType().FullName
		
		switch ($typeName)
		{
			"System.Management.Automation.Language.FunctionDefinitionAst"
			{
				if ($Ast.Name -like $CommandName)
				{
					Update-CommandParameterHelp -FunctionAst $Ast -ParameterName $ParameterName -HelpText $HelpText
					
					if ($Ast.Body.DynamicParamBlock) { Invoke-AstWalk -Ast $Ast.Body.DynamicParamBlock -CommandName $CommandName -ParameterName $ParameterName -HelpText $HelpText }
					if ($Ast.Body.BeginBlock) { Invoke-AstWalk -Ast $Ast.Body.BeginBlock -CommandName $CommandName -ParameterName $ParameterName -HelpText $HelpText }
					if ($Ast.Body.ProcessBlock) { Invoke-AstWalk -Ast $Ast.Body.ProcessBlock -CommandName $CommandName -ParameterName $ParameterName -HelpText $HelpText }
					if ($Ast.Body.EndBlock) { Invoke-AstWalk -Ast $Ast.Body.EndBlock -CommandName $CommandName -ParameterName $ParameterName -HelpText $HelpText }
				}
				else
				{
					Invoke-AstWalk -Ast $Ast.Body -CommandName $CommandName -ParameterName $ParameterName -HelpText $HelpText
				}
			}
			default
			{
				foreach ($property in $Ast.PSObject.Properties)
				{
					if ($property.Name -eq "Parent") { continue }
					if ($null -eq $property.Value) { continue }
					
					if (Get-Member -InputObject $property.Value -Name GetEnumerator -MemberType Method)
					{
						foreach ($item in $property.Value)
						{
							if ($item.PSObject.TypeNames -contains "System.Management.Automation.Language.Ast")
							{
								Invoke-AstWalk -Ast $item -CommandName $CommandName -ParameterName $ParameterName -HelpText $HelpText
							}
						}
						continue
					}
					
					if ($property.Value.PSObject.TypeNames -contains "System.Management.Automation.Language.Ast")
					{
						Invoke-AstWalk -Ast $property.Value -CommandName $CommandName -ParameterName $ParameterName -HelpText $HelpText
					}
				}
			}
		}
	}
	
	function Update-CommandParameterHelp
	{
		[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
		[CmdletBinding()]
		Param (
			[System.Management.Automation.Language.FunctionDefinitionAst]
			$FunctionAst,
			
			[string]
			$ParameterName,
			
			[string]
			$HelpText
		)
		
		#region Find the starting position
		function Get-StartIndex
		{
			[OutputType([System.Int32])]
			[CmdletBinding()]
			Param (
				[System.Management.Automation.Language.FunctionDefinitionAst]
				$FunctionAst,
				
				[string]
				$ParameterName,
				
				[int]
				$HelpEnd
			)
			
			if ($HelpEnd -lt 1) { return -1 }
			
			$index = -1
			$offset = 0
			
			while ($FunctionAst.Extent.Text.SubString(0, $HelpEnd).IndexOf(".PARAMETER $ParameterName", $offset, [System.StringComparison]::InvariantCultureIgnoreCase) -ne -1)
			{
				$tempIndex = $FunctionAst.Extent.Text.SubString(0, $HelpEnd).IndexOf(".PARAMETER $ParameterName", $offset, [System.StringComparison]::InvariantCultureIgnoreCase)
				$endOfLineIndex = $FunctionAst.Extent.Text.SubString(0, $HelpEnd).IndexOf("`n", $tempIndex, [System.StringComparison]::InvariantCultureIgnoreCase)
				if ($FunctionAst.Extent.Text.SubString($tempIndex, ($endOfLineIndex - $tempIndex)).Trim() -eq ".PARAMETER $ParameterName")
				{
					return $tempIndex
				}
				$offset = $endOfLineIndex
			}
			
			return $index
		}
		
		$startIndex = $FunctionAst.Extent.StartOffset
		$endIndex = $FunctionAst.Body.ParamBlock.Extent.StartOffset
		foreach ($attribute in $FunctionAst.Body.ParamBlock.Attributes)
		{
			if ($attribute.Extent.StartOffset -lt $endIndex) { $endIndex = $attribute.Extent.StartOffset }
		}
		
		$index1 = Get-StartIndex -FunctionAst $FunctionAst -ParameterName $ParameterName -HelpEnd ($endIndex - $startIndex)
		if ($index1 -eq -1)
		{
			Write-PSFMessage -Level Warning -Message "Could not find Comment Based Help for parameter '$ParameterName' of command '$($FunctionAst.Name)' in '$($FunctionAst.Extent.File)'" -Tag 'cbh', 'fail' -FunctionName Rename-PSMDParameter
			Write-Issue -Extent $FunctionAst.Extent -Type "ParameterCBHNotFound" -Data "Parameter Help not found"
			return
		}
		$index2 = $FunctionAst.Extent.Text.SubString(0, ($endIndex - $startIndex)).IndexOf("$ParameterName", $index1, [System.StringComparison]::InvariantCultureIgnoreCase) + $ParameterName.Length
		$goodIndex = $FunctionAst.Extent.Text.SubString($index2).IndexOf("`n") + 1 + $index2
		#endregion Find the starting position
		
		#region Find the ending position
		$lines = $FunctionAst.Extent.Text.SubString(0, ($endIndex - $startIndex)).Substring($goodIndex).Split("`n")
		
		$goodLines = @()
		$badLine = ""
		
		foreach ($line in $lines)
		{
			if ($line -notmatch "^#{0,1}[\s`t]{0,}\.|^#>") { $goodLines += $line }
			else
			{
				$badLine = $line
				break
			}
		}
		
		if (($goodLines.Count -eq 0) -or ($goodLines.Count -eq $lines.Count))
		{
			Write-PSFMessage -Level Warning -Message "Could not parse the Comment Based Help for parameter '$ParameterName' of command '$($FunctionAst.Name)' in '$($FunctionAst.Extent.File)'" -Tag 'cbh', 'fail' -FunctionName Rename-PSMDParameter
			Write-Issue -Extent $FunctionAst.Extent -Type "ParameterCBHBroken" -Data "Parameter Help cannot be parsed"
			return
		}
		
		$badIndex = $FunctionAst.Extent.Text.SubString(0, ($endIndex - $startIndex)).IndexOf($badLine, $index2) - 1
		#endregion Find the ending position
		
		#region Find the indent and create the text to insert
		$indents = @()
		foreach ($line in $goodLines)
		{
			if ($line.Trim(" ^t#$([char]13)").Length -gt 0)
			{
				$line | Select-String "^(#{0,1}[\s`t]+)" | ForEach-Object { $indents += $_.Matches[0].Groups[1].Value }
			}
		}
		if ($indents.Count -eq 0) { $indent = "`t`t" }
		else
		{
			$indent = $indents | Sort-Object -Property Length | Select-Object -First 1
		}
		$indent = $indent.Replace([char]13, [char]9)
		
		$newHelpText = ($HelpText.Split("`n") | ForEach-Object { "$($indent)$($_)" }) -join "`n"
		$newHelpText += "`n$($indent)"
		#endregion Find the indent and create the text to insert
		
		Add-FileReplacement -Path $FunctionAst.Extent.File -Start ($goodIndex + $startIndex) -Length ($badIndex - $goodIndex) -NewContent $newHelpText
	}
	
	function Add-FileReplacement
	{
		[CmdletBinding()]
		Param (
			[string]
			$Path,
			
			[int]
			$Start,
			
			[int]
			$Length,
			
			[string]
			$NewContent
		)
		Write-PSFMessage -Level Verbose -Message "Change Submitted: $Path | $Start | $Length | $NewContent" -Tag 'update', 'change', 'file'
		
		if (-not $globalFunctionHash.ContainsKey($Path))
		{
			$globalFunctionHash[$Path] = @()
		}
		
		$globalFunctionHash[$Path] += New-Object PSObject -Property @{
			Content    = $NewContent
			Start	   = $Start
			Length	   = $Length
		}
	}
	
	function Apply-FileReplacement
	{
		[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
		[CmdletBinding()]
		Param (
			
		)
		
		foreach ($key in $globalFunctionHash.Keys)
		{
			$value = $globalFunctionHash[$key] | Sort-Object Start
			$content = [System.IO.File]::ReadAllText($key)
			
			$newString = ""
			$currentIndex = 0
			
			foreach ($item in $value)
			{
				$newString += $content.SubString($currentIndex, ($item.Start - $currentIndex))
				$newString += $item.Content
				$currentIndex = $item.Start + $item.Length
			}
			
			$newString += $content.SubString($currentIndex)
			
			[System.IO.File]::WriteAllText($key, $newString)
			#$newString
		}
	}
	
	function Write-Issue
	{
		[CmdletBinding()]
		Param (
			$Extent,
			
			$Data,
			
			[string]
			$Type
		)
		
		New-Object PSObject -Property @{
			Type    = $Type
			Data    = $Data
			File    = $Extent.File
			StartLine = $Extent.StartLineNumber
			Text    = $Extent.Text
		}
	}
	#endregion Utility Functions
	
	$files = Get-ChildItem -Path $Path -Recurse | Where-Object Extension -Match "\.ps1|\.psm1"
	
	$issues = @()
	
	foreach ($file in $files)
	{
		$tokens = $null
		$parsingError = $null
		$ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parsingError)
		
		Write-PSFMessage -Level VeryVerbose -Message "Updating help for <c='sub'>$CommandName / $ParameterName</c> | Scanning $($file.FullName)" -Tag 'start' -Target $Name
		$issues += Invoke-AstWalk -Ast $ast -CommandName $CommandName -ParameterName $ParameterName -HelpText $HelpText
	}
	
	Set-PSFResultCache -InputObject $issues -DisableCache $DisableCache
	Apply-FileReplacement
	$issues
}