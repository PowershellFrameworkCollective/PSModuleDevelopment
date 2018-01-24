param (
	$ApiKey,
	$WhatIf
)

if ($WhatIf) { Publish-Module -Path "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\PSModuleDevelopment" -NuGetApiKey $ApiKey -Force -WhatIf }
else { Publish-Module -Path "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\PSModuleDevelopment" -NuGetApiKey $ApiKey -Force }