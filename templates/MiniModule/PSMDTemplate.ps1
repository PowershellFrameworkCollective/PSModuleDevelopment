@{
	TemplateName = 'MiniModule'
	Version = "1.0.0.0"
	AutoIncrementVersion = $true
	Tags = 'module'
	Author = 'Friedrich Weinmann'
	Description = 'Module scaffold with full CI/CD support and minimal dependencies'
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