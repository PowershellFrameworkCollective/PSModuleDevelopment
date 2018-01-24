@{
	
	# Script module or binary module file associated with this manifest
	RootModule = 'PSModuleDevelopment.psm1'
	
	# Version number of this module.
	ModuleVersion = '2.1.0.1'
	
	# ID used to uniquely identify this module
	GUID = '37dd5fce-e7b5-4d57-ac37-832055ce49d6'
	
	# Author of this module
	Author = 'Friedrich Weinmann'
	
	# Company or vendor of this module
	CompanyName = 'Infernal Associates ltd.'
	
	# Copyright statement for this module
	Copyright = '(c) 2016. All rights reserved.'
	
	# Description of the functionality provided by this module
	Description = 'A module designed to speed up the development of PowerShell modules'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '3.0'
	
	# Name of the Windows PowerShell host required by this module
	PowerShellHostName = ''
	
	# Minimum version of the Windows PowerShell host required by this module
	PowerShellHostVersion = ''
	
	# Minimum version of the .NET Framework required by this module
	DotNetFrameworkVersion = '2.0'
	
	# Minimum version of the common language runtime (CLR) required by this module
	CLRVersion = '2.0.50727'
	
	# Processor architecture (None, X86, Amd64, IA64) required by this module
	ProcessorArchitecture = 'None'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules		    = @(@{ ModuleName='PSFramework'; ModuleVersion= '0.9.8.17' })
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @('bin\PSModuleDevelopment.dll')
	
	# Script files (.ps1) that are run in the caller's environment prior to
	# importing this module
	ScriptsToProcess = @()
	
	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess = @()
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\PSModuleDevelopment.Format.ps1xml')
	
	# Modules to import as nested modules of the module specified in
	# ModuleToProcess
	NestedModules = @()
	
	# Functions to export from this module
    FunctionsToExport = @(
		'Expand-PSMDTypeName',
		'Find-PSMDFileContent',
		'Find-PSMDType',
		'Get-PSMDAssembly',
		'Get-PSMDConstructor',
		'Get-PSMDHelpEx',
		'Get-PSMDModuleDebug',
		'Import-PSMDModuleDebug',
		'Measure-PSMDCommandEx',
		'New-PSMDDotNetProject',
		'New-PSMDHeader',
		'New-PSMDFormatTableDefinition',
		'New-PssModuleProject',
		'Remove-PSMDModuleDebug',
		'Rename-PSMDParameter',
		'Restart-PSMDShell',
		'Set-PSMDModuleDebug',
		'Set-PSMDCmdletBinding',
		'Set-PSMDModulePath',
		'Set-PSMDParameterHelp',
		'Split-PSMDScriptFile'
    )
	
	# Cmdlets to export from this module
	CmdletsToExport = '' 
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
    AliasesToExport = @(
		'dotnetnew',
		'find',
		'hex',
		'Restart-Shell',
        'rss',
        'ipmod',
        'smd'
    )
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('Development', 'Module')
			
			# A URL to the license for this module.
			# LicenseUri = ''
			
			# A URL to the main website for this project.
			# ProjectUri = ''
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}







