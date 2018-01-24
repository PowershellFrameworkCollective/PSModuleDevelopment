Register-PSFTeppScriptblock -Name PSMD_dotNetTemplates -ScriptBlock {
	if (-not (Test-Path "$env:USERPROFILE\.templateengine\dotnetcli")) { return }
	
	$folder = (Get-ChildItem "$env:USERPROFILE\.templateengine\dotnetcli" | Sort-Object Name | Select-Object -Last 1).FullName
	Get-Content -Path "$folder\templatecache.json" | ConvertFrom-Json | Select-Object -ExpandProperty TemplateInfo | Select-Object -ExpandProperty ShortName -Unique
}