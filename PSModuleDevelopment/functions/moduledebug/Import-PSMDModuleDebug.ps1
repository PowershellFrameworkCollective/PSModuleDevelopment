function Import-PSMDModuleDebug
{
	<#
		.SYNOPSIS
			Invokes the preconfigured import of a module.
		
		.DESCRIPTION
			Invokes the preconfigured import of a module.
		
		.PARAMETER Name
			The exact name of the module to import using the specified configuration.
		
		.EXAMPLE
			PS C:\> Import-PSMDModuleDebug -Name 'cPSNetwork'
	
			Imports the cPSNetwork module as it was configured to be imported using Set-ModuleDebug.
		
		.NOTES
			Version 1.0.0.0
            Author: Friedrich Weinmann
            Created on: August 7th, 2016
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Name
	)
	
	# Get original module configuration
	$____module = $null
	$____module = Import-Clixml $PSModuleDevelopment_ModuleConfigPath | Where-Object { $_.Name -eq $Name }
	if (-not $____module) { throw "No matching module configuration found" }
	
	# Process entry
	if ($____module.DebugMode) { Set-Variable -Scope Global -Name "$($____module.Name)_DebugMode" -Value $____module.DebugMode -Force }
	if ($____module.PreImportAction)
	{
		[System.Management.Automation.ScriptBlock]::Create($____module.PreImportAction).Invoke()
	}
	Import-Module -Name $____module.Name -Scope Global
	if ($____module.PostImportAction)
	{
		[System.Management.Automation.ScriptBlock]::Create($____module.PostImportAction).Invoke()
	}
}
New-Alias -Name ipmod -Value Import-ModuleDebug -Option AllScope -Scope Global