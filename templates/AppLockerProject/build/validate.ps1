[CmdletBinding()]
param
(
    [string]
    $ProjectRoot = (Resolve-Path "$PSScriptRoot\..").Path,

    [ValidateSet('Unit', 'ConfigurationData', 'Integration')]
    [string]
    $TestType
)

Import-Module Pester

$global:testroot = Join-Path $ProjectRoot tests
$po = [PesterConfiguration]::New()
$po.Run.Path = Join-Path $global:testroot $TestType
$po.Run.PassThru = $true
$po.Output.Verbosity = 'Detailed'
$po.TestResult.Enabled = $true
$po.TestResult.OutputPath = Join-Path $global:testroot 'testresults.xml'
$po.TestResult.OutputFormat = 'NUnit2.5'

$result = Invoke-Pester -Configuration $po
if ($result.FailedCount -gt 0) {
    throw "Pester tests failed"
}
