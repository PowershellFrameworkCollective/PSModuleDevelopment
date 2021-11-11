function Resolve-PSMDBuildStepParameter {
<#
	.SYNOPSIS
		Resolves and consolidates the overall parameters of a given step.
	
	.DESCRIPTION
		Resolves and consolidates the overall parameters of a given step.
		This ensures that individual actions do not have to implement manual resolution and complex conditionals.
		Sources of parameters:
		- Explicitly defined parameter in the step
		- Value from Artifacts
		- Value from Configuration (only if not otherwise sourced)
		- Value from implicit artifact resolution: Any value that is formatted like this:
		  "%!NameOfArtifact!%" will be replaced with the value of the artifact of the same name.
		  This supports wildcard resolution, so "%!Session.*!%" will resolve to all artifacts with a name starting with "Session."
	
	.PARAMETER Parameters
		The hashtable containing the currently specified parameters from the step configuration within the build project file.
		Only settings not already defined there are taken from configuration.
	
	.PARAMETER FromArtifacts
		The hashtable mapping parameters from artifacts.
		This allows dynamically assigning artifacts to parameters.
	
	.PARAMETER ProjectName
		The name of the project being executed.
		Supplementary parameters taken from configuration will pick up settings based on this name:
		"PSModuleDevelopment.BuildParam.<ProjectName>.<StepName>.*"
	
	.PARAMETER StepName
		The name of the step being executed.
		Supplementary parameters taken from configuration will pick up settings based on this name:
		"PSModuleDevelopment.BuildParam.<ProjectName>.<StepName>.*"
	
	.EXAMPLE
		PS C:\> Resolve-PSMDBuildStepParameter -Parameters $actualParameters -ProjectName VMDeployment -StepName 'Create Session'
		
		Adds parameters provided through configuration.
#>
	[OutputType([hashtable])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[hashtable]
		$Parameters,
		
		[Parameter(Mandatory = $true)]
		[hashtable]
		$FromArtifacts,
		
		[Parameter(Mandatory = $true)]
		[string]
		$ProjectName,
		
		[Parameter(Mandatory = $true)]
		[string]
		$StepName
	)
	
	process {
		# Process parameters from Configuration
		$configObject = Select-PSFConfig -FullName "PSModuleDevelopment.BuildParam.$ProjectName.$StepName.*"
		foreach ($property in $configObject.PSObject.Properties) {
			if ($property.Name -in '_Name', '_FullName', '_Depth', '_Children') { continue }
			if ($Parameters.ContainsKey($property.Name)) { continue }
			$Parameters[$property.Name] = $property.Value
		}
		
		# Process parameters from Artifacts
		foreach ($pair in $FromArtifacts.GetEnumerator()) {
			$Parameters[$pair.Key] = (Get-PSMDBuildArtifact -Name $pair.Value).Value
		}
		
		# Resolve implicit artifact references
		foreach ($key in $($Parameters.Keys)) {
			if ($Parameters.$key -notlike '%!*!%') { continue }
			
			$artifactName = $Parameters.$key -replace '^%!(.+?)!%$', '$1'
			$Parameters[$Key] = (Get-PSMDBuildArtifact -Name $artifactName).Value
		}
		
		$Parameters
	}
}