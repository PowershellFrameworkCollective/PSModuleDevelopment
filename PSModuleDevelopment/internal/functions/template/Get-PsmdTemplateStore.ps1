function Get-PsmdTemplateStore
{
<#
	.SYNOPSIS
		Returns the configured template stores, usually only default.
	
	.DESCRIPTION
		Returns the configured template stores, usually only default.
		Returns null if no matching store is available.
	
	.PARAMETER Filter
		Default: "*"
		The returned stores are filtered by this.
	
	.EXAMPLE
		PS C:\> Get-PsmdTemplateStore
	
		Returns all stores configured.
	
	.EXAMPLE
		PS C:\> Get-PsmdTemplateStore -Filter default
	
		Returns the default store only
#>
	[CmdletBinding()]
	Param (
		[string]
		$Filter = "*"
	)
	
	process
	{
		Get-PSFConfig -FullName "PSModuleDevelopment.Template.Store.$Filter" | ForEach-Object {
			New-Object PSModuleDevelopment.Template.Store -Property @{
				Path  = $_.Value
				Name  = $_.Name -replace "^.+\."
			}
		}
	}
}