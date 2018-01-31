function Publish-Local {
    <#
    .SYNOPSIS
        A simple function to build a local NuGet package from a module.

    .PARAMETER PackagePath
        Path where the package file will be copied.

    .PARAMETER ModulePath
        Path to the PowerShell module you are creating a Nuget package from

    .EXAMPLE
        Publish-Local -PackagePath 'c:\temp\package' -ModulePath .\DBOps
    #>

    [CmdletBinding()]
    param(
        [string]$PackagePath = 'C:\temp\package',
        [Parameter(mandatory=$true)]
        [string]$ModulePath
    )

    Write-Host "Creating package path if needed: " -NoNewline
    try {
        New-Item -Path $PackagePath -ItemType Directory -Force | Out-Null
        Write-Host "done" -ForegroundColor Green
    } catch {
        Write-Host "failed - $_.Exception.Message" -ForegroundColor Red
        return
    }

    Write-Host "Verifying Module Path: " -NoNewline
    if ( Test-Path -Path $ModulePath ) {
        Write-Host "found" -ForegroundColor green
    } else {
        Write-Host "not found" -ForegroundColor red
    }

    Write-Host "Building Nuget Package..." -ForegroundColor Green

    try {
        Register-PSRepository -Name 'TempLocalRepository' -PublishLocation $PackagePath -SourceLocation $PackagePath -InstallationPolicy Trusted -ErrorAction Stop
        Publish-Module -Path $ModulePath -Repository 'TempLocalRepository' -ErrorAction Stop
        Unregister-PSRepository -Name 'TempLocalRepository'
        Write-Host "COMPLETE - Package should now exist in: $($PackagePath)" -ForegroundColor Green
    } catch {
        Unregister-PSRepository -Name 'TempLocalRepository'
        Write-Host "FAILED - $_.Exception.Message" -ForegroundColor Red
        return
    }

}