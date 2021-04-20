function Get-PSMDBuildProject {
	[CmdletBinding(DefaultParameterSetName = 'Path')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Path')]
		[string]
		$Path,
		
		[Parameter(ParameterSetName = 'Path')]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Selected')]
		[switch]
		$Selected
	)
	
	process {
		#region By Path
		if ($Path) {
			$importPath = $Path
			if ($Name) { $importPath = Join-Path -Path $Path -ChildPath "$Name.build.json" }
			
			Get-Content -Path $importPath -Encoding UTF8 | ConvertFrom-Json
		}
		#endregion By Path
		
		#region Selected
		else {
			Get-Content -Path (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Build.Project.Selected') -Encoding UTF8 | ConvertFrom-Json
		}
		#endregion Selected
	}
}
