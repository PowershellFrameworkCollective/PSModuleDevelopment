param (
	$Path
)

New-PSMDTemplate -FilePath "$PSScriptRoot\þnameþ.provider.ps1" -TemplateName 'PSFLoggingProvider' -OutPath $Path -Description "A Custom Logfile Provider" -Author "Friedrich Weinmann" -Tags 'logging', 'provider', 'file'