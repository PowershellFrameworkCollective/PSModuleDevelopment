param
(
    [string]
    $DependencyPath = (Resolve-Path "$PSScriptRoot\requiredModules.psd1").Path
)

$psdependConfig = Import-PowerShellDataFile -Path $DependencyPath

$null = Get-PackageProvider -Name NuGet -ForceBootstrap

Save-Module -Name PackageManagement, PowerShellGet, PSDepend -Repository $psdependConfig.PSDependOptions.Parameters.Repository -Path $psdependConfig.PSDependOptions.Target -Force

Remove-Module -Name PowerShellGet -ErrorAction SilentlyContinue -Force
Remove-Module -Name PackageManagement -ErrorAction SilentlyContinue -Force
Import-Module -Force -Name (Join-Path -Path $psdependConfig.PSDependOptions.Target -ChildPath PackageManagement\*\PackageManagement.psd1 -Resolve)
Import-Module -Force -Name (Join-Path -Path $psdependConfig.PSDependOptions.Target -ChildPath PowerShellGet\*\PowerShellGet.psd1 -Resolve)
Import-Module -Name (Join-Path -Path $psdependConfig.PSDependOptions.Target -ChildPath PSDepend\*\PSDepend.psd1 -Resolve)

Invoke-PSDepend -Path $DependencyPath -Force
