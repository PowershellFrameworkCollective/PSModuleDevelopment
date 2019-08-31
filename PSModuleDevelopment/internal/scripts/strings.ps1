foreach ($resolvedPath in (Resolve-PSFPath -Path "$($script:ModuleRoot)\en-us\*.psd1"))
{
	$data = Import-PowerShellDataFile -Path $resolvedPath
	
	foreach ($key in $data.Keys)
	{
		[PSFramework.Localization.LocalizationHost]::Write('PSModuleDevelopment', $key, 'en-US', $data[$key])
	}
}