param (
	$Path
)

New-PSMDTemplate -FilePath "$PSScriptRoot\þnameþ.ps1" -TemplateName configuration -OutPath $Path -Description "Basic configuration template" -Author "Friedrich Weinmann" -Tags 'configuration','file'