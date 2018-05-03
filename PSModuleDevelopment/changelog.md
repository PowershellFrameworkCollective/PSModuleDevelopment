# Changelog
## 2.2.2.14 (May 03rd, 2018)
 - Upd: Find-PSMDType - add `-Attribute` parameter to filter by class attributes (#27)
 - Fix: Find-PSMDType - suppress error that gets thrown on empty assemblies.

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