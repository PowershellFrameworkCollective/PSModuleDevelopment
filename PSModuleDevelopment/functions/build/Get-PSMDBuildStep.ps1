function Get-PSMDBuildStep {
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
