#region Templates
# New-PSMDDotNetProject
Register-PSFTeppArgumentCompleter -Name PSMD_dotNetTemplates -Command New-PSMDDotNetProject -Parameter TemplateName
Register-PSFTeppArgumentCompleter -Name PSMD_dotNetTemplatesUninstall -Command New-PSMDDotNetProject -Parameter Uninstall
Register-PSFTeppArgumentCompleter -Name PSMD_dotNetTemplatesInstall -Command New-PSMDDotNetProject -Parameter Install

# New-PSMDTemplate
Register-PSFTeppArgumentCompleter -Name PSMD_templatestore -Command New-PSMDTemplate -Parameter OutStore

# Get-PSMDTemplate
Register-PSFTeppArgumentCompleter -Name PSMD_templatestore -Command Get-PSMDTemplate -Parameter Store
Register-PSFTeppArgumentCompleter -Name PSMD_templatename -Command Get-PSMDTemplate -Parameter TemplateName

# Invoke-PSMDTemplate
Register-PSFTeppArgumentCompleter -Name PSMD_templatestore -Command Invoke-PSMDTemplate -Parameter Store
Register-PSFTeppArgumentCompleter -Name PSMD_templatename -Command Invoke-PSMDTemplate -Parameter TemplateName

# Remove-PSMDTemplate
Register-PSFTeppArgumentCompleter -Name PSMD_templatestore -Command Remove-PSMDTemplate -Parameter Store
Register-PSFTeppArgumentCompleter -Name PSMD_templatename -Command Remove-PSMDTemplate -Parameter TemplateName

#endregion Templates

#region Refactor
Register-PSFTeppArgumentCompleter -Name psframework-encoding -Command Set-PSMDEncoding -Parameter Encoding
#endregion Refactor