param
(
    [string]
    $DependencyPath = (Resolve-Path "$PSScriptRoot\requiredModules.psd1").Path,

    [switch]
    $BuildWorker
)

$psdependConfig = Import-PowerShellDataFile -Path $DependencyPath

if ($BuildWorker.IsPresent)
{
    $null = Get-PackageProvider -Name NuGet -ForceBootstrap

    Install-Module -Force -Name PackageManagement, PowerShellGet -Repository $psdependConfig.PSDependOptions.Parameters.Repository -Scope CurrentUser

    Remove-Module -Name PowerShellGet -ErrorAction SilentlyContinue -Force
    Remove-Module -Name PackageManagement -ErrorAction SilentlyContinue -Force
    Import-Module -Force -Name PowerShellGet
    Import-Module -Force -Name PackageManagement

    $null = Install-WindowsFeature -Name GPMC
}

Save-Module -Name PSDepend -Repository $psdependConfig.PSDependOptions.Parameters.Repository -Path $psdependConfig.PSDependOptions.Target -Force
Import-Module -Name (Join-Path -Path $psdependConfig.PSDependOptions.Target -ChildPath PSDepend\*\PSDepend.psd1 -Resolve)
Invoke-PSDepend -Path $DependencyPath -Force
