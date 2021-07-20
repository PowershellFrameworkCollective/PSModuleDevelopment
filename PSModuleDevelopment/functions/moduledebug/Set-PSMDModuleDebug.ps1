function Set-PSMDModuleDebug
{
	<#
		.SYNOPSIS
			Configures how modules are handled during import of this module.
		
		.DESCRIPTION
			This module allows specifying other modules to import during import of this module.
			Using the Set-PSMDModuleDebug function it is possible to configure, which module is automatically imported, without having to edit the profile each time.
			This import occurs at the end of importing this module, thus setting this module in the profile as automatically imported is recommended.
		
		.PARAMETER Name
			The name of the module to configure for automatic import.
			Needs to be an exact match, the first entry found using "Get-Module -ListAvailable" will be imported.
		
		.PARAMETER AutoImport
			Setting this will cause the module to be automatically imported at the end of importing the PSModuleDevelopment module.
			Even when set to false, the configuration can still be maintained and the debug mode enabled.
		
		.PARAMETER DebugMode
			Setting this will cause the module to create a global variable named "<ModuleName>_DebugMode" with value $true during import of PSModuleDevelopment.
			Modules configured to use this variable can determine the intended import mode using this variable.
		
		.PARAMETER PreImportAction
			Any scriptblock that should run before importing the module.
			Only used when importing modules using the "Invoke-ModuleDebug" funtion, as is used for modules set to auto-import.
		
		.PARAMETER PostImportAction
			Any scriptblock that should run after importing the module.
			Only used when importing modules using the "Invoke-ModuleDebug" funtion, as his used for modules set to auto-import.
	
		.PARAMETER Priority
			When importing modules in a debugging context, they are imported in the order of their priority.
			The lower the number, the sooner it is imported.
		
		.PARAMETER AllAutoImport
			Changes all registered modules to automatically import on powershell launch.
		
		.PARAMETER NoneAutoImport
			Changes all registered modules to not automatically import on powershell launch.
	
		.PARAMETER Confirm
			If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
		
		.PARAMETER WhatIf
			If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
		
		.EXAMPLE
			PS C:\> Set-PSMDModuleDebug -Name 'cPSNetwork' -AutoImport
			
			Configures the module cPSNetwork to automatically import after importing PSModuleDevelopment
		
		.EXAMPLE
			PS C:\> Set-PSMDModuleDebug -Name 'cPSNetwork' -AutoImport -DebugMode
			
			Configures the module cPSNetwork to automatically import after importing PSModuleDevelopment using debug mode.
		
		.EXAMPLE
			PS C:\> Set-PSMDModuleDebug -Name 'cPSNetwork' -AutoImport -DebugMode -PreImportAction { Write-Host "Was done before importing" } -PostImportAction { Write-Host "Was done after importing" }
			
			Configures the module cPSNetwork to automatically import after importing PSModuleDevelopment using debug mode.
			- Running a scriptblock before import
			- Running another scriptblock after import
			
			Note: Using Write-Host is generally - but not always - bad practice
			Note: Verbose output during module import is generally discouraged (doesn't apply to tests of course)
	#>
    [Alias('smd')]
	[CmdletBinding(DefaultParameterSetName = "Name", SupportsShouldProcess = $true)]
	Param (
		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('n')]
		[string]
		$Name,
		
		[Parameter(ParameterSetName = 'Name')]
		[Alias('ai')]
		[switch]
		$AutoImport,
		
		[Parameter(ParameterSetName = 'Name')]
		[Alias('dbg')]
		[switch]
		$DebugMode,
		
		[Parameter(ParameterSetName = 'Name')]
		[AllowNull()]
		[System.Management.Automation.ScriptBlock]
		$PreImportAction,
		
		[Parameter(ParameterSetName = 'Name')]
		[AllowNull()]
		[System.Management.Automation.ScriptBlock]
		$PostImportAction,
		
		[Parameter(ParameterSetName = 'Name')]
		[int]
		$Priority = 5,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'AllImport')]
		[Alias('aai')]
		[switch]
		$AllAutoImport,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'NoneImport')]
		[Alias('nai')]
		[switch]
		$NoneAutoImport
	)
	
	process
	{
		#region AllAutoImport
		if ($AllAutoImport)
		{
			$allModules = Import-Clixml (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath')
			if (Test-PSFShouldProcess -Target ($allModules.Name -join ", ") -Action "Configuring modules to automatically import" -PSCmdlet $PSCmdlet)
			{
				foreach ($module in $allModules)
				{
					$module.AutoImport = $true
				}
				Export-Clixml -InputObject $allModules -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath')
			}
			return
		}
		#endregion AllAutoImport
		
		#region NoneAutoImport
		if ($NoneAutoImport)
		{
			$allModules = Import-Clixml -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath')
			if (Test-PSFShouldProcess -Target ($allModules.Name -join ", ") -Action "Configuring modules to not automatically import" -PSCmdlet $PSCmdlet)
			{
				foreach ($module in $allModules)
				{
					$module.AutoImport = $false
				}
				Export-Clixml -InputObject $allModules -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath')
			}
			return
		}
		#endregion NoneAutoImport
		
		#region Name
		# Import all module-configurations
		$allModules = Import-Clixml -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath')
		
		# If a configuration already exists, change only those values that were specified
		if ($module = $allModules | Where-Object Name -eq $Name)
		{
			if (Test-PSFParameterBinding -ParameterName "AutoImport") { $module.AutoImport = $AutoImport.ToBool() }
			if (Test-PSFParameterBinding -ParameterName "DebugMode") { $module.DebugMode = $DebugMode.ToBool() }
			if (Test-PSFParameterBinding -ParameterName "PreImportAction") { $module.PreImportAction = $PreImportAction }
			if (Test-PSFParameterBinding -ParameterName "PostImportAction") { $module.PostImportAction = $PostImportAction }
			if (Test-PSFParameterBinding -ParameterName "Priority") { $module.Priority = $Priority }
		}
		# If no configuration exists yet, create a new one with all parameters as specified
		else
		{
			$module = [pscustomobject]@{
				Name	   = $Name
				AutoImport = $AutoImport.ToBool()
				DebugMode  = $DebugMode.ToBool()
				PreImportAction = $PreImportAction
				PostImportAction = $PostImportAction
				Priority   = $Priority
			}
		}
		
		# Add new module configuration to all (if any) other previous configurations and export it to config file
		$newModules = @(($allModules | Where-Object Name -ne $Name), $module)
		
		if (Test-PSFShouldProcess -Target $name -Action "Changing debug settings for module" -PSCmdlet $PSCmdlet)
		{
			Export-Clixml -InputObject $newModules -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Debug.ConfigPath')
		}
		#endregion Name
	}
}