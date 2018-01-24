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
. Import-PSMDFile -Path "$PSModuleRoot\internal\scripts\license.ps1"

# Import maintenance tasks
foreach ($file in (Get-ChildItem -Path "$PSModuleRoot\internal\maintenance"))
{
	. Import-PSMDFile -Path $file.FullName
}

# Import tab completion
foreach ($file in (Get-ChildItem -Path "$PSModuleRoot\internal\tabcompletion\scriptblocks"))
{
	. Import-PSMDFile -Path $file.FullName
}
Import-PSMDFile -Path "$PSModuleRoot\internal\tabcompletion\assignment.ps1"