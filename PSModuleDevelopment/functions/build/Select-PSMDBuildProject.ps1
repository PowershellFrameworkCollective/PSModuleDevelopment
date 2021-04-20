function Select-PSMDBuildProject
{
<#
	.SYNOPSIS
		Set the specified build project as the default project.
	
	.DESCRIPTION
		Set the specified build project as the default project.
		This will have most other commands in this Component automatically use the specified project.
	
	.PARAMETER Path
		Path to the project file to pick.
	
	.PARAMETER Register
		Persist the choice as default build project file across PowerShell sessions.
	
	.EXAMPLE
		PS C:\> Select-PSMDBuildProject -Path 'c:\code\Project\Project.build.json'
	
		Sets the specified build project as the default project.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Path,
		
		[switch]
		$Register
	)
	
	process
	{
		Invoke-PSFProtectedCommand -ActionString 'Select-PSMDBuildProject.Testing' -ActionStringValues $Path -ScriptBlock {
			$null = Get-PSMDBuildProject -Path $Path -ErrorAction Stop
		} -Target $Path -EnableException $true -PSCmdlet $PSCmdlet
		Set-PSFConfig -Module PSModuleDevelopment -Name 'Build.Project.Selected' -Value $Path
		if ($Register) { Register-PSFConfig -Module PSModuleDevelopment -Name 'Build.Project.Selected' }
	}
}
