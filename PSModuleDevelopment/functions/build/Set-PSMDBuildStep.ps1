function Set-PSMDBuildStep {
<#
	.SYNOPSIS
		Create or update a step from a build project.
	
	.DESCRIPTION
		Create or update a step from a build project.
	
	.PARAMETER Name
		The name of the step.
		All step names must be unique within a single build project.
	
	.PARAMETER Weight
		The weight of the step.
		Weight determines processing order, the lower the number the earlier it is executed.
	
	.PARAMETER Action
		The name of the action to execute.
		Use Get-PSMDBuildAction to get a list of available actions.
	
	.PARAMETER Parameters
		The parameters this action should take.
		See the action object to see a description of parameters, including which must be provided and which can be skipped.
	
	.PARAMETER Condition
		A PSFramework filter condition that must apply for this action to be executed successfully.
		Example Conditions:
		  Elevated
		  PS7Plus -and OSWindows
		More Details: https://psframework.org/documentation/documents/psframework/filters.html
	
	.PARAMETER ConditionSet
		The name of the condition set to use.
		This is part of the PSFramework filter system:
		https://psframework.org/documentation/documents/psframework/filters.html
	
		Specify as "<module> <conditionsetname>" format.
		Default Value: PSFramework Environment
	
	.PARAMETER Dependency
		Any other steps that must successfully finished in order for this step to execute.
		ALL of the listed steps must have succeeded, skipped steps do not count.
	
	.PARAMETER BuildProject
		The build project file to work against.
		Specify the full path to the build project file.
		This parameter can be skipped if a default project file has been defined.
	
	.EXAMPLE
		PS C:\> Set-PSMDBuildStep -Name 'Create Session' -Action new-pssession -Parameters @{ VMName = 'labdc1'; CredentialPath = "%ProjectRoot%\creds\labdc1.cred";  }
	
		Defines a new step named 'Create Session' using the 'new-pssession'-action.
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
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
		$projectObject = Get-PSMDBuildProject -Path $projectPath | ConvertTo-PSFHashtable
		$stepObject = $projectObject.Steps | Where-Object Name -EQ $Name | ConvertTo-PSFHashtable
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
		$projectObject.Steps = @($projectObject.Steps | Where-Object Name -ne $Name) + @($stepObject)
		$projectObject | Export-PsmdBuildProjectFile -OutPath $projectPath -ErrorAction Stop
	}
}