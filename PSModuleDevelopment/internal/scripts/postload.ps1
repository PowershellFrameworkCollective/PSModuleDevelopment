$__modules = Get-PSMDModuleDebug | Sort-Object Priority

foreach ($__module in $__modules)
{
	if ($__module.AutoImport)
	{
		try { . Import-PSMDModuleDebug -Name $__module.Name -ErrorAction Stop }
		catch { Write-PSFMessage -Level Warning -Message "Failed to import Module: $($__module.Name)" -Tag import -ErrorRecord $_ -Target $__module.Name }
	}
}

# Import License
. Import-PSMDFile -Path "$PSModuleDevelopmentModuleRoot\internal\scripts\license.ps1"