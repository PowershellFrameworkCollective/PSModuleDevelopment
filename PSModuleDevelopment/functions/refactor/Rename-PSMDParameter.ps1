function Rename-PSMDParameter
{
	<#
		.SYNOPSIS
			Renames a parameter of a function.
		
		.DESCRIPTION
			This command is designed to rename the parameter of a function within an entire module.
			By default it will add an alias for the previous command name.
	
			In order for this to work you need to consider to have the command / module imported.
			Hint: Import the psm1 file for best results.
	
			It will then search all files in the specified path (hint: Specify module root for best results), and update all psm1/ps1 files.
			At the same time it will force all commands to call the parameter by its new standard, even if they previously used an alias for the parameter.
	
			While this command was designed to work with a module, it is not restricted to that:
			You can load a standalone function and specify a path with loose script files for the same effect.
	
			Note:
			You can also use this to update your scripts, after a foreign module introduced a breaking change by renaming a parameter.
			In this case, import the foreign module to see the function, but point it at the base path of your scripts to update.
			The loaded function is only used for alias/parameter alias resolution
		
		.PARAMETER Path
			The path to the root folder where all the files are stored.
			It will search the folder recursively and ignore hidden files & folders.
		
		.PARAMETER Command
			The name of the function, whose parameter should be changed.
			Most be loaded into the current runtime.
		
		.PARAMETER Name
			The name of the parameter to change.
		
		.PARAMETER NewName
			The new name for the parameter.
			Do not specify "-" or the "$" symbol
		
		.PARAMETER NoAlias
			Avoid creating an alias for the old parameter name.
			This may cause a breaking change!
		
		.PARAMETER EnableException
            Replaces user friendly yellow warnings with bloody red exceptions of doom!
            Use this if you want the function to throw terminating errors you want to catch.
		
		.EXAMPLE
			PS C:\> Rename-PSMDParameter -Path 'C:\Scripts\Modules\MyModule' -Command 'Get-Test' -Name 'Foo' -NewName 'Bar'
	
			Renames the parameter 'Foo' of the command 'Get-Test' to 'Bar' for all scripts stored in 'C:\Scripts\Modules\MyModule'
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$Path,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Command,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true)]
		[string]
		$NewName,
		
		[switch]
		$NoAlias,
		
		[switch]
		$EnableException
	)
	
	# Global Store for pending file updates
	# Exempt from Scope Boundary violation rule, since only accessed using dedicated helper function
	$globalFunctionHash = @{ }
	
	#region Helper Functions
	function Invoke-AstWalk
	{
		[CmdletBinding()]
		Param (
			$Ast,
			
			[string]
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
			"System.Management.Automation.Language.CommandAst"
			{
				Write-PSFMessage -Level Verbose -Message "Line $($Ast.Extent.StartLineNumber): Processing Command Ast: <c='em'>$($Ast.Extent.ToString())</c>"
				
				$commandName = $Ast.CommandElements[0].Value
				$resolvedCommand = $commandName
				
				if (Test-Path function:\$commandName)
				{
					$resolvedCommand = (Get-Item function:\$commandName).Name
				}
				if (Test-Path alias:\$commandName)
				{
					$resolvedCommand = (Get-Item function:\$commandName).ResolvedCommand.Name
				}
				
				if ($resolvedCommand -eq $Command)
				{
					$parameters = $Ast.CommandElements | Where-Object { $_.GetType().FullName -eq "System.Management.Automation.Language.CommandParameterAst" }
					
					foreach ($parameter in $parameters)
					{
						if ($parameter.ParameterName -in $Name)
						{
							Write-PSFMessage -Level SomewhatVerbose -Message "Found parameter: <c='em'>$($parameter.ParameterName)</c>"
							Update-CommandParameter -Ast $parameter -NewName $NewName
						}
					}
					
					$splatted = $Ast.CommandElements | Where-Object Splatted
					
					foreach ($splat in $splatted)
					{
						$assignments = $Ast.Parent.Parent.Statements | Where-Object { $_.GetType().FullName -eq "System.Management.Automation.Language.AssignmentStatementAst" }
						$assignments | Where-Object { ($_.Left.VariablePath.UserPath -eq $splat.VariablePath.UserPath) -and ($Ast.Parent.Parent.Statements.IndexOf($_) -lt $Ast.Parent.Parent.Statements.IndexOf($Ast.Parent)) } | ForEach-Object {
							
						}
					}
				}
				
				foreach ($element in $Ast.CommandElements)
				{
					if ($element.GetType().FullName -ne "System.Management.Automation.Language.CommandParameterAst")
					{
						Invoke-AstWalk -Ast $element -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand -NoAlias $NoAlias
					}
				}
			}
			"System.Management.Automation.Language.FunctionDefinitionAst"
			{
				if ($Ast.Name -eq $Command)
				{
					foreach ($parameter in $Ast.Body.ParamBlock.Parameters)
					{
						if ($Name[0] -ne $parameter.Name.VariablePath.UserPath) { continue }
						
						$stringExtent = $parameter.Extent.ToString()
						$lines = $stringExtent.Split("`n")
						$multiLine = $lines -gt 1
						$indent = 0
						$indentStyle = "`t"
						
						if ($multiLine)
						{
							if ($lines[1][0] -eq " ") { $indentStyle = " " }
							$indent = $lines[1].Length - $lines[1].Trim().Length
						}
						
						$aliases = @()
						foreach ($attribute in $parameter.Attributes)
						{
							if ($attribute.TypeName.FullName -eq "Alias") { $aliases += $attribute }
						}
						
						$aliasNames = $aliases.PositionalArguments.Value
						if ($aliasNames -contains $NewName) { $aliasNames = $aliasNames | Where-Object { $_ -ne $NewName } }
						if (-not $NoAlias) { $aliasNames += $Name }
						$aliasNames = $aliasNames | Select-Object -Unique | Sort-Object
						
						if ($aliasNames)
						{
							if ($aliases)
							{
								$newAlias = "[Alias($("'" + ($aliasNames -join "','")+ "'"))]"
								Add-FileReplacement -Path $aliases[0].Extent.File -Start $aliases[0].Extent.StartOffset -Length ($aliases[0].Extent.EndOffset - $aliases[0].Extent.StartOffset) -NewContent $newAlias
								Add-FileReplacement -Path $parameter.Name.Extent.File -Start $parameter.Name.Extent.StartOffset -Length ($parameter.Name.Extent.EndOffset - $parameter.Name.Extent.StartOffset) -NewContent "`$$NewName"
							}
							else
							{
								if ($multiLine)
								{
									$newAliasAndName = "[Alias($("'" + ($aliasNames -join "','") + "'"))]`n$($indentStyle * $indent)`$$NewName"
								}
								else
								{
									$newAliasAndName = "[Alias($("'" + ($aliasNames -join "','") + "'"))]`$$NewName"
								}
								Add-FileReplacement -Path $parameter.Name.Extent.File -Start $parameter.Name.Extent.StartOffset -Length ($parameter.Name.Extent.EndOffset - $parameter.Name.Extent.StartOffset) -NewContent $newAliasAndName
							}
						}
						else
						{
							Add-FileReplacement -Path $parameter.Name.Extent.File -Start $parameter.Name.Extent.StartOffset -Length ($parameter.Name.Extent.EndOffset - $parameter.Name.Extent.StartOffset) -NewContent "`$$NewName"
						}
					}
					
					if ($Ast.Body.DynamicParamBlock) { Invoke-AstWalk -Ast $Ast.Body.DynamicParamBlock -Command $Command -Name $Name -NewName $NewName -IsCommand $true -NoAlias $NoAlias }
					if ($Ast.Body.BeginBlock) { Invoke-AstWalk -Ast $Ast.Body.BeginBlock -Command $Command -Name $Name -NewName $NewName -IsCommand $true -NoAlias $NoAlias }
					if ($Ast.Body.ProcessBlock) { Invoke-AstWalk -Ast $Ast.Body.ProcessBlock -Command $Command -Name $Name -NewName $NewName -IsCommand $true -NoAlias $NoAlias }
					if ($Ast.Body.EndBlock) { Invoke-AstWalk -Ast $Ast.Body.EndBlock -Command $Command -Name $Name -NewName $NewName -IsCommand $true -NoAlias $NoAlias }
				}
				else
				{
					Invoke-AstWalk -Ast $Ast.Body -Command $Command -Name $Name -NewName $NewName -IsCommand $false -NoAlias $NoAlias
				}
			}
			"System.Management.Automation.Language.VariableExpressionAst"
			{
				if ($IsCommand -and ($Ast.VariablePath.UserPath -eq $Name))
				{
					Add-FileReplacement -Path $Ast.Extent.File -Start $Ast.Extent.StartOffset -Length ($Ast.Extent.EndOffset - $Ast.Extent.StartOffset) -NewContent "`$$NewName"
				}
				
			}
			default
			{
				foreach ($property in $Ast.PSObject.Properties)
				{
					if ($property.Name -eq "Parent") { continue }
					if ($property.Value -eq $null) { continue }
					
					if (Get-Member -InputObject $property.Value -Name GetEnumerator -MemberType Method)
					{
						foreach ($item in $property.Value)
						{
							if ($item.PSObject.TypeNames -contains "System.Management.Automation.Language.Ast")
							{
								Invoke-AstWalk -Ast $item -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand -NoAlias $NoAlias
							}
						}
						continue
					}
					
					if ($property.Value.PSObject.TypeNames -contains "System.Management.Automation.Language.Ast")
					{
						Invoke-AstWalk -Ast $property.Value -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand -NoAlias $NoAlias
					}
				}
			}
		}
	}
	
	function Update-CommandParameter
	{
		[CmdletBinding()]
		Param (
			[System.Management.Automation.Language.CommandParameterAst]
			$Ast,
			
			[string]
			$NewName
		)
		
		$name = $NewName
		if ($name -notlike "-*") { $name = "-$name" }
		
		Add-FileReplacement -Path $Ast.Extent.File -Start $Ast.Extent.StartOffset -Length ($Ast.Extent.EndOffset - $Ast.Extent.StartOffset) -NewContent $name
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
		Write-PSFMessage -Level Verbose -Message "Change Submitted: $Path | $Start | $Length | $NewContent" -Tag 'update','change','file'
		
		if (-not $globalFunctionHash.ContainsKey($Path))
		{
			$globalFunctionHash[$Path] = @()
		}
		
		$globalFunctionHash[$Path] += New-Object PSObject -Property @{
			Content  = $NewContent
			Start	  = $Start
			Length    = $Length
		}
	}
	
	function Apply-FileReplacement
	{
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
			
			#[System.IO.File]::WriteAllText($key, $newString)
			$newString
		}
	}
	#endregion Helper Functions
	
	try { $com = Get-Item function:\$Command -ErrorAction Stop }
	catch
	{
		Stop-PSFFunction -Message "Could not find command, please import the module using the psm1 file before starting a refactor" -EnableException $EnableException -Category ObjectNotFound -ErrorRecord $_ -OverrideExceptionMessage -Tag "fail", "input"
		return
	}
	$param = $com.Parameters.$Name
	if ($param -eq $null)
	{
		Stop-PSFFunction -Message "Parameter $param not found on command $Command" -EnableException $EnableException -Category ObjectNotFound -Tag "fail", "input"
		return
	}
	
	$names = @()
	$names += $param.Name
	foreach ($alias in $param.Attributes.AliasNames)
	{
		if ($alias.Length -gt 0) { $names += $alias }
	}
	
	$files = Get-ChildItem -Path $Path -Recurse | Where-Object Extension -Match "\.ps1|\.psm1"
	
	foreach ($file in $files)
	{
		$tokens = $null
		$parsingError = $null
		$ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parsingError)
		
		Write-PSFMessage -Level VeryVerbose -Message "Replacing <c='sub'>$Command / $Name</c> with <c='em'>$NewName</c> | Scanning $($file.FullName)" -Tag 'start' -Target $Name
		Invoke-AstWalk -Ast $ast -Command $Command -Name $Name -NewName $NewName -IsCommand $false -NoAlias $NoAlias
	}
	
	Apply-FileReplacement
}