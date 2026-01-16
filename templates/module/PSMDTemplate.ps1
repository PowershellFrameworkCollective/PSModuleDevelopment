@{
	TemplateName = 'module'
	Version = "1.1.1.0"
	AutoIncrementVersion = $true
	Tags = 'module'
	Author = 'Friedrich Weinmann'
	Description = 'Basic PowerShell module scaffold: standard folder structure, manifest with GUID/year/scripts, function/test placeholders and PSFramework version capture'
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