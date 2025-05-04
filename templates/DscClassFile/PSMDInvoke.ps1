param (
	$Path
)

New-PSMDTemplate -FilePath "$PSScriptRoot\þnameþ.ps1" -TemplateName DscClassFile -OutPath $Path -Description "A DSC Resource Class definition" -Author "Friedrich Weinmann" -Tags 'function','file'