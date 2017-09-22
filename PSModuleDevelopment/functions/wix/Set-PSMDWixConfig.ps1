Function Set-PSMDWixConfig
{
	[Cmdletbinding()]
	Param (
		[Parameter(Mandatory = $false)]
		[string]
		$Path = (Get-Location).Path,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$Replace,
		
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = "Object")]
		[object]
		$Settings,
		
		[Parameter(Mandatory = $false, ParameterSetName = "Strings")]
		[string]
		$ProductShortName,
		
		[Parameter(Mandatory = $false, ParameterSetName = "Strings")]
		[string]
		$ProductName,
		
		[Parameter(Mandatory = $false, ParameterSetName = "Strings")]
		[string]
		$ProductVersion,
		
		[Parameter(Mandatory = $false, ParameterSetName = "Strings")]
		[string]
		$Manufacturer,
		
		[Parameter(Mandatory = $false, ParameterSetName = "Strings")]
		[string]
		$HelpLink,
		
		[Parameter(Mandatory = $false, ParameterSetName = "Strings")]
		[string]
		$AboutLink,
		
		[Parameter(Mandatory = $false, ParameterSetName = "Strings")]
		[string]
		$UpgradeCodeX86,
		
		[Parameter(Mandatory = $false, ParameterSetName = "Strings")]
		[string]
		$UpgradeCodeX64
	)
	
	$file = Get-WixAbsolutePath((Join-Path $Path '.wix.json'))
	if ($Settings)
	{
		$newSettings = New-Object -TypeName PSCustomObject
		if (!$Replace)
		{
			$readSettings = Get-PSMDWixConfig -Path $Path
			$readSettings.PSObject.Properties | foreach-object {
				Add-Member -InputObject $newSettings -MemberType NoteProperty -Name $_.Name -Value $_.Value
			}
		}
		$Settings.PSObject.Properties | foreach-object {
			$setting = $_.Name
			$value = $_.Value
			Add-Member -InputObject $newSettings -MemberType NoteProperty -Name $setting -Value $value -Force
		}
		$null = (New-Item -ItemType Directory -Force -Path (Split-Path $file))
		$newSettings | ConvertTo-JSON | Out-File -Encoding utf8 $file
		Get-PSMDWixConfig -Path $Path
	}
	else
	{
		$params = $PSBoundParameters.GetEnumerator() | Where-Object { ($_.Key -ne 'Path') -and ($_.Key -ne 'Settings') -and ($_.Key -ne 'Replace') }
		$Settings = New-Object -TypeName PSCustomObject
		foreach ($parameter in $params)
		{
			$setting = $parameter.Key
			$value = $parameter.Value
			if ($value)
			{
				Add-Member -InputObject $Settings -MemberType NoteProperty -Name $setting -Value $value
			}
		}
		Set-PSMDWixConfig -Path $Path -Settings $Settings -Replace:$Replace
	}
}