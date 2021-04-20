function Invoke-PSMDBuildProject {
	[Alias('build')]
	[CmdletBinding()]
	param (
		[string]
		$Path,
		
		[switch]
		$RetainArtifacts
	)
	
	begin {
		$script:buildArtifacts = @{ }
		$buildStatus = @{ }
		
		$projectPath = $Path
		if (-not $projectPath) { $projectPath = Get-PSFConfigValue -FullName 'PSModuleDevelopment.Build.Project.Selected' }
		if (-not $projectPath) { throw "No Project path specified and none selected!" }
		if (-not (Test-Path -Path $projectPath)) {
			throw "Project file not found: $projectPath"
		}
		
		function Write-StepResult {
			[CmdletBinding()]
			param (
				[int]
				$Count,
				
				[ValidateSet('Success', 'Failed', 'ConditionNotMet', 'DependencyNotMet', 'BadAction')]
				[string]
				$Status,
				
				$StepObject,
				
				$Data,
				
				[hashtable]
				$BuildStatus,
				
				[string]
				$ContinueLabel
			)
			
			$BuildStatus[$StepObject.Name] = $Status -eq 'Success'
			
			$paramWritePSFMessage = @{
				Level	     = 'Warning'
				String	     = "Invoke-PSMDBuildProject.Step.$Status"
			}
			
			switch ($Status) {
				Failed { Write-PSFMessage @paramWritePSFMessage -StringValues $StepObject.Name, $StepObject.Action -ErrorRecord $Data }
				ConditionNotMet { Write-PSFMessage @paramWritePSFMessage -StringValues $StepObject.Name, $StepObject.Action, $StepObject.Condition }
				DependencyNotMet { Write-PSFMessage @paramWritePSFMessage -StringValues $StepObject.Name, $StepObject.Action, $Data }
				BadAction { Write-PSFMessage @paramWritePSFMessage -StringValues $StepObject.Name, $StepObject.Action }	
			}
			
			[PSCustomObject]@{
				PSTypeName = 'PSModuleDevelopment.Build.StepResult'
				Count	   = $Count
				Action	   = $StepObject.Action
				Status	   = $Status
				Step	   = $StepObject.Name
				Data	   = $Data
			}
			
			if ($ContinueLabel) {
				continue $ContinueLabel
			}
		}
	}
	process {
		$projectObject = Get-PSMDBuildProject -Path $projectPath
		$steps = $projectObject.Steps | Sort-Object Weight
		
		$count = 0
		$stepResults = :main foreach ($step in $steps) {
			$count++
			$resultDef = @{
				Count = $count
				StepObject = $step
				BuildStatus = $buildStatus
			}
			
			Write-PSFMessage -Level Host -String 'Invoke-PSMDBuildProject.Step.Executing' -StringValues $count, $step.Name, $step.Action
			
			#region Validation
			$actionObject = $script:buildActions[$step.Action]
			if (-not $actionObject) {
				Write-StepResult @resultDef -Status BadAction -ContinueLabel main
			}
			
			foreach ($dependency in $step.Dependency) {
				if (-not $buildStatus[$dependency]) {
					Write-StepResult @resultDef -Status DependencyNotMet -Data $dependency -ContinueLabel main
				}
			}
			
			if ($step.Condition -and $step.ConditionSet) {
				$cModule, $cSetName = $step.ConditionSet -split " ", 2
				$conditionSet = Get-PSFFilterConditionSet -Module $cModule -Name $cSetName
				if (-not $conditionSet) {
					Write-StepResult @resultDef -Status ConditionNotMet -ContinueLabel main
				}
				
				$filter = New-PSFFilter -Expression $step.Condition -ConditionSet $conditionSet
				if (-not $filter.Evaluate()) {
					Write-StepResult @resultDef -Status ConditionNotMet -ContinueLabel main
				}
			}
			#endregion Validation
			
			#region Execution
			$parameters = @{
				RootPath = Split-Path -Path $projectPath
				Parameters = $step.Parameters
			}
			try { $null = & $actionObject.Action $parameters }
			catch {
				Write-StepResult @resultDef -Status Failed -Data $_ -ContinueLabel main
			}
			Write-StepResult @resultDef -Status Success
			#endregion Execution
		}
		$stepResults
	}
	end {
		if (-not $RetainArtifacts) {
			$script:buildArtifacts = @{ }
		}
	}
}
