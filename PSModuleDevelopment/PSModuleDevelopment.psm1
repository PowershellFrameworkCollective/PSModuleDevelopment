$script:PSModuleRoot = $PSScriptRoot
$script:PSModuleVersion = (Import-PowerShellDataFile -Path "$($script:PSModuleRoot)\PSModuleDevelopment.psd1").ModuleVersion

$script:doDotSource = $false
if (Get-PSFConfigValue -FullName PSModuleDevelopment.Import.DoDotSource) { $script:doDotSource = $true }

#region Helper function
function Import-PSMDFile
{
	<#
		.SYNOPSIS
			Loads files into the module on module import.
		
		.DESCRIPTION
			This helper function is used during module initialization.
			It should always be dotsourced itself, in order to proper function.
		
		.PARAMETER Path
			The path to the file to load
		
		.EXAMPLE
			PS C:\> . Import-PSMDFile -File $function.FullName
	
			Imports the file stored in $function according to import policy
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Path
	)
	
	if ($script:doDotSource) { . (Resolve-Path $Path) }
	else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($(Resolve-Path $Path)))), $null, $null) }
}
#endregion Helper function


# Perform Actions before loading the rest of the content
. Import-PSMDFile -Path "$PSModuleRoot\internal\scripts\preload.ps1"

#region Load internal functions
foreach ($function in (Get-ChildItem "$PSModuleRoot\internal\functions" -Recurse -File -Filter "*.ps1"))
{
	. Import-PSMDFile -Path $function.FullName
}
#endregion Load internal functions

#region Load functions
foreach ($function in (Get-ChildItem "$PSModuleRoot\functions" -Recurse -File -Filter "*.ps1"))
{
	. Import-PSMDFile -Path $function.FullName
}
#endregion Load functions

# Perform Actions after loading the module contents
. Import-PSMDFile -Path "$PSModuleRoot\internal\scripts\postload.ps1"
