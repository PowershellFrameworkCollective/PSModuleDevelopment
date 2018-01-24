Register-PSFTeppScriptblock -Name PSMD_dotNetTemplatesInstall -ScriptBlock {
	Get-PSFTaskEngineCache -Module PSModuleDevelopment -Name "dotNetTemplates"
}