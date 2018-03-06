function Remove-PSMDTemplate
{
<#
	.SYNOPSIS
		Removes templates
	
	.DESCRIPTION
		This function removes templates used in the PSModuleDevelopment templating system.
	
	.PARAMETER Template
		A template object returned by Get-PSMDTemplate.
		Will clear exactly the version specified, from exactly its location.
	
	.PARAMETER TemplateName
		The name of the template to remove.
		Templates are filtered by this using wildcard comparison.
	
	.PARAMETER Store
		The template store to retrieve tempaltes from.
		By default, all stores are queried.
	
	.PARAMETER Path
		Instead of a registered store, look in this path for templates.
	
	.PARAMETER Deprecated
		Will delete all versions of matching templates except for the latest one.
		Note:
		If the same template is found in multiple stores, it will keep a single copy across all stores.
		To process by store, be sure to specify the store parameter and loop over the stores desired.
	
	.PARAMETER EnableException
		Replaces user friendly yellow warnings with bloody red exceptions of doom!
		Use this if you want the function to throw terminating errors you want to catch.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Remove-PSMDTemplate -TemplateName '*' -Deprecated
	
		Remove all templates that have been superseded by a newer version.
	
	.EXAMPLE
		PS C:\> Get-PSMDTemplate -TemplateName 'module' -RequiredVersion '1.2.2.1' | Remove-PSMDTemplate
	
		Removes all copies of the template 'module' with exactly the version '1.2.2.1'
#>
	[CmdletBinding(DefaultParameterSetName = 'NameStore', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Template')]
		[PSModuleDevelopment.Template.TemplateInfo[]]
		$Template,
		
		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'NameStore')]
		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'NamePath')]
		[string]
		$TemplateName,
		
		[Parameter(ParameterSetName = 'NameStore')]
		[string]
		$Store = "*",
		
		[Parameter(Mandatory = $true, ParameterSetName = 'NamePath')]
		[string]
		$Path,
		
		[Parameter(ParameterSetName = 'NameStore')]
		[Parameter(ParameterSetName = 'NamePath')]
		[switch]
		$Deprecated,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ", ")" -Tag 'debug', 'start', 'param'
		
		$templates = @()
		switch ($PSCmdlet.ParameterSetName)
		{
			'NameStore' { $templates = Get-PSMDTemplate -TemplateName $TemplateName -Store $Store -All }
			'NamePath' { $templates = Get-PSMDTemplate -TemplateName $TemplateName -Path $Path -All }
		}
		if ($Deprecated)
		{
			$toKill = @()
			$toKeep = @{ }
			foreach ($item in $templates)
			{
				if ($toKeep.Keys -notcontains $item.Name) { $toKeep[$item.Name] = $item }
				elseif ($toKeep[$item.Name].Version -lt $item.Version)
				{
					$toKill += $toKeep[$item.Name]
					$toKeep[$item.Name] = $item
				}
				else { $toKill += $item}
			}
			$templates = $toKill
		}
		
		function Remove-Template
		{
		<#
			.SYNOPSIS
				Deletes the files associated with a given template.
			
			.DESCRIPTION
				Deletes the files associated with a given template.
				Takes objects returned by Get-PSMDTemplate.
			
			.PARAMETER Template
				The template to kill.
			
			.EXAMPLE
				PS C:\> Remove-Template -Template $template
			
				Removes the template stored in $template
		#>
			[CmdletBinding()]
			Param (
				[PSModuleDevelopment.Template.TemplateInfo]
				$Template
			)
			
			$pathFile = $Template.Path
			$pathInfo = $Template.Path -replace '\.xml$', '-Info.xml'
			
			Remove-Item $pathInfo -Force -ErrorAction Stop
			Remove-Item $pathFile -Force -ErrorAction Stop
		}
	}
	process
	{
		foreach ($item in $Template)
		{
			if ($PSCmdlet.ShouldProcess($item, "Remove template"))
			{
				try { Remove-Template -Template $item }
				catch { Stop-PSFFunction -Message "Failed to remove template $($item)" -EnableException $EnableException -ErrorRecord $_ -Target $item -Tag 'fail', 'template', 'remove' -Continue }
			}
		}
		foreach ($item in $templates)
		{
			if ($PSCmdlet.ShouldProcess($item, "Remove template"))
			{
				try { Remove-Template -Template $item }
				catch { Stop-PSFFunction -Message "Failed to remove template $($item)" -EnableException $EnableException -ErrorRecord $_ -Target $item -Tag 'fail', 'template', 'remove' -Continue }
			}
		}
	}
	end
	{
	
	}
}