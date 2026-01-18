@{
	TemplateName = 'DscModule'
	Version = "1.0.0"
	AutoIncrementVersion = $true
	Tags = 'module'
	Author = 'Friedrich Weinmann'
	Description = 'Full DSC module project scaffold: resources folder layout, CI/CD & build scripts, automated versioning, test harness, manifest & metadata generation'
	Exclusions = @("PSMDInvoke.ps1") # Contains list of files - relative path to root - to ignore when building the template
	Scripts = @{
		guid = {
			[System.Guid]::NewGuid().ToString()
		}
		year = {
			Get-Date -Format "yyyy"
		}
	}
}