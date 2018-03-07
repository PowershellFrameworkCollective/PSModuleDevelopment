$script:PSModuleRoot = $PSScriptRoot

#region Helper function
function Import-ModuleFile
{
	<#
		.SYNOPSIS
			Loads files into the module on module import.
		
		.DESCRIPTION
			This helper function is used during module initialization.
			It should always be dotsourced itself, in order to proper function.
			
			This provides a central location to react to files being imported, if later desired
		
		.PARAMETER Path
			The path to the file to load
		
		.EXAMPLE
			PS C:\> . Import-ModuleFile -File $function.FullName
	
			Imports the file stored in $function according to import policy
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Path
	)
	
	if ($script:dontDotSource) { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null) }
	else { . $Path }
}
#endregion Helper function

# Perform Actions before loading the rest of the content
. Import-ModuleFile -Path "$PSModuleRoot\internal\scripts\preimport.ps1"

#region Load functions
foreach ($function in (Get-ChildItem "$PSModuleRoot\internal\functions" -Recurse -File -Filter "*.ps1"))
{
	. Import-ModuleFile -Path $function.FullName
}

foreach ($function in (Get-ChildItem "$PSModuleRoot\functions" -Recurse -File -Filter "*.ps1"))
{
	. Import-ModuleFile -Path $function.FullName
}
#endregion Load functions

# Perform Actions after loading the module contents
. Import-ModuleFile -Path "$PSModuleRoot\internal\scripts\postimport.ps1"