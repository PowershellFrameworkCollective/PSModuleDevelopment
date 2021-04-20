function Set-PSMDBuildStep {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[int]
		$Weight,
		
		[PsfArgumentCompleter('PSModuleDevelopment.Build.Action')]
		[string]
		$Action,
		
		[hashtable]
		$Parameters,
		
		[string]
		$Condition,
		
		[string]
		$ConditionSet,
		
		[string[]]
		$Dependency,
		
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
		$stepObject = $projectObject.Steps | Where-Object Name -EQ $Name
		if (-not $stepObject) {
			$stepObject = [pscustomobject]@{
				PSTypeName = 'PSModuleDevelopment.Build.Step'
				Name	   = $Name
				Weight	   = 50
				Action	   = ''
				Parameters = @{ }
				Condition  = ''
				ConditionSet = 'PSFramework Environment'
				Dependency = @()
			}
		}
		if (Test-PSFParameterBinding -ParameterName Weight) { $stepObject.Weight = $Weight }
		if (Test-PSFParameterBinding -ParameterName Action) { $stepObject.Action = $Action }
		if (Test-PSFParameterBinding -ParameterName Parameters) { $stepObject.Parameters = $Parameters }
		if (Test-PSFParameterBinding -ParameterName Condition) { $stepObject.Condition = $Condition }
		if (Test-PSFParameterBinding -ParameterName ConditionSet) { $stepObject.ConditionSet = $ConditionSet }
		if (Test-PSFParameterBinding -ParameterName Dependency) { $stepObject.Dependency = $Dependency }
		
		if (-not $stepObject.Action) {
			throw "Failed to save Build Step $Name : No Action defined!"
		}
		$projectObject.Steps = @($projectObject.Steps | Where-Object Name -ne $Name) + @($stepObject) | Sort-Object -Property Name
		$projectObject | ConvertTo-Json -Depth 10 | Set-Content -Path $projectPath -Encoding UTF8
	}
}