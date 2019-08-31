Register-PSFTeppScriptblock -Name PSMD_templatename -ScriptBlock {
	if ($fakeBoundParameter.Store)
	{
		$storeName = $fakeBoundParameter.Store
	}
	else
	{
		$storeName = "*"
	}
	
	$storePaths = Get-PSFConfig -FullName "PSModuleDevelopment.Template.Store.$storeName" | Select-Object -ExpandProperty Value
	$names = @()
	foreach ($path in $storePaths)
	{
		Get-ChildItem $path | Where-Object { $_.Name -match '-Info.xml$' } | ForEach-Object {
			$names += $_.Name -replace '-\d+(\.\d+){0,3}-Info.xml$'
		}
	}
	
	$names | Select-Object -Unique
}