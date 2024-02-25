@{
	TemplateName = 'AppLockerProject'
	Version = "1.0.0"
	AutoIncrementVersion = $true
	Tags = 'module','psframework', 'applocker'
	Author = 'Jan-Hendrik Peters'
	Description = 'PowerShell Framework based AppLocker CI template'
	Exclusions = @("PSMDInvoke.ps1", ".PSMDDependency") # Contains list of files - relative path to root - to ignore when building the template
	Scripts = @{ }
    NoFolder = $true
}