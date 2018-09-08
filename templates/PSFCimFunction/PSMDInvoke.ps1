param (
	$Path
)

New-PSMDTemplate -FilePath "$PSScriptRoot\þnameþ.ps1" -TemplateName PSFCimFunction -OutPath $Path -Description "PSFramework: Create function that connects via CIM" -Author "Friedrich Weinmann" -Tags 'function','file'