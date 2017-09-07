# Perform Actions before loading the rest of the content
. "$PSScriptRoot\scripts\preload.ps1"

#region Load module content

. "$PSScriptRoot\functions\Get-HelpEx.ps1"
. "$PSScriptRoot\functions\Get-ModuleDebug.ps1"
. "$PSScriptRoot\functions\Import-ModuleDebug.ps1"
. "$PSScriptRoot\functions\Measure-CommandEx.ps1"
. "$PSScriptRoot\functions\New-PssModuleProject.ps1"
. "$PSScriptRoot\functions\Remove-ModuleDebug.ps1"
. "$PSScriptRoot\functions\Restart-Shell.ps1"
. "$PSScriptRoot\functions\Set-ModuleDebug.ps1"

#endregion Load module content

# Perform Actions after loading the module contents
. "$PSScriptRoot\scripts\postload.ps1"