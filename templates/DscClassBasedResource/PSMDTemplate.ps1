@{
	TemplateName = 'dscclass'
	Version = "1.0.0.0"
	AutoIncrementVersion = $true
	Tags = 'dscresource'
	Author = 'Jan-Hendrik Peters'
	Description = 'Basic class-based DSC resource template with support for Azure Guest Configuration'
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