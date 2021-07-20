function Resolve-PSMDBuildStepParameter {
<#
	.SYNOPSIS
		Update missing build action parameters from the configuration system.
	
	.DESCRIPTION
		Update missing build action parameters from the configuration system.
		This command is for use within the defined code of build actions.
	
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
		
		$Parameters
	}
}