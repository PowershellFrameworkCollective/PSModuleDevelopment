[CmdletBinding()]
param (
	[switch]
	$Local,

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

	Start-Process $application -ArgumentList @('-NoExit', '-NoProfile', '-File', "$PSScriptRoot\launch.ps1", '-Local')
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
#endregion Functions

$projectRoot = Resolve-Path -Path "$PSScriptRoot\.."
$templateRoot = New-TemporaryPath -Prefix PsmdTemplate
#Build-PsmdModule -ProjectPath $projectRoot
Import-PsmdModule -ProjectPath $projectRoot
Build-Template -RootPath $templateRoot -ProjectPath $projectRoot