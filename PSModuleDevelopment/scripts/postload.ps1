$__modules = Get-ModuleDebug | Sort-Object Priority

foreach ($__module in $__modules)
{
	if ($__module.AutoImport)
	{
		try { . Import-ModuleDebug -Name $__module.Name -ErrorAction Stop }
		catch { Write-Warning "Failed to import Module: $($__module.Name)" }
	}
}