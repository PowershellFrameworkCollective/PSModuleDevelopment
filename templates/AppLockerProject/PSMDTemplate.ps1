@{
	TemplateName = 'AppLockerProject'
	Version = "1.0.0"
	AutoIncrementVersion = $true
	Tags = 'module','psframework', 'applocker'
	Author = 'Jan-Hendrik Peters'
	Description = 'PSFramework-based AppLocker policy project scaffold with CI pipeline, build/test scripts and structure for authoring & validating AppLocker rules'
	Exclusions = @("PSMDInvoke.ps1", ".PSMDDependency") # Contains list of files - relative path to root - to ignore when building the template
	Scripts = @{ }
    NoFolder = $true
}