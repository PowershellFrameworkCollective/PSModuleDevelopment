function Invoke-PSMDBuildProject {
<#
	.SYNOPSIS
		Execute a build project.
	
	.DESCRIPTION
		Execute a build project.
		A build project is a configured chain of actions that have been configured in json.
		They will be processed in their specified order and allow manageable, configurable steps without having to reinvent the same action again and again.
		
		+ Individual action types become available using Register-PSMDBuildAction.
		+ Create new build projects using New-PSMDBuildProject
		+ Set up steps taken during a build using Set-PSMDBuildStep
		+ Select the default build project using Select-PSMDBuildProject
	
	.PARAMETER Path
		The path to the build project file to execute.
		Mandatory if no build project has been selected as the default project.
		Use the Select-PSMDBuildProject to define a default project (and optionally persist the choice across sessions)
	
	.PARAMETER RetainArtifacts
		Whether, after executing the project, its artifacts should be retained.
		By default, any artifacts created during a build project will be discarded upon project completion.
	
		Artifacts are similar to variables to the pipeline and can be used to pass data throughout the pipeline.
		
		+ Use Publish-PSMDBuildArtifact to create a new artifact.
		+ Use Get-PSMDBuildArtifact to access existing build artifacts.
	
	.EXAMPLE
		PS C:\> Invoke-PSMDBuildProject -Path .\VMDeployment.build.Json
	
		Execute the build file "VMDeployment.build.json" from the current folder
	
	.EXAMPLE
		PS C:\> build
	
		Execute the default build project.
#>
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
				Parameters = $step.Parameters | ConvertTo-PSFHashtable
				ProjectName = $projectObject.Name
				StepName = $step.Name
				ParametersFromArtifacts = $step.ParametersFromArtifacts | ConvertTo-PSFHashtable
			}
			if (-not $parameters.Parameters) { $parameters.Parameters = @{ } }
			if (-not $parameters.ParametersFromArtifacts) { $parameters.ParametersFromArtifacts = @{ } }
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
