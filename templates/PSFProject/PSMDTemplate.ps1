@{
	TemplateName = 'PSFProject'
	Version = "1.0.1.0"
	AutoIncrementVersion = $true
	Tags = 'module','psframework'
	Author = 'Friedrich Weinmann'
	Description = 'PowerShell Framework based project scaffold'
	Exclusions = @("PSMDInvoke.ps1", ".PSMDDependency") # Contains list of files - relative path to root - to ignore when building the template
	Scripts = @{
		guid = {
			[System.Guid]::NewGuid().ToString()
		}
		date = {
			Get-Date -Format "yyyy-MM-dd"
		}
		year = {
			Get-Date -Format "yyyy"
		}
		guid2 = {
			[System.Guid]::NewGuid().ToString().ToUpper()
		}
		guid3 = {
			[System.Guid]::NewGuid().ToString().ToUpper()
		}
		guid4 = {
			[System.Guid]::NewGuid().ToString().ToUpper()
		}
		psframework = {
			(Get-Module PSFramework).Version.ToString()
		}
	}
}