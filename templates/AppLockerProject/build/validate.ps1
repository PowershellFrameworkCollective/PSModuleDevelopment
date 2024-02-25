[CmdletBinding()]
param
(
    [string]
    $DependencyPath = (Resolve-Path "$PSScriptRoot\requiredModules.psd1").Path,

    [string]
    $ProjectRoot = (Resolve-Path "$PSScriptRoot\..").Path,

    [ValidateSet('Unit', 'ConfigurationData', 'Integration')]
    [string]
    $TestType
)

$psdependConfig = Import-PowerShellDataFile -Path $DependencyPath
$modPath = Resolve-Path -Path $psdependConfig.PSDependOptions.Target
$modOld = $env:PSModulePath
$pathSeparator = [System.IO.Path]::PathSeparator
$env:PSModulePath = "$modPath$pathSeparator$modOld"

Import-Module Pester -Force -ErrorAction Stop -MinimumVersion 5.0.0

$global:testroot = Join-Path $ProjectRoot tests
$po = [PesterConfiguration]::New()
$po.Run.Path = Join-Path $global:testroot $TestType
$po.Run.PassThru = $true
$po.Output.Verbosity = 'Detailed'
$po.TestResult.Enabled = $true
$po.TestResult.OutputPath = Join-Path $global:testroot 'testresults.xml'
$po.TestResult.OutputFormat = 'NUnit2.5'

$result = Invoke-Pester -Configuration $po
$env:PSModulePath = $modOld

if ($result.FailedCount -gt 0) {
    throw "Pester tests failed"
}
