param (
	$Path
)

New-PSMDTemplate -FilePath "$PSScriptRoot\þnameþ.ps1" -TemplateName function -OutPath $Path -Description "Basic function template" -Author "Friedrich Weinmann" -Tags 'function','file'