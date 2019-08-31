#region Ensure Config path exists

# If there is no global override for the config path, use module default path
# Note: Generally, you shouldn't enforce checking on the global scope for variables. Since importing modules however is a global action, this is an exception
if (-not ($global:PSModuleDevelopment_ModuleConfigPath))
{
	$script:PSModuleDevelopment_ModuleConfigPath = "$($env:APPDATA)\InfernalAssociates\PowerShell\PSModuleDevelopment\config.xml"
}

# If the folder doesn't exist yet, create it
$root = Split-Path $PSModuleDevelopment_ModuleConfigPath
if (-not (Test-Path $root)) { New-Item $root -ItemType Directory -Force | Out-Null }

# If the config file doesn't exist yet, create it
if (-not (Test-Path $PSModuleDevelopment_ModuleConfigPath)) { Export-Clixml -InputObject @() -Path $PSModuleDevelopment_ModuleConfigPath}

#endregion Ensure Config path exists

# Pass on the host UI to the library
[PSModuleDevelopment.Utility.UtilityHost]::RawUI = $host.UI.RawUI