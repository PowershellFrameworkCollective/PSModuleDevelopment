# The parameter identifier used to detect and insert parameters
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.Identifier' -Value 'þ' -Initialize -Validation 'string' -Description "The identifier used by the template system to detect and insert variables / scriptblock values"

# The default values for common parameters
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.ParameterDefault.Author' -Value "$env:USERNAME" -Initialize -Validation 'string' -Description "The default value to set for the parameter 'Author'. This same setting can be created for any other parameter name."
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.ParameterDefault.Company' -Value "MyCompany" -Initialize -Validation 'string' -Description "The default value to set for the parameter 'Company'. This same setting can be created for any other parameter name."

# The file extensions that will not be scanned for content replacement and will be stored as bytes
Set-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.BinaryExtensions' -Value @('.dll','.exe') -Initialize -Description "When creating a template, files with these extensions will be included as raw bytes and not interpreted for parameter insertion."