@{
	TemplateName		 = 'AzureFunctionTimer'
	Version			     = "1.0.0.0"
	AutoIncrementVersion = $true
	Tags				 = 'azure', 'function', 'timer'
	Author			     = 'Friedrich Weinmann'
	Description	     = 'Adds a timer (schedule) trigger function with example cron configuration to the base AzureFunction scaffold'
	Exclusions		     = @("PSMDInvoke.ps1", ".PSMDDependency") # Contains list of files - relative path to root - to ignore when building the template
	Scripts			     = @{ }
}