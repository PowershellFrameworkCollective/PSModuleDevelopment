param (
	$Path
)

New-PSMDTemplate -FilePath "$PSScriptRoot\þnameþ.Tests.ps1" -TemplateName CommandTest -OutPath $Path -Description "Testing template for a command unit test" -Author "Friedrich Weinmann" -Tags 'command', 'test', 'file'