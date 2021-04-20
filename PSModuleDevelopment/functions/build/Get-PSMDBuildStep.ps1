function Get-PSMDBuildStep {
<#
	.SYNOPSIS
		Read the steps that are part of the specified build project.
	
	.DESCRIPTION
		Read the steps that are part of the specified build project.
	
	.PARAMETER Name
		The name by which to filter the steps returned.
		Defaults to '*'
	
	.PARAMETER BuildProject
		Path to the build project file to read from.
		Defaults to the currently selected project if available.
		Use Select-PSMDBuildProject to select a default project.
	
	.EXAMPLE
		PS C:\> Get-PSMDBuildStep
	
		Read all steps that are part of the default build project.
	
	.EXAMPLE
		PS C:\> Get-PSMDBuildStep -Name CreateSession -BuildProject C:\code\Project\Project.build.json
	
		Return the CreateSession step from the specified project file.
#>
	[CmdletBinding()]
	param (
		[string]
		$Name = '*',
		
		[string]
		$BuildProject
	)
	
	begin {
		$projectPath = $BuildProject
		if (-not $projectPath) { $projectPath = Get-PSFConfigValue -FullName 'PSModuleDevelopment.Build.Project.Selected' }
		if (-not $projectPath) { throw "No Project path specified and none selected!" }
		if (-not (Test-Path -Path $projectPath)) {
			throw "Project file not found: $projectPath"
		}
	}
	process {
		$projectObject = Get-PSMDBuildProject -Path $projectPath
		$projectObject.Steps | Where-Object Name -Like $Name
	}
}
