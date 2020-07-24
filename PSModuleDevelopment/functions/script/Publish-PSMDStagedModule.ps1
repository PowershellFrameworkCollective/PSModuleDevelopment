function Publish-PSMDStagedModule
{
<#
	.SYNOPSIS
		Publish a module to your staging repository.
	
	.DESCRIPTION
		Publish a module to your staging repository.
		Always publishes the latest version available when specifying a name.
	
	.PARAMETER Name
		The name of the module to publish.
	
	.PARAMETER Path
		The path to the module to publish.
	
	.PARAMETER Repository
		The repository from which to withdraw the module to then publish to the staging repository.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Publish-PSMDStagedModule -Name 'PSFramework'
	
		Publishes the latest version of PSFramework found on the local machine.
	
	.EXAMPLE
		PS C:\> Publish-PSMDStagedModule -Name 'Microsoft.Graph' -Repository PSGallery
	
		Publishes the entire kit of 'Microsoft.Graph' modules from the PSGallery to the staging repository.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Name')]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Path')]
		[PsfValidateScript('PSModuleDevelopment.Validate.Path', ErrorString = 'PSModuleDevelopment.Validate.Path')]
		[string]
		$Path,
		
		[Parameter(ParameterSetName = 'Name')]
		[string]
		$Repository,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		$tempPath = Get-PSFPath -Name Temp
	}
	process
	{
		#region Explicit Path specified
		if ($Path)
		{
			try { Publish-Module -Path $Path -Repository (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Script.StagingRepository') -ErrorAction Stop }
			catch
			{
				if ($_.FullyQualifiedErrorId -like '*ModuleVersionIsAlreadyAvailableInTheGallery*')
				{
					Write-PSFMessage -Level Warning -String 'Publish-PSMDStagedModule.Module.AlreadyPublished' -StringValues $moduleToPublish.Name, $moduleToPublish.Version -ErrorRecord $_
					return
				}
				
				Stop-PSFFunction -String 'Publish-PSMDStagedModule.Module.PublishError' -StringValues $Name, $folder.Name -ErrorRecord $_ -EnableException $EnableException
				return
			}
			return
		}
		#endregion Explicit Path specified
		
		#region Deploy from source repository
		if ($Repository)
		{
			$workingDirectory = Join-Path -Path $tempPath -ChildPath "psmd_$(Get-Random)"
			$null = New-Item -Path $workingDirectory -ItemType Directory -Force
			
			Save-Module -Name $Name -Repository $Repository -Path $workingDirectory
			
			foreach ($folder in Get-ChildItem -Path $workingDirectory | Sort-Object -Property LastWriteTime)
			{
				$subFolder = Get-ChildItem -Path $folder.FullName | Sort-Object -Property Name -Descending | Select-Object -First 1
				
				try { Publish-Module -Path $subFolder.FullName -Repository (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Script.StagingRepository') -ErrorAction Stop }
				catch
				{
					if ($_.FullyQualifiedErrorId -like '*ModuleVersionIsAlreadyAvailableInTheGallery*') { continue }
					
					Remove-Item -Path $workingDirectory -Force -Recurse -ErrorAction Ignore
					Stop-PSFFunction -String 'Publish-PSMDStagedModule.Module.PublishError' -StringValues $Name, $folder.Name -ErrorRecord $_ -EnableException $EnableException
					return
				}
			}
			
			Remove-Item -Path $workingDirectory -Force -Recurse -ErrorAction Ignore
		}
		#endregion Deploy from source repository
		
		#region Deploy from local computer installation
		else
		{
			$modules = Get-Module -Name $Name -ListAvailable
			if (-not $modules)
			{
				Stop-PSFFunction -String 'Publish-PSMDStagedModule.Module.NotFound' -StringValues $Name -EnableException $EnableException
			}
			$moduleToPublish = $modules | Sort-Object -Property Version -Descending | Select-Object -First 1
			try { Publish-Module -Path $moduleToPublish.ModuleBase -Repository (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Script.StagingRepository') -ErrorAction Stop }
			catch
			{
				if ($_.FullyQualifiedErrorId -like '*ModuleVersionIsAlreadyAvailableInTheGallery*')
				{
					Write-PSFMessage -Level Warning -String 'Publish-PSMDStagedModule.Module.AlreadyPublished' -StringValues $moduleToPublish.Name, $moduleToPublish.Version -ErrorRecord $_
					return
				}
				
				Stop-PSFFunction -String 'Publish-PSMDStagedModule.Module.PublishError' -StringValues $Name, $folder.Name -ErrorRecord $_ -EnableException $EnableException
				return
			}
		}
		#endregion Deploy from local computer installation
	}
}