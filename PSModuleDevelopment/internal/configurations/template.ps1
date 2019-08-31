# The parameter identifier used to detect and insert parameters
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.Identifier' -Value 'þ' -Initialize -Validation 'string' -Description "The identifier used by the template system to detect and insert variables / scriptblock values"

# The default values for common parameters
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.ParameterDefault.Author' -Value "$env:USERNAME" -Initialize -Validation 'string' -Description "The default value to set for the parameter 'Author'. This same setting can be created for any other parameter name."
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.ParameterDefault.Company' -Value "MyCompany" -Initialize -Validation 'string' -Description "The default value to set for the parameter 'Company'. This same setting can be created for any other parameter name."

# The file extensions that will not be scanned for content replacement and will be stored as bytes
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.BinaryExtensions' -Value @('.dll', '.exe', '.pdf', '.doc', '.docx', '.xls', '.xlsx') -Initialize -Description "When creating a template, files with these extensions will be included as raw bytes and not interpreted for parameter insertion."

# Define the default store. To add more stores, just add a similar setting with a different last name segment
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.Store.Default' -Value "$path_FileUserShared\WindowsPowerShell\PSModuleDevelopment\Templates" -Initialize -Validation "string" -Description "Path to the default directory where PSModuleDevelopment will store its templates. You can add additional stores by creating the same setting again, only changing the last name segment to a new name and configuring a separate path."
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.Store.PSModuleDevelopment' -Value "$script:ModuleRoot\internal\templates" -Initialize -Validation "string" -Description "Path to the templates shipped in PSModuleDevelopment"

# Define the default path to create from templates in
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.OutPath' -Value '.' -Initialize -Validation 'string' -Description "The path where new files & projects should be created from templates by default."