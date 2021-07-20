Register-PSFTeppScriptblock -Name 'PSModuleDevelopment.Build.Action' -ScriptBlock {
	(Get-PSMDBuildAction).Name
}