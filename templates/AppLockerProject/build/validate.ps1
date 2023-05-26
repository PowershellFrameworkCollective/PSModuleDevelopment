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

$po = [PesterConfiguration]::New()
$po.Run.Path = Join-Path $ProjectRoot "tests/$TestType"
$po.Run.PassThru = $true
$po.Output.Verbosity = 'Detailed'
$po.TestResult.Enabled = $true
$po.TestResult.OutputPath = Join-Path $ProjectRoot 'testresults.xml'
$po.TestResult.OutputFormat = 'NUnit2.5'

$result = Invoke-Pester -Configuration $po
if ($result.FailedCount -gt 0) {
    throw "Pester tests failed"
}
