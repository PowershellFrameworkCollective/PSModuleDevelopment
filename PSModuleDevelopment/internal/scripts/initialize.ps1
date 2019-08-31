#region Ensure Config path exists

# If the folder doesn't exist yet, create it
$root = Split-Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath')
if (-not (Test-Path $root)) { New-Item $root -ItemType Directory -Force | Out-Null }

# If the config file doesn't exist yet, create it
if (-not (Test-Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath'))) { Export-Clixml -InputObject @() -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath') }

#endregion Ensure Config path exists

# Pass on the host UI to the library
[PSModuleDevelopment.Utility.UtilityHost]::RawUI = $host.UI.RawUI