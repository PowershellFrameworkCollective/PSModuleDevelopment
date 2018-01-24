Function Get-PSMDWixConfig
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]
	[Cmdletbinding()]
	Param (
		[Parameter(Mandatory = $false)]
		[string]
		$Path = (Get-Location).Path,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$ProductShortName,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$ProductName,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$ProductVersion,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$Manufacturer,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$HelpLink,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$AboutLink,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$UpgradeCodeX86,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$UpgradeCodeX64
	)
	
	$file = Get-WixAbsolutePath((Join-Path $Path '.wix.json'))
	$leaf = Split-Path $Path -Leaf
	$defaults = @{
		'ProductShortName'  = $leaf;
		'ProductName'	    = $leaf;
		'ProductVersion'    = '1.0.0';
		'Manufacturer'	    = $leaf;
		'HelpLink'		    = "http://www.google.com/q=${leaf}";
		'AboutLink'		    = "http://www.google.com/q=${leaf}";
		'UpgradeCodeX86'    = ([System.Guid]::NewGuid().ToString().ToUpper());
		'UpgradeCodeX64'    = ([System.Guid]::NewGuid().ToString().ToUpper())
	}
	$settings = New-Object -TypeName PSCustomObject
	$readSettings = New-Object -TypeName PSCustomObject
	$params = $PSBoundParameters.GetEnumerator() |	Where-Object { ($_.Key -ne 'Path') }
	
	# Make sure we have persistent upgrade codes
	if (Test-Path $file)
	{
		try
		{
			$readSettings = Get-Content -Raw $file | ConvertFrom-Json
		}
		catch { }
	}
	If (!$readSettings.UpgradeCodeX86 -or !$readSettings.UpgradeCodeX64)
	{
		If (!$readSettings.UpgradeCodeX86)
		{
			Add-Member -InputObject $readSettings -MemberType NoteProperty -Name UpgradeCodeX86 -Value ([System.Guid]::NewGuid().ToString().ToUpper())
		}
		If (!$readSettings.UpgradeCode64)
		{
			Add-Member -InputObject $readSettings -MemberType NoteProperty -Name UpgradeCodeX64 -Value ([System.Guid]::NewGuid().ToString().ToUpper())
		}
		#$readsettings
		$null = (New-Item -ItemType Directory -Force -Path (Split-Path $file))
		$readSettings | ConvertTo-JSON | Out-File -Encoding utf8 $file
	}
	
	if (Test-Path $file)
	{
		try
		{
			$readSettings = Get-Content -Raw $file | ConvertFrom-Json
		}
		catch { }
	}
	foreach ($parameter in $params)
	{
		$setting = $parameter.Key.ToLower()
		$value = $parameter.Value
		if ($value)
		{
			if ($readSettings.$setting)
			{
				Add-Member -InputObject $settings -MemberType NoteProperty -Name $setting -Value $readSettings.$setting
			}
			elseif ($defaults.$setting)
			{
				Add-Member -InputObject $settings -MemberType NoteProperty -Name $setting -Value $defaults.$setting
			}
			else
			{
				Add-Member -InputObject $settings -MemberType NoteProperty -Name $setting -Value (Read-Host "$setting")
			}
		}
	}
	if ($params.count -eq 0)
	{
		foreach ($default in $defaults.GetEnumerator())
		{
			$setting = $default.Name
			$value = $default.Value
			Add-Member -InputObject $settings -MemberType NoteProperty -Name $setting -Value $value -Force
		}
		$readSettings.PSObject.Properties | foreach-object {
			$setting = $_.Name
			$value = $_.Value
			Add-Member -InputObject $settings -MemberType NoteProperty -Name $setting -Value $value -Force
		}
	}
	Return $settings
}