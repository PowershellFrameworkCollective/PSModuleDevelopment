@{
	TemplateName = 'module'
	Version = "1.0.0.0"
	AutoIncrementVersion = $true
	Tags = 'module'
	Author = 'Friedrich Weinmann'
	Description = 'Basic module scaffold'
	Exclusions = @("PSMDInvoke.ps1") # Contains list of files - relative path to root - to ignore when building the template
	Scripts = @{
		guid = {
			[System.Guid]::NewGuid().ToString()
		}
		year = {
			Get-Date -Format "yyyy"
		}
		psfversion = {
			(Get-Module PSFramework).Version.ToString()
		}
	}
}