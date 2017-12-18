function Invoke-PSMDWixBuild2
{
	[CmdletBinding()]
	Param (
		[string]
		$ConfigurationName,
		
		[string]
		$ConfigurationPath = (Get-Location).Path,
		
		[string]
		$OutputFolder = (Get-Location).Path
	)
	
	<#
	Config Properties:
	
	- Path
	- Exclusions
	- Default Output Folder
	- LicenseFile
	- IconFile
	- BannerFile
	- DialogFile
	- ProductShortName
	- ProductName
	- Manufacturer
	- HelpLink
	- AboutLink
	- UpgradeCodeX86
	- UpgradeCodeX64
	- Build Type (X64 / x86 / x64x86)
	
	The msi product version is read from the module
	#>
}