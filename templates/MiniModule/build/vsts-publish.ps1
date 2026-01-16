[CmdletBinding()]
param (
	[string]
	$ApiKey,
	
	[string]
	$WorkingDirectory,
	
	[string]
	$Repository = 'PSGallery',
	
	[switch]
	$LocalRepo
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
	# Dependencies must go first
	Write-Host "Creating Nuget Package for module: PSFramework"
	New-PSMDModuleNugetPackage -ModulePath (Get-Module -Name PSFramework).ModuleBase -PackagePath .
	Write-Host "Creating Nuget Package for module: þnameþ"
	New-PSMDModuleNugetPackage -ModulePath "$($publishDir)\þnameþ" -PackagePath .
	return
}

# Publish to Gallery
Write-Host "Publishing the þnameþ module to $($Repository)"
$param = @{
	Path       = "$($publishDir)\þnameþ"
	Force      = $true
	Repository = $Repository
}
if ($ApiKey) { $param.NuGetApiKey = $ApiKey }

Publish-Module @param