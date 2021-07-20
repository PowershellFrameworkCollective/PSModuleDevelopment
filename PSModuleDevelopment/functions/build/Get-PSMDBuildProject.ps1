function Get-PSMDBuildProject {
<#
	.SYNOPSIS
		Reads & returns a build project.
	
	.DESCRIPTION
		Reads & returns a build project.
		A build project is a container including the steps executed during the build.
	
	.PARAMETER Path
		Path to the build project file.
		May target the folder, in which case the -Name parameter must be specified.
	
	.PARAMETER Name
		The name of the build project to read.
		Use together with the -Path parameter only.
		Absolute file path assumed will be: "<Path>\<Name>.build.json"
	
	.PARAMETER Selected
		Rather than specifying the path to read from, return the currently selected build project.
		Use Select-PSMDBuildProject to select a build project as the default ("selected") project.
	
	.EXAMPLE
		PS C:\> Get-PSMDBuildProject -Path 'C:\code\project' -Name project
	
		Will load the build project stored in the file "C:\code\project\project.build.json"
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
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
