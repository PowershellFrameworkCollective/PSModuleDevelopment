@{
	TemplateName		 = 'AzureFunctionRest'
	Version			     = "1.0.0.0"
	AutoIncrementVersion = $true
	Tags				 = 'azure', 'function', 'rest'
	Author			     = 'Friedrich Weinmann'
	Description		     = 'HTTP Trigger endpoint for the basic Azure Function Template'
	Exclusions		     = @("PSMDInvoke.ps1", ".PSMDDependency") # Contains list of files - relative path to root - to ignore when building the template
	Scripts			     = @{ }
}