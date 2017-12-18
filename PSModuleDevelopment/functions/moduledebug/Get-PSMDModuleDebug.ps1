function Get-PSMDModuleDebug
{
	<#
		.SYNOPSIS
			Retrieves module debugging configurations
		
		.DESCRIPTION
			Retrieves a list of all matching module debugging configurations.
		
		.PARAMETER Filter
			Default: "*"
			A string filter applied to the module name. All modules of matching name (using a -Like comparison) will be returned.
		
		.EXAMPLE
			PS C:\> Get-PSMDModuleDebug -Filter *net*
	
			Returns the module debugging configuration for all modules with a name that contains "net"
		
		.NOTES
			Version 1.1.0.0
            Author: Friedrich Weinmann
            Created on: August 7th, 2016
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Filter = "*"
	)
	
	Import-Clixml $PSModuleDevelopment_ModuleConfigPath | Where-Object { ($_.Name -like $Filter) -and ($_.Name.Length -gt 0) }
}