@{

	# Script module or binary module file associated with this manifest
	RootModule = 'PSModuleDevelopment.psm1'

	# Version number of this module.
	ModuleVersion = '2.2.10.128'

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

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules	       = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.6.205' }
		@{ ModuleName = 'string'; ModuleVersion = '1.0.0' }
	)

	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @('bin\PSModuleDevelopment.dll')

	# Script files (.ps1) that are run in the caller's environment prior to
	# importing this module
	ScriptsToProcess = @()

	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess = @('xml\PSModuleDevelopment.Types.ps1xml')

	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\PSModuleDevelopment.Format.ps1xml')

	# Modules to import as nested modules of the module specified in
	# ModuleToProcess
	NestedModules = @()

	# Functions to export from this module
	FunctionsToExport  = @(
		'Convert-PSMDMessage'
		'Expand-PSMDTypeName'
		'Export-PSMDString'
		'Find-PSMDFileContent'
		'Find-PSMDType'
		'Format-PSMDParameter'
		'Get-PSMDArgumentCompleter'
		'Get-PSMDAssembly'
		'Get-PSMDBuildAction'
		'Get-PSMDBuildArtifact'
		'Get-PSMDBuildProject'
		'Get-PSMDBuildStep'
		'Get-PSMDConstructor'
		'Get-PSMDFileCommand'
		'Get-PSMDHelp'
		'Get-PSMDMember'
		'Get-PSMDModuleDebug'
		'Get-PSMDTemplate'
		'Import-PSMDModuleDebug'
		'Invoke-PSMDBuildProject'
		'Invoke-PSMDTemplate'
		'Measure-PSMDCommand'
		'Measure-PSMDLinesOfCode'
		'New-PSMDBuildProject'
		'New-PSMDDotNetProject'
		'New-PSMDFormatTableDefinition'
		'New-PSMDHeader'
		'New-PSMDModuleNugetPackage'
		'New-PSMDTemplate'
		'New-PssModuleProject'
		'Publish-PSMDBuildArtifact'
		'Publish-PSMDScriptFile'
		'Publish-PSMDStagedModule'
		'Read-PSMDScript'
		'Register-PSMDBuildAction'
		'Remove-PSMDBuildArtifact'
		'Remove-PSMDModuleDebug'
		'Remove-PSMDTemplate'
		'Rename-PSMDParameter'
		'Resolve-PSMDBuildStepParameter'
		'Restart-PSMDShell'
		'Search-PSMDPropertyValue'
		'Select-PSMDBuildProject'
		'Set-PSMDBuildStep'
		'Set-PSMDCmdletBinding'
		'Set-PSMDEncoding'
		'Set-PSMDModuleDebug'
		'Set-PSMDModulePath'
		'Set-PSMDParameterHelp'
		'Set-PSMDStagingRepository'
		'Show-PSMDSyntax'
		'Split-PSMDScriptFile'
    )

	# Cmdlets to export from this module
	# CmdletsToExport = ''

	# Variables to export from this module
	# VariablesToExport = ''

	# Aliases to export from this module
	AliasesToExport    = @(
		'build'
		'dotnetnew'
		'find'
		'hex'
		'imt'
		'ipmod'
		'parse'
		'Restart-Shell'
        'rss'
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
			LicenseUri = 'https://github.com/PowershellFrameworkCollective/PSModuleDevelopment/blob/development/LICENSE'

			# A URL to the main website for this project.
			ProjectUri = 'http://psframework.org'

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			ReleaseNotes = 'https://github.com/PowershellFrameworkCollective/PSModuleDevelopment/blob/master/PSModuleDevelopment/changelog.md'

		} # End of PSData hashtable

	} # End of PrivateData hashtable
}







