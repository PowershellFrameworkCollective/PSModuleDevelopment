Function Invoke-PSMDWixBuild
{
	[Cmdletbinding()]
	Param (
		[Parameter(Mandatory = $false, Position = 0)]
		[string]
		$Path = (Get-Location).Path,
		
		[Parameter(Mandatory = $false)]
		[string[]]
		$Exclude = @('.git', '.gitignore', '*.msi'),
		
		[Parameter(Mandatory = $false)]
		[string]
		$OutputFolder = (Get-Location).Path,
		
		[Parameter(Mandatory = $false)]
		[string]
		$LicenseFile = "$Path\license.rtf",
		
		[Parameter(Mandatory = $false)]
		[string]
		$IconFile = "$Path\icon.ico",
		
		[Parameter(Mandatory = $false)]
		[string]
		$BannerFile = "$Path\banner.bmp",
		
		[Parameter(Mandatory = $false)]
		[string]
		$DialogFile = "$Path\dialog.bmp",
		
		[Parameter(Mandatory = $false)]
		[string]
		$ProductShortName = (Get-PSMDWixConfig -ProductShortName -Path $Path).ProductShortName,
		
		[Parameter(Mandatory = $false)]
		[string]
		$ProductName = (Get-PSMDWixConfig -ProductName -Path $Path).ProductName,
		
		[Parameter(Mandatory = $false)]
		[string]
		$ProductVersion = (Get-PSMDWixConfig -ProductVersion -Path $Path).ProductVersion,
		
		[Parameter(Mandatory = $false)]
		[string]
		$Manufacturer = (Get-PSMDWixConfig -Manufacturer -Path $Path).Manufacturer,
		
		[Parameter(Mandatory = $false)]
		[string]
		$HelpLink = (Get-PSMDWixConfig -HelpLink -Path $Path).HelpLink,
		
		[Parameter(Mandatory = $false)]
		[string]
		$AboutLink = (Get-PSMDWixConfig -AboutLink -Path $Path).AboutLink,
		
		[Parameter(Mandatory = $false)]
		[string]
		$UpgradeCodeX86 = (Get-PSMDWixConfig -UpgradeCodeX86 -Path $Path).UpgradeCodeX86,
		
		[Parameter(Mandatory = $false)]
		[string]
		$UpgradeCodeX64 = (Get-PSMDWixConfig -UpgradeCodeX64 -Path $Path).UpgradeCodeX64,
		
		[Parameter(Mandatory = $false)]
		[int]
		$Increment = 3,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$NoX86,
		
		[Parameter(Mandatory = $false)]
		[switch]
		$NoX64
	)
	
	#region Helper functions
	Function ConvertTo-WixNeutralString
	{
		[CmdletBinding()]
		Param (
			[string]
			$Text
		)
		$changes = New-Object System.Collections.Hashtable
		$changes.'ß' = 'ss'
		$changes.'Ä' = 'Ae'
		$changes.'ä' = 'ae'
		$changes.'Ü' = 'Ue'
		$changes.'ü' = 'ue'
		$changes.'Ö' = 'Oe'
		$changes.'ö' = 'oe'
		$changes.' ' = '_'
		$changes.'-' = '_'
		Foreach ($key in $changes.Keys)
		{
			$text = $text.Replace($key, $changes.$key)
		}
		$text
	}
	
	Function Copy-WixSourceFiles
	{
		[Cmdletbinding()]
		Param (
			[Parameter(Mandatory = $true, Position = 0)]
			[string]
			$Source,
			
			[Parameter(Mandatory = $true, Position = 1)]
			[string]
			$Destination,
			
			[Parameter(Mandatory = $false)]
			[string[]]
			$Exclude
		)
		New-Item $Destination -ItemType directory -Force | Out-Null
		$objects = Get-ChildItem $Source -Force -Exclude $exclude
		foreach ($object in $objects)
		{
			if ($object.Attributes -contains 'Directory')
			{
				Copy-WixSourceFiles $object.Fullname (Join-path $Destination $object.Name) -Exclude $Exclude
			}
			else
			{
				Copy-Item $object.FullName $Destination
			}
		}
	}
	#endregion Helper functions
	
	# Increment version number if requested
	If ($Increment -gt 0)
	{
		$versionArray = $ProductVersion.split(".")
		If ($Increment -gt $versionArray.length)
		{
			$extraDigits = $Increment - $versionArray.length
			for ($i = 0; $i -lt $extraDigits - 1; $i++)
			{
				$versionArray += "0"
			}
			$versionArray += "1"
		}
		else
		{
			$versionArray[$Increment - 1] = [string]([int]($versionArray[$Increment - 1]) + 1)
		}
		$NewProductVersion = $versionArray -Join "."
		Set-PSMDWixConfig -ProductVersion $NewProductVersion -Path $Path | Out-Null
	}
	
	# MSI IDs
	$productId = ConvertTo-WixNeutralString -Text $ProductShortName
	
	# Date and time
	$timeStamp = (Get-Date -format yyyyMMddHHmmss)
	
	# WiX paths
	If ((Get-ChildItem -Path 'C:\Program Files*\WiX*\' -Filter heat.exe -Recurse))
	{
		$wixDir = Split-Path ((((Get-ChildItem -Path 'C:\Program Files (x86)\WiX*\' -Filter heat.exe -Recurse) | Select-Object FullName)[0]).FullName)
	}
	Else
	{
		Throw "Please install WiX Toolset"
	}
	
	#$wixDir = Join-Path $libdir "wix"
	$heatExe = Join-Path $wixDir "heat.exe"
	$candleExe = Join-Path $wixDir "candle.exe"
	$lightExe = Join-Path $wixDir "light.exe"
	
	# Other paths
	$thisModuleName = ConvertTo-WixNeutralString -Text $MyInvocation.MyCommand.ModuleName
	$tmpDirGlobalRoot = Join-Path $Env:TMP $thisModuleName
	$tmpDirThisRoot = Join-Path $tmpDirGlobalRoot $productId
	$tmpDir = Join-Path $tmpDirThisRoot $timeStamp
	
	
	$varName = "var." + $productId
	$oldMsi = Join-Path $OutputFolder ($productID + '*' + ".msi")
	$cabFileName = $productId + ".msi"
	
	$moduleIconFile = Join-Path $PSScriptRoot "icon.ico"
	$moduleBannerFile = Join-Path $PSScriptRoot "banner.bmp"
	$moduleDialogFile = Join-Path $PSScriptRoot "dialog.bmp"
	
	$tmpIconFile = Join-Path $tmpDir "icon.ico"
	$tmpBannerFile = Join-Path $tmpDir "banner.bmp"
	$tmpDialogFile = Join-Path $tmpDir "dialog.bmp"
	
	# MSI IDs
	$productId = ConvertTo-WixNeutralString -Text $ProductShortName
	
	# Create tmp folder
	if (test-path $tmpDir)
	{
		Remove-Item $tmpDir -Recurse
	}
	New-Item $tmpDir -ItemType directory | Out-Null
	
	# Copy Files to tmp dir
	$tmpSourceDir = Join-Path $tmpDir "files"
	Copy-WixSourceFiles $Path $tmpSourceDir -Exclude $Exclude
	
	# Add license
	if (test-path $LicenseFile)
	{
		$licenseCmd = @"
<WixVariable Id="WixUILicenseRtf" Value="$LicenseFile"></WixVariable>
"@
	}
	# Add icon
	if (test-path $IconFile)
	{
		Copy-Item $IconFile $tmpIconFile
	}
	elseif (test-path $moduleIconFile)
	{
		Copy-Item $moduleIconFile $tmpIconFile
	}
	if (test-path $tmpIconFile)
	{
		$iconCmd = @"
<Icon Id="icon.ico" SourceFile="$tmpIconFile"/>
<Property Id="ARPPRODUCTICON" Value="icon.ico" />
"@
	}
	# Add banner graphic
	if (test-path $BannerFile)
	{
		Copy-Item $BannerFile $tmpBannerFile
	}
	elseif (test-path $moduleBannerFile)
	{
		Copy-Item $moduleBannerFile $tmpBannerFile
	}
	if (test-path $tmpBannerFile)
	{
		$bannerCmd = @"
<WixVariable Id="WixUIBannerBmp" Value="$tmpBannerFile"></WixVariable>
"@
	}
	# Add dialog graphic
	if (test-path $DialogFile)
	{
		Copy-Item $DialogFile $tmpDialogFile
	}
	elseif (test-path $moduleDialogFile)
	{
		Copy-Item $moduleDialogFile $tmpDialogFile
	}
	if (test-path $tmpDialogFile)
	{
		$dialogCmd = @"
<WixVariable Id="WixUIDialogBmp" Value="$tmpDialogFile"></WixVariable>
"@
	}
	
	# Platform settings
	$platforms = @()
	
	$x86Settings = @{
		'arch'		   = 'x86';
		'sysFolder'    = 'SystemFolder';
		'progfolder'   = 'ProgramFilesFolder';
		'upgradeCode'  = $UpgradeCodeX86;
		'productName'  = "${ProductName} (x86)";
		'outputMsi'    = (Join-Path $OutputFolder ($productID + "_" + $ProductVersion + "_x86.msi"))
	}
	$x64Settings = @{
		'arch'		   = 'x64';
		'sysFolder'    = 'System64Folder';
		'progfolder'   = 'ProgramFiles64Folder';
		'upgradeCode'  = $UpgradeCodeX64;
		'productName'  = "${ProductName} (x64)";
		'outputMsi'    = (Join-Path $OutputFolder ($productID + "_" + $ProductVersion + "_x64.msi"))
	}
	
	If (!$Nox86)
	{
		$platforms += $x86Settings
	}
	If (!$Nox64)
	{
		$platforms += $x64Settings
	}
	
	# Remove existing MSIs
	# Remove-Item $oldMsi
	
	# Do the build
	foreach ($platform in $platforms)
	{
		$platformArch = $platform.arch
		$platformUpgradeCode = $platform.upgradeCode
		$platformSysFolder = $platform.sysFolder
		$platformProgFolder = $platform.progFolder
		$platformProductName = $platform.productName
		
		
		$modulesWxs = Join-Path $tmpDir "_modules${platformArch}.wxs"
		$productWxs = Join-Path $tmpDir ".wxs${platformArch}"
		$modulesWixobj = Join-Path $tmpDir "_modules${platformArch}.wixobj"
		$productWixobj = Join-Path $tmpDir ".wixobj${platformArch}"
		$productPdb = Join-Path $tmpDir ($productID + ".wizpdb${platformArch}")
		
		# Build XML
		$wixXml = [xml] @"
<?xml version="1.0" encoding="utf-8"?>
<Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'>
  <Product Id="*" Language="1033" Name="$platformProductName" Version="$ProductVersion"
           Manufacturer="$Manufacturer" UpgradeCode="$platformUpgradeCode" >

    <Package Id="*" Description="$platformProductName Installer"
             InstallPrivileges="elevated" Comments="$ProductShortName Installer"
             InstallerVersion="200" Compressed="yes" Platform="$platformArch">
    </Package>
    $iconCmd
    <Upgrade Id="$platformUpgradeCode">
      <!-- Detect any newer version of this product -->
      <UpgradeVersion Minimum="$ProductVersion" IncludeMinimum="no" OnlyDetect="yes"
                      Language="1033" Property="NEWPRODUCTFOUND" />

      <!-- Detect and remove any older version of this product -->
      <UpgradeVersion Maximum="$ProductVersion" IncludeMaximum="yes" OnlyDetect="no"
                      Language="1033" Property="OLDPRODUCTFOUND" />
    </Upgrade>

    <!-- Define a custom action -->
    <CustomAction Id="PreventDowngrading"
                  Error="Newer version already installed." />

    <InstallExecuteSequence>
      <!-- Prevent downgrading -->
      <Custom Action="PreventDowngrading" After="FindRelatedProducts">
        NEWPRODUCTFOUND
      </Custom>
      <RemoveExistingProducts After="InstallFinalize" />
    </InstallExecuteSequence>

    <InstallUISequence>
      <!-- Prevent downgrading -->
      <Custom Action="PreventDowngrading" After="FindRelatedProducts">
        NEWPRODUCTFOUND
      </Custom>
    </InstallUISequence>

    <Media Id="1" Cabinet="$cabFileName" EmbedCab="yes"></Media>
    $licenseCmd
    $bannerCmd
    $dialogCmd
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="$platformProgFolder" Name="$platformProgFolder">
        <Directory Id="WindowsPowerShell" Name="WindowsPowerShell">
          <Directory Id="INSTALLDIR" Name="Modules">
            <Directory Id="$ProductId" Name="$ProductShortName">
              <Directory Id="VERSIONDIR" Name="$ProductVersion">
              </Directory>
            </Directory>
          </Directory>
        </Directory>
      </Directory>
    </Directory>
    <Property Id="ARPHELPLINK" Value="$HelpLink"></Property>
    <Property Id="ARPURLINFOABOUT" Value="$AboutLink"></Property>
    <Feature Id="$ProductId" Title="$ProductShortName" Level="1"
             ConfigurableDirectory="INSTALLDIR">
      <ComponentGroupRef Id="VERSIONDIR">
      </ComponentGroupRef>
    </Feature>
    <UI></UI>
    <UIRef Id="WixUI_InstallDir"></UIRef>
    <Property Id="WIXUI_INSTALLDIR" Value="INSTALLDIR"></Property>
  </Product>
</Wix>
"@
		
		# Save XML and create productWxs
		$wixXml.Save($modulesWxs)
		& $heatExe dir $tmpSourceDir -nologo -sfrag -sw5151 -suid -ag -srd -dir $productId -out $productWxs -cg VERSIONDIR -dr VERSIONDIR | Out-Null
		
		# Produce wixobj files
		& $candleexe $modulesWxs -out $modulesWixobj | Out-Null
		& $candleexe $productWxs -out $productWixobj | Out-Null
	}
	foreach ($platform in $platforms)
	{
		$platformArch = $platform.arch
		$modulesWixobj = Join-Path $tmpDir "_modules${platformArch}.wixobj"
		$productWixobj = Join-Path $tmpDir ".wixobj${platformArch}"
		$platformOutputMsi = $platform.outputMsi
		
		# Produce the MSI file
		& $lightexe -sw1076 -spdb -ext WixUIExtension -out $platformOutputMsi $modulesWixobj $productWixobj -b $tmpSourceDir -sice:ICE91 -sice:ICE69 -sice:ICE38 -sice:ICE57 -sice:ICE64 -sice:ICE204 -sice:ICE80 | Out-Null
		
	}
	# Remove tmp dir
	Remove-Item $tmpDir -Recurse
}