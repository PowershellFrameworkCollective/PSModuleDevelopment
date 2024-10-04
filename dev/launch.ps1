[CmdletBinding()]
param (
	[switch]
	$Local,

	[switch]
	$Build,

	[ValidateSet('Desktop', 'Core')]
	[string]
	$PSVersion
)

#region Launch in new cponsole
if (-not $Local) {
	$application = (Get-Process -id $PID).Path
	if ($PSVersion -and $PSVersionTable.Edition -ne $PSVersion) {
		$application = 'pwsh.exe'
		if ($PSVersion -eq 'Desktop') { $application = 'powershell.exe'}
	}

	$arguments =  @('-NoExit', '-NoProfile', '-File', "$PSScriptRoot\launch.ps1", '-Local')
	if ($Build) { $arguments += '-Build' }

	Start-Process $application -ArgumentList $arguments
	return
}
#endregion Launch in new cponsole

$ErrorActionPreference = 'Stop'
trap {
	Write-Warning "Script failed: $_"
	throw $_
}

#region Functions
function New-TemporaryPath {
	[OutputType([string])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Prefix
	)

	Write-Host "Creating new temporary path: $Prefix"

	# Remove Previous Temporary Paths
	Remove-Item -Path "$env:Temp\$Prefix*" -Force -Recurse -ErrorAction SilentlyContinue

	# Create New Temporary Path
	$item = New-Item -Path $env:TEMP -Name "$($Prefix)_$(Get-Random)" -ItemType Directory
	$item.FullName
}

function Build-Template {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$RootPath,

		[Parameter(Mandatory = $true)]
		[string]
		$ProjectPath
	)

	Write-Host "Building Templates from Source"
	$buildScriptPath = Join-Path -Path $ProjectPath -ChildPath "templates\build.ps1"
	& $buildScriptPath -Path $RootPath

	Set-PSFConfig -FullName 'PSModuleDevelopment.Template.Store.PSModuleDevelopment' -Value "$RootPath\output"
}

function Import-PsmdModule {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ProjectPath
	)

	Write-Host "Importing PSModuleDevelopment from source code"
	Import-Module "$ProjectPath\PSModuleDevelopment\PSModuleDevelopment.psd1" -Global

	# Does not work during initial start
	# [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory("ipmo '$ProjectPath\PSModuleDevelopment\PSModuleDevelopment.psd1'")
}

function Build-PsmdModule {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ProjectPath
	)

	Write-Host "Building Library. This may require the .NET 4.8 Targeting Pack"
	try { $null = & "$ProjectPath\build\vsts-build-library.ps1" }
	catch {
		Write-Host "Targeting pack Download Link: https://dotnet.microsoft.com/en-us/download/visual-studio-sdks?cid=getdotnetsdk"
		throw
	}
}
#endregion Functions

$projectRoot = Resolve-Path -Path "$PSScriptRoot\.."
$templateRoot = New-TemporaryPath -Prefix PsmdTemplate
if ($Build) { Build-PsmdModule -ProjectPath $projectRoot }
Import-PsmdModule -ProjectPath $projectRoot
Build-Template -RootPath $templateRoot -ProjectPath $projectRoot