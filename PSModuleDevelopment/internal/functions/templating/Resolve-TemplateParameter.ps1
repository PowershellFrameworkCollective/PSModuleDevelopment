function Resolve-TemplateParameter {
	<#
	.SYNOPSIS
		Resolves the parameters to invoke a template with.
	
	.DESCRIPTION
		Resolves the parameters to invoke a template with.

		This processes parameters with the following, ascending priority:

		- From Configuration (if specified)
		- From PSMD Configuration files (if specified)
		- From being explicitly specified on invocation

		Explicitly bound parameters will thus always win.
	
	.PARAMETER Path
		Path in which the template is being invoked.
		If this parameter is specified, it will search the path and all parent paths for PSMDConfig.psd1 files.
		Then read the settings from them, starting at the root path.
		The deeper the path, the later the settings are loaded, overwriting settings from parent folders in case of conflict.
	
	.PARAMETER Configuration
		The Configuration settings specified by the user.
		These take precedence over anything else.
	
	.PARAMETER FromConfiguration
		Whether to load configuration settings from configuration.
	
	.EXAMPLE
		PS C:\> Resolve-TemplateParameter -Path $resolvedPath -Configuration $Configuration -FromConfiguration

		Resolves all parameters for the current template.
	#>
	[OutputType([hashtable])]
	[CmdletBinding()]
	param (
		[string]
		$Path,

		[hashtable]
		$Configuration = @{ },

		[switch]
		$FromConfiguration
	)
	process {
		$newConfiguration = @{ }

		if ($Path) {
			$currentPath = $Path
			$paths = while ($currentPath) {
				$currentPath
				$currentPath = Split-Path $currentPath
			}
			
			foreach ($rootPath in $paths | Sort-Object Length) {
				$configPath = Join-Path $rootPath 'PSMDConfig.psd1'
				if (-not (Test-Path -Path $configPath)) { continue }

				$cfg = Import-PSFPowerShellDataFile -Path $configPath
				if ($cfg -and $cfg -is [hashtable]) {
					foreach ($pair in $cfg.GetEnumerator()) {
						$newConfiguration[$pair.Key] = $pair.Value
					}
				}
			}
		}

		foreach ($pair in $Configuration.GetEnumerator()) {
			$newConfiguration[$pair.Key] = $pair.Value
		}

		if ($FromConfiguration) {
			foreach ($config in Get-PSFConfig -Module 'PSModuleDevelopment' -Name 'Template.ParameterDefault.*') {
				$cfgName = $config.Name -replace '^.+\.([^\.]+)$', '$1'
				if (-not $newConfiguration.ContainsKey($cfgName)) {
					$newConfiguration[$cfgName] = $config.Value
				}
			}
		}

		$newConfiguration
	}
}