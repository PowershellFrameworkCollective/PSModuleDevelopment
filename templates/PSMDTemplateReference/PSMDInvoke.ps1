param (
	$Path
)
New-PSMDTemplate -FilePath "$PSScriptRoot\PSMDTemplate.ps1" -TemplateName PSMDTemplateReference -OutPath $Path -Description "PSModule Development Template Reference file" -Author "Friedrich Weinmann" -Tags 'template','file','configuration'