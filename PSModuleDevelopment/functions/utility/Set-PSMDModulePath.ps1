function Set-PSMDModulePath
{
<#
	.SYNOPSIS
		Sets the path of the module currently being developed.
	
	.DESCRIPTION
		Sets the path of the module currently being developed.
		This is used by several utility commands in order to not require any path input.
		
		This is a wrapper around the psframework configuration system, the same action can be taken by running this command:
		Set-PSFConfig -Module PSModuleDevelopment -Name "Module.Path" -Value $Path
	
	.PARAMETER Module
		The module, the path of which to register.
	
	.PARAMETER Path
		The path to set as currently developed module.
	
	.PARAMETER Register
		Register the specified path, to have it persist across sessions
	
	.PARAMETER EnableException
		Replaces user friendly yellow warnings with bloody red exceptions of doom!
		Use this if you want the function to throw terminating errors you want to catch.
	
	.EXAMPLE
		Set-PSMDModulePath -Path "C:\github\dbatools"
		
		Sets the current module path to "C:\github\dbatools"
	
	.EXAMPLE
		Set-PSMDModulePath -Path "C:\github\dbatools" -Register
		
		Sets the current module path to "C:\github\dbatools"
		Then stores the setting in registry, causing it to be persisted acros multiple sessions.
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Module')]
		[System.Management.Automation.PSModuleInfo]
		$Module,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Path')]
		[string]
		$Path,
		
		[switch]
		$Register,
		
		[switch]
		$EnableException
	)
	
	process
	{
		if ($Path)
		{
			$resolvedPath = Resolve-PSFPath -Path $Path -Provider FileSystem -SingleItem
			if (Test-Path -Path $resolvedPath)
			{
				if ((Get-Item $resolvedPath).PSIsContainer)
				{
					Set-PSFConfig -Module PSModuleDevelopment -Name "Module.Path" -Value $resolvedPath
					if ($Register) { Register-PSFConfig -Module 'PSModuleDevelopment' -Name 'Module.Path' }
					return
				}
			}
			
			Stop-PSFFunction -Target $Path -Message "Could not validate/resolve path: $Path" -EnableException $EnableException -Category InvalidArgument
			return
		}
		else
		{
			Set-PSFConfig -Module PSModuleDevelopment -Name "Module.Path" -Value $Module.ModuleBase
			if ($Register) { Register-PSFConfig -Module 'PSModuleDevelopment' -Name 'Module.Path' }
		}
	}
}