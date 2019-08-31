# Add all things you want to run before importing the main code

# Load the strings used in messages
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\strings.ps1"

# Load Variables needed during import
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\variables.ps1"

# Load Configurations
<#
Usually configuration is imported after most of the module has been imported.
This module is an exception to this, as some of its tasks are performed on import.
#>
foreach ($file in (Get-ChildItem "$($script:ModuleRoot)\internal\configurations\*.ps1" -ErrorAction Ignore))
{
	. Import-ModuleFile -Path $file.FullName
}

# Load additional resources needed during import
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\initialize.ps1"