function Remove-PSMDModuleDebug
{
	<#
		.SYNOPSIS
			Removes module debugging configurations.
		
		.DESCRIPTION
			Removes module debugging configurations.
		
		.PARAMETER Name
			Name of modules whose debugging configuration should be removed.
	
		.PARAMETER Confirm
			If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
		
		.PARAMETER WhatIf
			If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
		
		.EXAMPLE
			PS C:\> Remove-PSMDModuleDebug -Name "cPSNetwork"
	
			Removes all module debugging configuration for the module cPSNetwork
		
		.NOTES
			Version 1.0.0.0
            Author: Friedrich Weinmann
            Created on: August 7th, 2016
	#>
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
	Param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, Mandatory = $true)]
		[string[]]
		$Name
	)
	
	Begin
	{
		$allModules = Import-Clixml -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath')
	}
	Process
	{
		foreach ($nameItem in $Name)
		{
			($allModules) | Where-Object { $_.Name -like $nameItem } | ForEach-Object {
				if (Test-PSFShouldProcess -Target $_.Name -Action 'Remove from list of modules configured for debugging' -PSCmdlet $PSCmdlet)
				{
					$Module = $_
					$allModules = $allModules | Where-Object { $_ -ne $Module }
				}
			}
		}
	}
	End
	{
		Export-Clixml -InputObject $allModules -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath') -Depth 99
	}
}