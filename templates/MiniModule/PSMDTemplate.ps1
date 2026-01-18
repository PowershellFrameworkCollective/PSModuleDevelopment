@{
	TemplateName = 'MiniModule'
	Version = "1.0.0.0"
	AutoIncrementVersion = $true
	Tags = 'module'
	Author = 'Friedrich Weinmann'
	Description = 'Lean PowerShell module scaffold with CI/CD basics, minimal dependencies, build + test structure, manifest & metadata placeholders'
	Exclusions = @("PSMDInvoke.ps1") # Contains list of files - relative path to root - to ignore when building the template
	Scripts = @{
		guid = {
			[System.Guid]::NewGuid().ToString()
		}
		year = {
			Get-Date -Format "yyyy"
		}
		date = {
			Get-Date -Format "yyyy-MM-dd"
		}
	}
}