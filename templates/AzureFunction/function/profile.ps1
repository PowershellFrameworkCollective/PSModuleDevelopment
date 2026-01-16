# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution
# Authenticate with Azure PowerShell using MSI.
# Remove this if you are not planning on using MSI or Azure PowerShell.

if ($env:MSI_SECRET -and (Get-Module -ListAvailable Az.Accounts))
{
	Connect-AzAccount -Identity
}

$pathDelimiter = ';'
if (-not $IsWindows) { $pathDelimiter = ':' }
$modulePaths = $env:PSModulePath -split $pathDelimiter
$ourModulePath = Join-Path -Path $PSScriptRoot -ChildPath Modules

if ($modulePaths -notcontains $ourModulePath) {
	$env:PSModulePath = $ourModulePath, $env:PSModulePath -join $pathDelimiter
}