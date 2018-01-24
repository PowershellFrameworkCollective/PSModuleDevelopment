function Set-PSMDCmdletBinding
{
	<#
		.SYNOPSIS
			Adds cmdletbinding attributes in bulk
		
		.DESCRIPTION
			Searches the specified file(s) for functions that ...
			- Do not have a cmdlet binding attribute
			- Do have a param block
			and inserts a cmdletbinding attribute for them.
	
			Will not change files where functions already have this attribute. Will also update internal functions.
		
		.PARAMETER FullName
			The file to process
		
		.PARAMETER DisableCache
			By default, this command caches the results of its execution in the PSFramework result cache.
			This information can then be retrieved for the last command to do so by running Get-PSFResultCache.
			Setting this switch disables the caching of data in the cache.
	
		.PARAMETER Confirm
			If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
		
		.PARAMETER WhatIf
			If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
		
		.EXAMPLE
			PS C:\> Get-ChildItem .\functions\*\*.ps1 | Set-PSMDCmdletBinding
	
			Updates all commands in the module to have a cmdletbinding attribute.
	#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$FullName,
		
		[switch]
		$DisableCache
	)
	
	begin
	{
		#region Utility functions
		function Invoke-AstWalk
		{
			[CmdletBinding()]
			Param (
				$Ast,
				
				[string[]]
				$Command,
				
				[string[]]
				$Name,
				
				[string]
				$NewName,
				
				[bool]
				$IsCommand,
				
				[bool]
				$NoAlias
			)
			
			#Write-PSFMessage -Level Host -Message "Processing $($Ast.Extent.StartLineNumber) | $($Ast.Extent.File) | $($Ast.GetType().FullName)"
			$typeName = $Ast.GetType().FullName
			
			switch ($typeName)
			{
				"System.Management.Automation.Language.FunctionDefinitionAst"
				{
					#region Has a param block, but no cmdletbinding
					if (($null -ne $Ast.Body.ParamBlock) -and (-not ($Ast.Body.ParamBlock.Attributes | Where-Object TypeName -Like "CmdletBinding")))
					{
						$text = [System.IO.File]::ReadAllText($Ast.Extent.File)
						
						$index = $Ast.Body.ParamBlock.Extent.StartOffset
						while (($index -gt 0) -and ($text.Substring($index, 1) -ne "`n")) { $index = $index - 1 }
						
						$indentIndex = $index + 1
						$indent = $text.Substring($indentIndex, ($Ast.Body.ParamBlock.Extent.StartOffset - $indentIndex))
						Add-FileReplacement -Path $Ast.Body.ParamBlock.Extent.File -Start $indentIndex -Length ($Ast.Body.ParamBlock.Extent.StartOffset - $indentIndex) -NewContent "$($indent)[CmdletBinding()]`n$($indent)"
					}
					#endregion Has a param block, but no cmdletbinding
					
					Invoke-AstWalk -Ast $Ast.Body -Command $Command -Name $Name -NewName $NewName -IsCommand $false
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
									Invoke-AstWalk -Ast $item -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand
								}
							}
							continue
						}
						
						if ($property.Value.PSObject.TypeNames -contains "System.Management.Automation.Language.Ast")
						{
							Invoke-AstWalk -Ast $property.Value -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand
						}
					}
				}
			}
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
				Content	    = $NewContent
				Start	    = $Start
				Length	    = $Length
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
				Type	 = $Type
				Data	 = $Data
				File	 = $Extent.File
				StartLine = $Extent.StartLineNumber
				Text	 = $Extent.Text
			}
		}
		#endregion Utility functions
	}
	process
	{
		foreach ($path in $FullName)
		{
			$globalFunctionHash = @{ }
			
			$tokens = $null
			$parsingError = $null
			$ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$parsingError)
			
			Write-PSFMessage -Level VeryVerbose -Message "Ensuring Cmdletbinding for all functions in $path" -Tag 'start' -Target $Name
			$issues += Invoke-AstWalk -Ast $ast -Command $Command -Name $Name -NewName $NewName -IsCommand $false
			
			Set-PSFResultCache -InputObject $issues -DisableCache $DisableCache
			if ($PSCmdlet.ShouldProcess($path, "Set CmdletBinding attribute"))
			{
				Apply-FileReplacement
			}
			$issues
		}
	}
}