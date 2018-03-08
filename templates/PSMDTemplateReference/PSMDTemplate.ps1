@{
	TemplateName = 'þnameþ' # Insert name of template
	Version = "1.0.0.0" # Version to build to
	AutoIncrementVersion = $true # If a newer version than specified is present, instead of the specified version, make it one greater than the existing template
	Tags = @() # Insert Tags as desired
	Author = 'þauthorþ' # The author of the template, not the file / project created from it
	Description = 'þdescriptionþ' # Try describing the template
	Exclusions = @() # Contains list of files - relative path to root - to ignore when building the template
	Scripts = @{
		guid = {
			[System.Guid]::NewGuid().ToString()
		}
	} # Insert additional scriptblocks as needed. Each scriptblock will be executed once only on create, no matter how often it is referenced.
}