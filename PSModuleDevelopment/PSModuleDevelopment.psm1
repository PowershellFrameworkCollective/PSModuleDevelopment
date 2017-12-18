$script:PSModuleDevelopmentModuleRoot = $PSScriptRoot
$script:PSModuleDevelopmentModuleVersion = '2.0.0.0'

$script:doDotSource = $false
if (Get-PSFConfigValue -Name PSModuleDevelopment.Import.DoDotSource) { $script:doDotSource = $true }

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
	
	if ($script:doDotSource) { . $Path }
	else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null) }
}
#endregion Helper function


# Perform Actions before loading the rest of the content
. Import-PSMDFile -Path "$PSModuleDevelopmentModuleRoot\internal\scripts\preload.ps1"

#region Load functions
foreach ($function in (Get-ChildItem "$PSModuleDevelopmentModuleRoot\functions" -Recurse -File -Filter "*.ps1"))
{
	. Import-PSMDFile -Path $function.FullName
}
#endregion Load functions

# Perform Actions after loading the module contents
. Import-PSMDFile -Path "$PSModuleDevelopmentModuleRoot\internal\scripts\postload.ps1"