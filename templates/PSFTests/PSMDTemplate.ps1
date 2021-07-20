@{
	TemplateName = 'PSFTests' # Insert name of template
	Version = "2.0.1" # Version to build to
	AutoIncrementVersion = $true # If a newer version than specified is present, instead of the specified version, make it one greater than the existing template
	Tags = @('Tests', 'PSFramework') # Insert Tags as desired
	Author = 'Friedrich Weinmann' # The author of the template, not the file / project created from it
	Description = 'The PSFramework-based standard test suite for a PowerShell Module' # Try describing the template
	Exclusions = @('PSMDInvoke.ps1') # Contains list of files - relative path to root - to ignore when building the template
	Scripts = @{
		guid = {
			[System.Guid]::NewGuid().ToString()
		}
		testfolder = {
			
		}
		pesterconfig = {

		}
	} # Insert additional scriptblocks as needed. Each scriptblock will be executed once only on create, no matter how often it is referenced.
}