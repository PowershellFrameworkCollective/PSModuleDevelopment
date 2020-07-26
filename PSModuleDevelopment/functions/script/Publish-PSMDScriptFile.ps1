function Publish-PSMDScriptFile
{
<#
	.SYNOPSIS
		Packages a script with all dependencies and "publishes" it as a zip package.
	
	.DESCRIPTION
		Packages a script with all dependencies and "publishes" it as a zip package.
		By default, it will be published to the user's desktop.
		All modules it uses will be parsed from the script:
		- Commands that cannot be resolved will trigger a warning.
		- Modules that are installed in the Windows folder (such as the ActiveDirectory module or other modules associated with server roles) will be ignored.
		- PSSnapins will be ignored
		- All other modules determined by the commands used will be provided from a repository, packaged in a subfolder and included in the zip file.
	
		If needed, the scriptfile will be modified to add the new modules folder to its list of known folders.
		(The source file itself will never be modified)
	
		Use Set-PSMDStagingRepository to create / use a local path for staging modules to provide that way.
		This gives you better control over the versions used and better performance.
		Also the ability to use this with non-public modules.
		Use Publish-PSMDStagedModule to transfer modules from path or another repository into your registered staging repository.
	
	.PARAMETER Path
		Path to the scriptfile to publish.
		The scriptfile is expected to be UTF8 encoded with BOM, otherwise some characters may end up broken.
	
	.PARAMETER OutPath
		The path to the folder where the output zip file will be created.
		Defaults to the user's desktop.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Publish-PSMDScriptFile -Path 'C:\scripts\logrotate.ps1'
	
		Creates a delivery package for the logrotate.ps1 scriptfile and places it on the desktop
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PsfValidateScript('PSModuleDevelopment.Validate.File', ErrorString = 'PSModuleDevelopment.Validate.File')]
		[string]
		$Path,
		
		[PsfValidateScript('PSModuleDevelopment.Validate.Path', ErrorString = 'PSModuleDevelopment.Validate.Path')]
		[string]
		$OutPath = (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Script.OutPath'),
		
		[switch]
		$EnableException
	)
	
	begin
	{
		#region Utility Functions
		function Get-Modifier
		{
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				[string]
				$Path
			)
			
			$help = Get-Help $Path
			$modifiers = $help.alertSet.alert.Text -split "`n" | Where-Object { $_ -like "PSMD: *" } | ForEach-Object { $_ -replace '^PSMD: ' }
			
			foreach ($modifier in $modifiers)
			{
				$operation, $values = $modifier -split ":"
				switch ($operation)
				{
					'Include'
					{
						foreach ($module in $values.Split(",").ForEach{ $_.Trim() })
						{
							[pscustomobject]@{
								Type = 'Include'
								Name = $module
							}
						}
					}
					'Exclude'
					{
						foreach ($module in $values.Split(",").ForEach{ $_.Trim() })
						{
							[pscustomobject]@{
								Type = 'Exclude'
								Name = $module
							}
						}
					}
					'IgnoreUnknownCommand'
					{
						foreach ($commandName in $values.Split(",").ForEach{ $_.Trim() })
						{
							[pscustomobject]@{
								Type = 'IgnoreCommand'
								Name = $commandName
							}
						}
					}
				}
			}
		}
		
		function Add-PSModulePath
		{
			[CmdletBinding()]
			param (
				[string]
				$Path
			)
			
			$psmodulePathCode = @'

# Ensure modules are available
$modulePath = "$PSScriptRoot\Modules"
if (-not $env:PSModulePath.Contains($modulePath)) { $env:PSModulePath = "$($env:PSModulePath);$($modulePath)" }


'@
			
			$parsedFile = Read-PSMDScript -Path $Path
			$assignment = $parsedFile.Ast.FindAll({
					$args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] -and
					$args[0].Left.VariablePath.UserPath -eq 'env:PSModulePath'
				}, $true)
			if ($assignment) { return }
			if ($parsedFile.Ast.ParamBlock.Extent)
			{
				$paramExtent = $parsedFile.Ast.ParamBlock.Extent
				$text = [System.IO.File]::ReadAllText($Path)
				$newText = $text.Substring(0, $paramExtent.EndOffset) + $psmodulePathCode + $text.Substring($paramExtent.EndOffset)
				$encoding = [System.Text.UTF8Encoding]::new($true)
				[System.IO.File]::WriteAllText($Path, $newText, $encoding)
			}
			else
			{
				$extent = $parsedFile.Ast.EndBlock.Statements[0].Extent
				$text = [System.IO.File]::ReadAllText($Path)
				$textBefore = ""
				$textAfter = $text
				if ($extent.StartOffset -gt 0)
				{
					$textBefore = $text.Substring(0, $extent.StartOffset)
					$textAfter = $text.Substring($extent.StartOffset)
				}
				$newText = $textBefore + $psmodulePathCode + $textAfter
				$encoding = [System.Text.UTF8Encoding]::new($true)
				[System.IO.File]::WriteAllText($Path, $newText, $encoding)
			}
		}
		#endregion Utility Functions
		
		$modulesToProcess = @{
			IgnoreCommand = @()
			Include = @()
			Exclude = @()
		}
	}
	process
	{
		#region Prepare required Modules
		# Scan help-notes for explicit directives
		$modifiers = Get-Modifier -Path $Path
		foreach ($modifier in $modifiers)
		{
			$modulesToProcess.$($modifier.Type) += $modifier.Name
		}
		
		# Detect modules needed and store them
		try { $parsedCommands = Get-PSMDFileCommand -Path $Path -EnableException }
		catch
		{
			Stop-PSFFunction -String 'Publish-PSMDScriptFile.Script.ParseError' -StringValues $Path -EnableException $EnableException -ErrorRecord $_
			return
		}
		foreach ($command in $parsedCommands)
		{
			Write-PSFMessage -Level Verbose -String 'Publish-PSMDScriptFile.Script.Command' -StringValues $command.Name, $command.Count, $command.Module
			if ($modulesToProcess.IgnoreCommand -contains $command.Name) { continue }
			
			if (-not $command.Module -and -not $command.Internal)
			{
				Write-PSFMessage -Level Warning -String 'Publish-PSMDScriptFile.Script.Command.NotKnown' -StringValues $command.Name, $command.Count
				continue
			}
			if ($modulesToProcess.Exclude -contains "$($command.Module)") { continue }
			if ($modulesToProcess.Include -contains "$($command.Module)") { continue }
			if ($command.Module -is [System.Management.Automation.PSSnapInInfo]) { continue }
			if ($command.Module.ModuleBase -eq 'C:\Windows\System32\WindowsPowerShell\v1.0') { continue }
			if ($command.Module.ModuleBase -eq 'C:\Program Files\PowerShell\7'){ continue }
			$modulesToProcess.Include += "$($command.Module)"
		}
		
		$tempPath = Get-PSFPath -Name Temp
		$newPath = New-Item -Path $tempPath -Name "PSMD_$(Get-Random)" -ItemType Directory -Force
		$modulesFolder = New-Item -Path $newPath.FullName -Name 'Modules' -ItemType Directory -Force
		
		foreach ($moduleLabel in $modulesToProcess.Include | Select-Object -Unique)
		{
			if (-not $moduleLabel) { continue }
			Invoke-PSFProtectedCommand -ActionString 'Publish-PSMDScriptFile.Module.Saving' -ActionStringValues $moduleLabel, (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Script.StagingRepository') -Scriptblock {
				Save-Module -Name $moduleLabel -Repository (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Script.StagingRepository') -Path $modulesFolder.FullName -ErrorAction Stop
			} -EnableException $EnableException -PSCmdlet $PSCmdlet -Target $moduleLabel
			if (Test-PSFFunctionInterrupt) { return }
		}
		#endregion Prepare required Modules
		
		# Copy script file
		$newScript = Copy-Item -Path $Path -Destination $newPath.FullName -PassThru
		
		# Update script to set PSModulePath
		Add-PSModulePath -Path $newScript.FullName
		
		# Zip result & move to destination
		Compress-Archive -Path "$($newPath.FullName)\*" -DestinationPath ('{0}\{1}.zip' -f $OutPath, $newScript.BaseName) -Force
		Remove-Item -Path $newPath.FullName -Recurse -Force -ErrorAction Ignore
	}
}