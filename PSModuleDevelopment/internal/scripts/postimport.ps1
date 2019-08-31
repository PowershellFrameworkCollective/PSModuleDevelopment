# Add all things you want to run after importing the main code

# Load Scriptblocks
foreach ($file in (Get-ChildItem "$($script:ModuleRoot)\internal\scriptblocks\*.ps1" -ErrorAction Ignore))
{
	. Import-ModuleFile -Path $file.FullName
}

# Load Tab Expansion
foreach ($file in (Get-ChildItem "$($script:ModuleRoot)\internal\tepp\*.tepp.ps1" -ErrorAction Ignore))
{
	. Import-ModuleFile -Path $file.FullName
}

# Load Tab Expansion Assignment
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\tepp\assignment.ps1"

# Load Maintenance tasks
foreach ($file in (Get-ChildItem "$($script:ModuleRoot)\internal\maintenance\*.ps1" -ErrorAction Ignore))
{
	. Import-ModuleFile -Path $file.FullName
}

# Load License
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\license.ps1"

# Load Modules set for debug-import on PSMD import
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\moduledebug.ps1"