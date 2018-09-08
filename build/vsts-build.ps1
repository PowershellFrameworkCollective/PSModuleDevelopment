param (
	$ApiKey,
	$WhatIf
)

# For local execution only
if (-not $env:SYSTEM_DEFAULTWORKINGDIRECTORY)
{
	$env:SYSTEM_DEFAULTWORKINGDIRECTORY = (Get-Item $PSScriptRoot).Parent.FullName
}

# Prepare build folder
$item = New-Item -Path $env:TEMP -Name "Build" -ItemType Directory -Force
Write-PSFMessage -Level Host -Message "Building in $($item.FullName)"
Copy-Item -Path "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\PSModuleDevelopment" -Destination $item.FullName -Recurse

# Build Templates
Write-PSFMessage -Level Host -Message "Building templates"
Write-PSFMessage -Level Host -Message "  Creating root folder"
$templateBuild = New-Item -Path $item.FullName -Name "Templates" -ItemType Directory -Force
Write-PSFMessage -Level Host -Message "  Executing package compilation"
& "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\templates\build.ps1" -Path $templateBuild.FullName
Write-PSFMessage -Level Host -Message "  Merging tempalte packages into build"
Copy-Item -Path "$($templateBuild.FullName)\output\*" -Destination "$($item.FullName)\PSModuleDevelopment\internal\templates" -Force

# Publish to gallery
if ($env:BUILD_BUILDURI -like "vstfs*")
{
	Write-PSFMessage -Level Host -Message "Publishing to gallery"
	if ($WhatIf -or -not $ApiKey) { Publish-Module -Path "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\PSModuleDevelopment" -NuGetApiKey $ApiKey -Force -WhatIf }
	else { Publish-Module -Path "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\PSModuleDevelopment" -NuGetApiKey $ApiKey -Force }
}