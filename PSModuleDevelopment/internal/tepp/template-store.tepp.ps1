Register-PSFTeppScriptblock -Name PSMD_templatestore -ScriptBlock {
	Get-PSFConfig -FullName "PSModuleDevelopment.Template.Store.*" | ForEach-Object {
		$_.Name -replace "^.+\."
	}
}