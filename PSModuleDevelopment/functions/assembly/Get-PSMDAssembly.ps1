function Get-PSMDAssembly
{
	<#
		.SYNOPSIS
			Returns the assemblies currently loaded.
		
		.DESCRIPTION
			Returns the assemblies currently loaded.
		
		.PARAMETER Filter
			Default: *
			The name to filter by
		
		.EXAMPLE
			Get-PSMDAssembly
	
			Lists all imported libraries
	
		.EXAMPLE
			Get-PSMDAsssembly -Filter "Microsoft.*"
	
			Lists all imported libraries whose name starts with "Microsoft.".
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Filter = "*"
	)
	
	[appdomain]::CurrentDomain.GetAssemblies() | Where-Object FullName -Like $Filter
}