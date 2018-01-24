Register-PSFTeppScriptblock -Name PSMD_dotNetTemplatesUninstall -ScriptBlock {
	if (-not (Test-Path "$env:USERPROFILE\.templateengine\dotnetcli")) { return }
	
	$folder = (Get-ChildItem "$env:USERPROFILE\.templateengine\dotnetcli" | Sort-Object Name | Select-Object -Last 1).FullName
	$items = Get-Content -Path "$folder\installUnitDescriptors.json" | ConvertFrom-Json | Select-Object -ExpandProperty InstalledItems
	$items.PSObject.Properties.Value
}