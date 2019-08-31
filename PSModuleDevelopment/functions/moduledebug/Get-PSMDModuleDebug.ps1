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
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Filter = "*"
	)
	
	process
	{
		Import-Clixml -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath') | Where-Object {
			($_.Name -like $Filter) -and ($_.Name.Length -gt 0)
		}
	}
}