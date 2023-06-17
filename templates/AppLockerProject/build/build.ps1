
param
(
    [string]
    $DependencyPath = (Resolve-Path "$PSScriptRoot\requiredModules.psd1").Path,

    [string]
    $SourcePath = "$PSScriptRoot\..\configurationdata",

    [string]
    $OutputPath = "$PSScriptRoot\..\output",

    [switch]
    $IncludeRsop
)

$psdependConfig = Import-PowerShellDataFile -Path $DependencyPath
$modPath = Resolve-Path -Path $psdependConfig.PSDependOptions.Target
$modOld = $env:PSModulePath
$pathSeparator = [System.IO.Path]::PathSeparator
$env:PSModulePath = "$modPath$pathSeparator$modOld"

$SourcePath = Resolve-Path -Path $SourcePath -ErrorAction Stop
$OutputPath = if (-not (Resolve-Path -Path $OutputPath -ErrorAction SilentlyContinue))
{
    (New-Item -Path $OutputPath -ItemType Directory -Force).FullName
}
else
{
    Resolve-Path -Path $OutputPath
}

$rsopPath = Join-Path -Path $OutputPath -ChildPath rsop
$policyPath = Join-Path -Path $OutputPath -ChildPath policies
if (-not (Test-Path -Path $rsopPath))
{
    $null = New-Item -Path $rsopPath -ItemType Directory -Force
}

if (-not (Test-Path -Path $policyPath))
{
    $null = New-Item -Path $policyPath -ItemType Directory -Force
}

if (Get-DatumRsopCache)
{
    Clear-DatumRsopCache
}

$datum = New-DatumStructure -DefinitionFile (Join-Path $SourcePath Datum.yml)
$rsops = Get-DatumRsop $datum (Get-DatumNodesRecursive -AllDatumNodes $Datum.AllNodes)
$rsops | Export-AlfXml -Path $policyPath

if (-not $IncludeRsop)
{
    $env:PSModulePath = $modOld
    return
}

foreach ($rsop in $rsops)
{
    $domainPath = Join-Path -Path $rsopPath -ChildPath $rsop.Domain
    if (-not (Test-Path -Path $domainPath))
    {
        $null = New-Item -Path $domainPath -ItemType Directory -Force
    }
    $rsop | ConvertTo-Yaml -OutFile (Join-Path -Path $domainPath -ChildPath "$($rsop.PolicyName).yml") -Force
}

$env:PSModulePath = $modOld
