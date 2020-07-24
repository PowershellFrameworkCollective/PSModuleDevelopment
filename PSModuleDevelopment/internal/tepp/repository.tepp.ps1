Register-PSFTeppScriptblock -Name 'PSModuleDevelopment.Repository' -ScriptBlock {
	(Get-PSRepository).Name
}
Register-PSFTeppArgumentCompleter -Command Publish-PSMDStagedModule -Parameter Repository -Name 'PSModuleDevelopment.Repository'
Register-PSFTeppArgumentCompleter -Command Set-PSMDStagingRepository -Parameter Repository -Name 'PSModuleDevelopment.Repository'