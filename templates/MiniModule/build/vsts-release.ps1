[CmdletBinding()]
param (
	[string]
	$WorkingDirectory
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

if (-not (Test-Path -Path "$WorkingDirectory\publish\þnameþ")) {
	throw "Failed to create release: Cannot find the built code of the module! Run the build step first on the same agent!"
}

$config = Import-PowerShellDataFile -Path (Join-Path -Path $WorkingDirectory -ChildPath 'config.psd1') -ErrorAction Stop
if (-not $config.GithubRelease) {
	Write-Host "Skipping the Github release as configured"
	return
}

$moduleVersion = (Import-PowerShellDataFile -Path "$WorkingDirectory\publish\þnameþ\þnameþ.psd1").ModuleVersion

# Step 1: Zip Module Content
Write-Host "Wrapping up built module into a zip archive"
Compress-Archive -Path "$WorkingDirectory\publish\þnameþ\*" -DestinationPath "$WorkingDirectory\publish\þnameþ.zip" -Force

# Step 2: Create Release
Write-Host "Registering new release for version $($moduleVersion) with Github"
$response = Invoke-RestMethod -Method POST -Uri 'https://api.github.com/repos/þGithubAccountþ/þnameþ/releases' -Headers @{
	Authorization = "Bearer $env:GH_TOKEN"
	Accept = 'application/vnd.github+json'
	'X-GitHub-Api-Version' = '2022-11-28'
} -Body (@{
	tag_name = "v$moduleVersion"
	name = "v$moduleVersion"
	body = "Releasing v$moduleVersion of the þnameþ module."
	make_latest = 'true'
} | ConvertTo-Json -Depth 10 -Compress)

# Step 3: Upload ZIP as Release content

Write-Host "Publishing module archive to new release"
Invoke-RestMethod -Method POST -Uri "$($response.assets_url -replace 'api\.github\.com', 'uploads.github.com')?name=þnameþ.zip" -Headers @{
	Authorization = "Bearer $env:GH_TOKEN"
	Accept = 'application/vnd.github+json'
	'X-GitHub-Api-Version' = '2022-11-28'
	'Content-Type' = 'application/octet-stream'
} -InFile "$WorkingDirectory\publish\þnameþ.zip"
