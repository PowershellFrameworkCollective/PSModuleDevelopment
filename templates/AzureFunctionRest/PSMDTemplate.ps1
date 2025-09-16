@{
	TemplateName		 = 'AzureFunctionRest'
	Version			     = "1.0.0.0"
	AutoIncrementVersion = $true
	Tags				 = 'azure', 'function', 'rest'
	Author			     = 'Friedrich Weinmann'
	Description	     = 'Adds an HTTP (REST) trigger function with sample request/response handling to the base AzureFunction scaffold'
	Exclusions		     = @("PSMDInvoke.ps1", ".PSMDDependency") # Contains list of files - relative path to root - to ignore when building the template
	Scripts			     = @{ }
}