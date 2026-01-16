[CmdletBinding()]
param (
	[string]
	$ApiKey,
	
	[string]
	$WorkingDirectory,
	
	[string]
	$Repository = 'PSGallery',
	
	[switch]
	$LocalRepo,

	[switch]
	$SkipDependenciesCheck
)

#region Handle Working Directory Defaults
if (-not $WorkingDirectory) {
	if ($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS) {
		$WorkingDirectory = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath $env:RELEASE_PRIMARYARTIFACTSOURCEALIAS
	}
	else { $WorkingDirectory = $env:SYSTEM_DEFAULTWORKINGDIRECTORY }
}
if (-not $WorkingDirectory) { $WorkingDirectory = Split-Path $PSScriptRoot }
#endregion Handle Working Directory Defaults

$publishDir = Join-Path -Path $WorkingDirectory -ChildPath publish
if (-not (Test-Path -Path $publishDir)) {
	throw "Publish failed: publish directory not found! Ensure you first run the BUILD step (and do it on the same runner/agent)!"
}

if ($LocalRepo) {
	Write-Host "Creating Nuget Package for module: 'þnameþ' at '$(Get-Location)"
	Publish-PSFModule -Path "$($publishDir)\þnameþ" -DestinationPath . -SkipDependenciesCheck
	return
}

# Publish to Gallery
Write-Host "Publishing the þnameþ module to $($Repository)"
$param = @{
	Path                  = "$($publishDir)\þnameþ"
	Repository            = $Repository
	SkipDependenciesCheck = $SkipDependenciesCheck
}
if ($ApiKey) { $param.ApiKey = $ApiKey }

Publish-PSFModule @param