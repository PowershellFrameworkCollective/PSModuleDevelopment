@{
	TemplateName = 'PSFModule'
	Version = "1.1.2.0"
	AutoIncrementVersion = $true
	Tags = 'module','psframework'
	Author = 'Friedrich Weinmann'
	Description = 'PSFramework-based module scaffold: prewired logging, configuration, localization, test hooks, build integration & dynamic metadata scripts'
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
		psframework = {
			(Get-Module PSFramework).Version.ToString()
		}
		testfolder = {
			
		}
		pesterconfig = {

		}
	}
}