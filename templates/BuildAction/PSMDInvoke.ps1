param (
	$Path
)

New-PSMDTemplate -FilePath "$PSScriptRoot\þnameþ.action.ps1" -TemplateName BuildAction -OutPath $Path -Description "Action for the PSMD Build System" -Author "Friedrich Weinmann" -Tags 'action', 'build','file'