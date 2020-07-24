function Set-PSMDStagingRepository
{
<#
	.SYNOPSIS
		Define the repository to use for deploying modules along with scripts.
	
	.DESCRIPTION
		Define the repository to use for deploying modules along with scripts.
		By default, modules are deployed using the PSGallery, which may be problematic:
		- Offline computers do not have access to it
		- Low performance compared to a local mirror
	
	.PARAMETER Path
		The local path to use. Will configure that path as a PSRepository.
		The new repository will be named "PSMDStaging".
	
	.PARAMETER Repository
		The name of an existing repository to use
	
	.EXAMPLE
		PS C:\> Set-PSMDStagingRepository -Path 'C:\PowerShell\StagingRepo'
	
		Registers the local path 'C:\PowerShell\StagingRepo' as a repository and will use it for deploying modules along with scripts.
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Path')]
		[PsfValidateScript('PSModuleDevelopment.Validate.File', ErrorString = 'PSModuleDevelopment.Validate.File')]
		[string]
		$Path,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
		[string]
		$Repository
	)
	
	process
	{
		if ($Path)
		{
			if (Get-PSRepository -Name PSMDStaging -ErrorAction Ignore)
			{
				Unregister-PSRepository -Name PSMDStaging
			}
			Register-PSRepository -Name PSMDStaging -SourceLocation $Path -PublishLocation $Path -InstallationPolicy Trusted -PackageManagementProvider
			Set-PSFConfig -Module PSModuleDevelopment -Name 'Script.StagingRepository' -Value PSMDStaging -PassThru | Register-PSFConfig
		}
		else
		{
			Set-PSFConfig -Module PSModuleDevelopment -Name 'Script.StagingRepository' -Value $Repository -PassThru | Register-PSFConfig
		}
	}
}