# Changelog
##
 - New: Format-PSMDParameter - updates legacy parameter notation
 - New: Measure-PSMDLinesOfCode - Measures the lines of code in a scriptfile.
 - New: Search-PSMDPropertyValue - search objects for values in properties
 - Upd: Template PSFTest - adding WMI commands to list of forbidden commands
 - Upd: Template PSFModule - adding changelog
 - Upd: Template PSFModule - adding strings for localization
 - Upd: Template PSFModule - adding scriptblocks
 - Upd: Template PSFProject - updated build txt files to include new module content
 - Fix: Template PSMTest - replacing all -Filter calls on Get-ChildItem
 - Fix: New-PSMDTemplate records binary files as text files

## 2.2.5.41 (December 18th, 2018)
 - Fix: Get-PSMDMember - dropping the unintentional bool return

## 2.2.5.40 (December 17th, 2018)
 - New: Command Show-PSMDSyntax, used to show the parameter syntax with proper highlighting
 - New: Command Get-PSMDMember, used to show the members in a more organic and useful way
 - Fix: Template PSFProject build step was broken

## 2.2.5.37 ( October 20th, 2018)
 - Upd: Set-PSMDModulePath - add `-Module` parameter to persist the setting
 - Upd: Set-PSMDModulePath - add `-Register` parameter for integrated persistence
 - Upd: Set-PSMDEncoding - use `PSFEncoding` parameter class & tabcompletion
 - Upd: Template PSFProject - build directly into psm1
 - Upd: Template PSFProject, PSFModule - automatically read version in psm1 from psd1, rather than requiring explicit maintenance.
 - Fix: Template PSFTest - use category exclusions

## 2.2.5.31 (September 29th, 2018)
 - Fix: Template PSFProject dependencies installed correctly
 
## 2.2.5.30 (September 12th, 2018)
 - Upd: Template integrated NUnit Test Reporting
 - Upd: Template support for compiled module files

## 2.2.5.28 (September 08th, 2018)
 - Fix: Template CommandTest would throw an exception due to missing quotes on a string index

## 2.2.5.27 (September 08th, 2018)
 - Fix: Fixes in the build task

## 2.2.5.26 (September 08th, 2018)
 - New: Command Read-PSMDScript (Alias: parse)
 - New: Command Set-PSMDEncoding
 - New: Template PSFTests - Default module tests
 - New: Template CommandTest - A tempalte that generate a test from an already existing command.
 - Upd: Template PSFModule - some fixes
 - Upd: Template PSFProject - some fixes and improvements to the installer
 - Fix: Template function - encoding error
 - Fix: New-PSMDTemplate - now properly selects scriptblocks across multiple lines

## 2.2.4.18 (May 04rd, 2018)
 - Upd: New-PSMDFormatTableDefinition - Update to add parameters `-IncludePropertyAttribute` and `-ExcludePropertyAttribute`
 
## 2.2.3.17 (May 04rd, 2018)
 - Upd: New-PSMDFormatTableDefinition - Major redesign, extensive additional functionality (#29)
 - Upd: Find-PSMDType - add `-Attribute` parameter to filter by class attributes (#27)
 - Fix: Find-PSMDType - suppress error that gets thrown on empty assemblies.
 - Fix: New-PSMDFormatTableDefinition - Broken closing `<Configuration>` tag (#28)

## 2.2.1.12 (March 08th, 2018)
 - Added out-of-the box templates
 - fix: Verious bugfixes around the template system

## 2.2.1.11 (March 06th, 2018)
 - new: Alias imt --> Invoke-PSMDTemplate
 - Upd: Added TabCompletion to *-PSMDTemplate commands

## 2.2.0.10 (March 06th, 2018)
 - new: Command New-PSMDTemplate
 - new: Command Get-PSMDTemplate
 - new: Command Invoke-PSMDTemplate
 - new: Command Remove-PSMDTemplate

## 2.1.1.3 (February 06th, 2018)
 - new: Command New-PSMDModuleNugetPackage - A command that takes a module and writes it to a Nuget package.
 - Upd: Increased PSFramework required version to 0.9.9.19

## 2.1.0.1 (January 24th, 2018)
 - new: Included suite of tests, in order to provide a more reliable user experience.
 - new: Command New-PSMDDotNetProject - A wrapper around dotnet.exe

## 2.0.0.0 (December 18th, 2017)
 - Breaking change: Renamed all commands to include the PSMD prefix
 - New function: Find-PSMDFileContent (alias: find), to swiftly search in your current project
 - New function: New-PSMDHeader, to create headers for documentation
 - New function: Set-PSMDModulePath, to define the project currently being worked on
 - Suite of new functions that refactor a project:

```
Rename-PSMDParameter: Renames a parameter, then updates the function's internal use, then updates the parameter usage across the entire module.
Set-PSMDCmdletBinding: Inserts a CmdletBinding-Attribute into all functions that need one
Set-PSMDParameterHelp: Globally updates parameter help for all commands that share a parameter across the project
Split-PSMDScriptFile: Exports all functions in a file and creates new files, one per function, named after the function
```

 - New function: New-PSMDFormatTableDefinition, creates format xml for input types that will present it by default as a table
 - New function: Expand-PSMDTypeName, returns a list of all type-names an object has (by default, the entire inheritance chain)
 - New function: Find-PSMDType, search currently imported assemblies for types
 - New function: Get-PSMDAssembly, return the currently imported assemblies
 - New function: Get-PSMDConstructor, return the constructor definitions for a type or the type of an input object
  
## 1.3.0.0 (October 19th, 2016):
 - New function: Measure-CommandEx
 - Renamed function: Get-ExHelp --> Get-HelpEx
 - New Alias: Get-ExHelp --> Get-HelpEx
 - New Alias: hex --> Get-HelpEx
 
## 1.2.0.0 (August 15th, 2016):
 - New function: Get-ExHelp
