function New-PSMDModuleNugetPackage
{
<#
	.SYNOPSIS
		Creates a nuget package from a PowerShell module.
	
	.DESCRIPTION
		This function will take a module and wrap it into a nuget package.
		This is accomplished by creating a temporary local filesystem repository and using the PowerShellGet module to do the actual writing.
		
		Note:
		- Requires PowerShellGet module
		- Dependencies must be built first to the same folder
	
	.PARAMETER ModulePath
		Path to the PowerShell module you are creating a Nuget package from
	
	.PARAMETER PackagePath
		Path where the package file will be copied.
	
	.PARAMETER EnableException
		Replaces user friendly yellow warnings with bloody red exceptions of doom!
		Use this if you want the function to throw terminating errors you want to catch.
	
	.EXAMPLE
		New-PSMDModuleNugetPackage -PackagePath 'c:\temp\package' -ModulePath .\DBOps
		
		Packages the module stored in .\DBOps and stores the nuget file in 'c:\temp\package'
	
	.NOTES
		Author: Mark Wilkinson
		Editor: Friedrich Weinmann
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('ModuleBase')]
		[string[]]
		$ModulePath,
		
		[string]
		$PackagePath = (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Package.Path' -Fallback "$env:TEMP"),
		
		[switch]
		$EnableException
	)
	
	begin
	{
		#region Input validation and prerequisites check
		try
		{
			$null = Get-Command Publish-Module -ErrorAction Stop
			$null = Get-Command Register-PSRepository -ErrorAction Stop
			$null = Get-Command Unregister-PSRepository -ErrorAction Stop
		}
		catch
		{
			$paramStopPSFFunction = @{
				Message				       = "Failed to detect the PowerShellGet module! The module is required in order to execute this function."
				EnableException		       = $EnableException
				Category				   = 'NotInstalled'
				ErrorRecord			       = $_
				OverrideExceptionMessage   = $true
				Tag					       = 'fail', 'validation', 'prerequisites', 'module'
			}
			Stop-PSFFunction @paramStopPSFFunction
			return
		}
		
		if (-not (Test-Path $PackagePath))
		{
			Write-PSFMessage -Level Verbose -Message "Creating path: $PackagePath" -Tag 'begin', 'create', 'path'
			try { $null = New-Item -Path $PackagePath -ItemType Directory -Force -ErrorAction Stop }
			catch
			{
				Stop-PSFFunction -Message "Failed to create output path: $PackagePath" -ErrorRecord $_ -EnableException $EnableException -Tag 'fail', 'bgin', 'create', 'path'
				return
			}
		}
		$resolvedPath = (Get-Item -Path $PackagePath).FullName
		#endregion Input validation and prerequisites check
		
		#region Prepare local Repository
		try
		{
			if (Get-PSRepository | Where-Object Name -EQ 'PSModuleDevelopment_TempLocalRepository')
			{
				Unregister-PSRepository -Name 'PSModuleDevelopment_TempLocalRepository'
			}
			$paramRegisterPSRepository = @{
				Name				 = 'PSModuleDevelopment_TempLocalRepository'
				PublishLocation	     = $resolvedPath
				SourceLocation	     = $resolvedPath
				InstallationPolicy   = 'Trusted'
				ErrorAction		     = 'Stop'
			}
			
			Register-PSRepository @paramRegisterPSRepository
		}
		catch
		{
			Stop-PSFFunction -Message "Failed to create temporary PowerShell Repository" -ErrorRecord $_ -EnableException $EnableException -Tag 'fail', 'bgin', 'create', 'path'
			return
		}
		#endregion Prepare local Repository
	}
	process
	{
		if (Test-PSFFunctionInterrupt) { return }
		#region Process Paths
		foreach ($Path in $ModulePath)
		{
			Write-PSFMessage -Level VeryVerbose -Message "Starting to package: $Path" -Tag 'progress', 'developer' -Target $Path
			
			if (-not (Test-Path $Path))
			{
				Stop-PSFFunction -Message "Path not found: $Path" -EnableException $EnableException -Category InvalidArgument -Tag 'progress', 'developer', 'fail' -Target $Path -Continue
			}
			
			try { Publish-Module -Path $Path -Repository 'PSModuleDevelopment_TempLocalRepository' -ErrorAction Stop -Force }
			catch
			{
				Stop-PSFFunction -Message "Failed to publish module: $Path" -EnableException $EnableException -ErrorRecord $_ -Tag 'progress', 'developer', 'fail' -Target $Path -Continue
			}
			
			Write-PSFMessage -Level Verbose -Message "Finished processing: $Path" -Tag 'progress', 'developer' -Target $Path
		}
		#endregion Process Paths
	}
	end
	{
		Unregister-PSRepository -Name 'PSModuleDevelopment_TempLocalRepository' -ErrorAction Ignore
		if (Test-PSFFunctionInterrupt) { return }
	}
}