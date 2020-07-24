function Get-PSMDFileCommand
{
<#
	.SYNOPSIS
		Parses a scriptfile and returns the contained/used commands.
	
	.DESCRIPTION
		Parses a scriptfile and returns the contained/used commands.
		Use this to determine, what command resources are being used.
	
	.PARAMETER Path
		The path to the scriptfile to parse.
	
	.PARAMETER EnableException
        Replaces user friendly yellow warnings with bloody red exceptions of doom!
        Use this if you want the function to throw terminating errors you want to catch.
	
	.EXAMPLE
		PS C:\> Get-PSMDFileCommand -Path './task_usersync.ps1'
	
		Parses the scriptfile task_usersync.ps1 for commands used.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfValidateScript('PSModuleDevelopment.Validate.Path', ErrorString = 'PSModuleDevelopment.Validate.Path')]
		[string[]]
		$Path,
		
		[switch]
		$EnableException
	)
	
	process
	{
		foreach ($pathItem in $Path)
		{
			# Skip Folders
			if (-not (Test-Path -Path $pathItem -PathType Leaf)) { continue }
			
			$parsedCode = Read-PSMDScript -Path $pathItem
			if ($parsedCode.Errors)
			{
				Stop-PSFFunction -String 'Get-PSMDFileCommand.SyntaxError' -StringValues $pathItem -EnableException $EnableException -Continue
			}
			
			$results = @{ }
			$commands = $parsedCode.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true)
			$internalCommands = $parsedCode.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true).Name
			
			foreach ($command in $commands)
			{
				if (-not $results[$command.CommandElements[0].Value])
				{
					$commandInfo = Get-Command $command.CommandElements[0].Value -ErrorAction Ignore
					$module = $commandInfo.Module
					if (-not $module) { $module = $commandInfo.PSSnapin }
					$results[$command.CommandElements[0].Value] = [pscustomobject]@{
						PSTypeName = 'PSModuleDevelopment.File.Command'
						File	   = Get-Item $pathItem
						Name	   = $command.CommandElements[0].Value
						Parameters = @{ }
						Count	   = 0
						AstObjects = @()
						CommandInfo = $commandInfo
						Module	   = $module
						Internal   = $command.CommandElements[0].Value -in $internalCommands
						Path	   = $pathItem
					}
				}
				$object = $results[$command.CommandElements[0].Value]
				$object.Count = $object.Count + 1
				$object.AstObjects += $command
				foreach ($parameter in $command.CommandElements.Where{ $_ -is [System.Management.Automation.Language.CommandParameterAst] })
				{
					if (-not $object.Parameters[$parameter.ParameterName]) { $object.Parameters[$parameter.ParameterName] = 1 }
					else { $object.Parameters[$parameter.ParameterName] = $object.Parameters[$parameter.ParameterName] + 1 }
				}
			}
			
			$results.Values
		}
	}
}