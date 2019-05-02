param (
	$Path
)

New-PSMDTemplate -FilePath "$PSScriptRoot\þnameþ.ps1" -TemplateName AzureFunctionRest -OutPath $Path -Description "Template for an Azure Function with Rest Trigger" -Author "Friedrich Weinmann" -Tags 'function', 'file', 'azure'