# Changelog

## ???

+ Upd: Template AzureFunction - Update host.json extension bundle version to `[4.*, 5.0.0)`
+ Upd: Template AzureFunction - PSModulePath ensured to exist correctly
+ Upd: Template AzureFunction - Configuration for Flex Consumption added, changing build behavior
+ Upd: Template AzureFunction - Added Eventgrid Trigger folder to project module
+ Upd: Template AzureFunction - Added readme with setup instructions
+ Upd: Template AzureFunction - Added `-Restart` parameter to the build script, restarting the Function App after deployment
+ Upd: Template AzureFunction - Added psf-build.ps1 for faster build through PSFramework.Nuget
+ Upd: Template AzureFunction - Added option to deploy to Flex Consumption plans, disabling Managed Dependencies
+ Upd: Template DscModule - Reordered import sequence to prioritize resources over other components
+ Upd: Template DscModule - Added support to exclude files from the syntax verification, to address issues with PowerShell Classes
+ Fix: Template AzureFunction - the folder "modules" should be "Modules"
+ Fix: Template DscClassFile - Removed a trailing whitespace that would trigger module tests checking for that.

## 2.2.13.176 (2025-05-04)

+ New: Template AzureFunctionEventGrid - dedicated endpoint template for an EventGrid function
+ New: Template DscClassFile - a script file with a scaffold for individual DSC Resources. Intended for use with the DscModule template.
+ New: Template DscModule - a module designed to host one or multiple DSC Resources
+ Upd: Template AzureFunction - now also builds EventGrid triggers.

## 2.2.12.172 (2024-10-06)

+ Fix: Invoke-PSMDTemplate - On WinPS, script-logic on templates is not executed

## 2.2.12.171 (2024-10-04)

+ Upd: Raised PSFramework dependency due to critical security update
+ Fix: Invoke-PSMDTemplate - fails on non-Windows
+ Fix: Invoke-PSMDTemplate - fails with latest PSFramework version

## 2.2.11.168 (2024-05-31)

+ Upd: Template AzureFunction - added config option to override http Endpoint methods (#198)
+ Upd: Template AzureFunction - updated host.json to include some default headers (#197)
+ Fix: Template AzureFunction - build script ignores some overrides due to typo (#199)
+ Fix: Template AzureFunction - build fails when executing without the String module loaded (#196)
+ Fix: Template MiniModule - Automatically adds wrong github sponsor accountname

## 2.2.11.163 (2024-02-25)

+ New: Template ApplockerPipeline - A project that can be used to generate AppLocker policies across environments
+ Upd: Template AzureFunction - Added automatic Endpoint generation based on functions defined in the module
+ Upd: Template PSFProject - Improved PSScriptAnalyzer test results
+ Upd: Template PSFProject - Extended list of blacklisted commands
+ Upd: Template PSFProject - Build logic now also supports compiling the C# solution
+ Upd: Template PSFModule - Improved PSScriptAnalyzer test results
+ Upd: Template PSFModule - Extended list of blacklisted commands
+ Upd: Template PSFHelp - Improved PSScriptAnalyzer test results
+ Upd: Template PSFHelp - Extended list of blacklisted commands
+ Upd: Template MiniModule - Extended list of blacklisted commands
+ Fix: Template PSFProject - Help test fails on PS7.4
+ Fix: Template PSFProject - Help test added ProgressAction to common parameters
+ Fix: Template PSFModule - Help test fails on PS7.4
+ Fix: Template PSFModule - Help test added ProgressAction to common parameters
+ Fix: Template PSFHelp - Help test fails on PS7.4
+ Fix: Template PSFHelp - Help test added ProgressAction to common parameters
+ Fix: Template MiniModule - Help test - added ProgressAction to common parameters

## 2.2.11.146 (2023-05-31)

+ Upd: Export-PSMDString - added support for Get-PSMDLocalizedString calls (#181, thanks @nyanhp)
+ Upd: Invoke-PSMDTemplate - added support from template configuration files (#161)
+ Upd: Template MiniModule - added gitignore & main branch for automation (#179, Thanks @nyanhp)
+ Upd: Template MiniModule - switched github automation from windows-2019 to windows-latest
+ Upd: Template PSFProject - added main branch to build autopmation
+ Upd: Template PSFProject - switched github automation from windows-2019 to windows-latest
+ Upd: Templating - added common picture formats to the list of binary file extensions (#175)

## 2.2.11.139 (2022-04-29)

+ Fix: Invoke-PSMDTemplate - fails to generate templates on PS 5.1, due to splatting vs. explicitly bound parameter (#172)

## 2.2.11.138 (2022-04-19)

+ New: Template MiniModule - a scaffold for a minimal dependencies module
+ Upd: Invoke-PSMDTemplate - added parameter `-GenerateObjects` to return objects representing what would have been created as file, rather than actually creating files / folders. (@Callidus2000; #167)
+ Upd: Restart-PSMDShell (rss) - added support for Windows Terminal
+ Upd: Template AzureFunction - added Azure.Function.Tools as a dependency, dropped the automatic Az dependency (still available though)

## 2.2.10.134 (2022-03-17)

+ New: Test-PSMDClmCompatibility - Tests, whether the targeted file would have trouble executing under Constrained Language Mode.
+ New: alias ftype --> Find-PSMDType
+ Upd: Action: connect-pssession - added Credential parameter
+ Upd: Get-PsmdBuildAction - improved output format
+ Upd: Get-PsmdBuildProject - added support for psd1 documents
+ Fix: New-PSMDBuildProject - Would register relative paths for the current project

## 2.2.10.128 (2021-11-11)

+ New: Action: deployModule - Deploys a module to the target computer(s)
+ Upd: Invoke-PSMDBuildProject - Added parameter resolution from artifacts and configuration
+ Upd: Invoke-PSMDBuildProject - Added automatic artifacts resolution based on value of a parameter: %!Name!% will be resolved to the artifact named "Name".
+ Upd: Invoke-PSMDBuildProject - Added `-InheritArtifacts` parameter to allow keeping artifacts around created before starting the pipeline
+ Fix: Invoke-PSMDTemplate - Invoking templates on PS5.1 fails with invalid replace

## 2.2.10.123 (2021-07-21)

+ Fix: Template PSFProject+ Fixed string test modulename
+ Fix: Template PSFModule+ Fixed string test modulename
+ Fix: Template PSFTest+ Fixed string test modulename

## 2.2.10.120 (2021-07-20)

+ New: Build Component - define build workflows based on pre-defined & extensible action code
+ Upd: Template AzureFunction+ New layout with better build automation
+ Upd: Template AzureFunctionRest+ New layout to integrate into new AzureFunction template
+ Upd: Template PSFProject - added Github Actions integration
+ Upd: Aliases - removed "AllScope" option
+ Fix: Template PSFTest+ Fixed PSScriptAnalyzer test path detection
+ Fix: Template PSFTest+ Fixed string LegalSurplus exception being ignored
+ Fix: Template PSFModule+ Fixed PSScriptAnalyzer test path detection
+ Fix: Template PSFModule+ Fixed string LegalSurplus exception being ignored
+ Fix: Template PSFProject+ Fixed PSScriptAnalyzer test path detection
+ Fix: Template PSFProject+ Fixed string LegalSurplus exception being ignored
+ Fix: TemplateStore - default path iss invalid on MAC (#136)
+ Fix: Invoke-PSMDTemplate - unreliable string replacement through -replace operator (#113)
+ Fix: Publish-PSMDScriptFile - insufficient exclude paths (#138; @Callidus2000)

## 2.2.9.106 (September 10th, 2020)

+ New: Convert-PSMDMessage - Converts a file's use of PSFramework messages to strings.
+ Upd: Export-PSMDString - Adding support for Test-PSFShouldProcess.
+ Fix: Export-PSMDString - Failed with splatting detection

## 2.2.8.104 (July 26th, 2020)

+ Fix: Various bugs in the new functions

## 2.2.8.103 (July 24th, 2020)

+ New: Publish-PSMDScriptFile - Packages a script with all dependencies and "publishes" it as a zip package.
+ New: Get-PSMDFileCommand - Parses a scriptfile and returns the contained/used commands.
+ New: Set-PSMDStagingRepository - Define the repository to use for deploying modules along with scripts.
+ New: Publish-PSMDStagedModule - Publish a module to your staging repository.
+ Fix: Export-PSMDString - Random failure to execute (thanks @AndiBellstedt !)

## 2.2.7.98 (May 30th, 2020)

+ Upd: Template PSFTest - Pester v5 compatibility
+ Upd: Template PSFModule - Pester v5 compatibility
+ Upd: Template PSFProject - Pester v5 compatibility
+ Upd: Template PSFProject - Simplified module import workflow
+ Upd: Template PSFProject - Improved build process cross-agent convenience
+ Upd: Template PSFProject - Prerequisites task automatically detects module dependencies
+ Upd: Template PSFProject - Prerequisites task can be configured to work with any registered repository
+ Upd: Export-PSMDString - Now also detects splatted localization strings (thanks @StevePlp ; #117)

## 2.2.7.90 (September 1st, 2019)

+ New: Export-PSMDString - Parses strings from modules using the PSFramework localization feature.
+ Upd: Measure-PSMDCommand - Renamed from Measure-PSMDCommandEx, performance upgrades, adding option for comparing multiple test sets.
+ Upd: Refactored and updated the ModuleDebug component
+ Upd: Renamed Get-PSMDHelpEx to Get-PSMDHelp
+ Upd: Template PSFProject - Adding `-IncludAZ` switch parameter to `vsts-packageFunction.ps1`, making the template include the AZ module as managed dependency.
+ Upd: Template PSFProject - yaml file for AzDev PR validation pipeline
+ Upd: Refactored module structure to comply with current Fred Reference Architecture
+ Upd: Template PSFTests - Added localization string tests
+ Upd: Remove-PSMDTemplate - Refactored and updated messaging / ShouldProcess implementation
+ Upd: Find-PSMDFileContent+ Updated extension filtering to be configurable and include .cs files by default.
+ Upd: Get-PSMDArgumentCompleter - Refactoring and minor performance improvement
+ Upd: Restart-PSMDShell - Will restart same application as current process, enabling it to restart on core versions
+ Fix: Template PSFProject - Publish Folder created during build is created using `-Force`
+ Fix: Template PSFProject - Cleaning up Azure Function conversion
+ Fix: Template PSFTests - Encoding test no longer fails on core (#104)
+ Fix: Template PSFTests - Referenced DLLs from GAC will fail as path cannot be found (#100)
+ Fix: Template Module - RootModule | 3-element version | Module Import from UNC path
+ Fix: Template-System - Bad default template store path on linux or mac. (#106)

## 2.2.6.72 (May 27th, 2019)

+ New: Template AzureFunction - Creates a basic azure function scaffold
+ New: Template AzureFunctionTimer - Creates a timer triggered Azure Function
+ Upd: Template AzureFunctionRest - Redesigned to only spawn a function rest endpoint to insert into the base AzureFunction template.
+ Upd: Template PSFProject - Improved Azure Functions creation experience, added client module support.

## 2.2.6.68 (May 3rd, 2019)

+ Upd: Template PSFProject - Improved Azure Functions creation experience

## 2.2.6.67 (May 2nd, 2019)

+ Upd: Invoke-PSMDTemplate adding tab completion
+ Fix: Invoke-PSMDTemplate fails to create templates

## 2.2.6.65 (May 2nd, 2019)

+ New: Template: AzureFunctionRest - creates an azure function designed for rest API trigger.
+ Upd: Template: PSFProject added Azure Functions Project CI/CD integration.
+ Upd: Invoke-PSMDTemplate supports `-Encoding` parameter, defaulting to utf8 with BOM.

## 2.2.6.62 (April 30th, 2019)

+ New: Get-PSMDArgumentCompleter - Lists registered argument completers on PS5+
+ New: Template: PSFLoggingProvider - Creates a custom logfile logging provider for module specific logging.
+ Upd: Template: PSFTest - Adding test against module tags with whitespace
+ Upd: Get-PSMDConstructor - Added `-NonPublic` parameter to show hidden constructors.
+ Upd: Template: PSFModule - Improved import speed.
+ Upd: Template: PSFProject - Add parameter `-LocalRepo`
+ Upd: Template: PSFProject - Add parameter `-AutoVersion`
+ Fix: New-PSMDModuleNugetPackage - Resolving input path.
+ Fix: New-PSMDModuleNugetPackage - Reregistering temp export repository if accidentally not cleaned up.
+ Fix: Template: PSFModule+ Fixed format xml closing tag
+ Fix: Template: PSFModule+ Fixed import from network share.

## 2.2.6.51 (January 29th, 2019)

+ New: Format-PSMDParameter+ Updates legacy parameter notation
+ New: Measure-PSMDLinesOfCode - Measures the lines of code in a scriptfile.
+ New: Search-PSMDPropertyValue - search objects for values in properties
+ Upd: Template PSFTest - adding WMI commands to list of forbidden commands
+ Upd: Template PSFModule - adding changelog
+ Upd: Template PSFModule - adding strings for localization
+ Upd: Template PSFModule - adding scriptblocks
+ Upd: Template PSFProject+ Updated build txt files to include new module content
+ Fix: Template PSMTest - replacing all -Filter calls on Get-ChildItem
+ Fix: New-PSMDTemplate records binary files as text files

## 2.2.5.41 (December 18th, 2018)

+ Fix: Get-PSMDMember - dropping the unintentional bool return

## 2.2.5.40 (December 17th, 2018)

+ New: Command Show-PSMDSyntax, used to show the parameter syntax with proper highlighting
+ New: Command Get-PSMDMember, used to show the members in a more organic and useful way
+ Fix: Template PSFProject build step was broken

## 2.2.5.37 ( October 20th, 2018)

+ Upd: Set-PSMDModulePath - add `-Module` parameter to persist the setting
+ Upd: Set-PSMDModulePath - add `-Register` parameter for integrated persistence
+ Upd: Set-PSMDEncoding - use `PSFEncoding` parameter class & tabcompletion
+ Upd: Template PSFProject - build directly into psm1
+ Upd: Template PSFProject, PSFModule - automatically read version in psm1 from psd1, rather than requiring explicit maintenance.
+ Fix: Template PSFTest - use category exclusions

## 2.2.5.31 (September 29th, 2018)

+ Fix: Template PSFProject dependencies installed correctly

## 2.2.5.30 (September 12th, 2018)

+ Upd: Template integrated NUnit Test Reporting
+ Upd: Template support for compiled module files

## 2.2.5.28 (September 08th, 2018)

+ Fix: Template CommandTest would throw an exception due to missing quotes on a string index

## 2.2.5.27 (September 08th, 2018)

+ Fix: Fixes in the build task

## 2.2.5.26 (September 08th, 2018)

+ New: Command Read-PSMDScript (Alias: parse)
+ New: Command Set-PSMDEncoding
+ New: Template PSFTests - Default module tests
+ New: Template CommandTest - A tempalte that generate a test from an already existing command.
+ Upd: Template PSFModule - some fixes
+ Upd: Template PSFProject - some fixes and improvements to the installer
+ Fix: Template function - encoding error
+ Fix: New-PSMDTemplate - now properly selects scriptblocks across multiple lines

## 2.2.4.18 (May 04rd, 2018)

+ Upd: New-PSMDFormatTableDefinition+ Update to add parameters `-IncludePropertyAttribute` and `-ExcludePropertyAttribute`

## 2.2.3.17 (May 04rd, 2018)

+ Upd: New-PSMDFormatTableDefinition - Major redesign, extensive additional functionality (#29)
+ Upd: Find-PSMDType - add `-Attribute` parameter to filter by class attributes (#27)
+ Fix: Find-PSMDType - suppress error that gets thrown on empty assemblies.
+ Fix: New-PSMDFormatTableDefinition - Broken closing `<Configuration>` tag (#28)

## 2.2.1.12 (March 08th, 2018)

+ Added out-of-the box templates
+ Fix: Verious bugfixes around the template system

## 2.2.1.11 (March 06th, 2018)

+ New: Alias imt --> Invoke-PSMDTemplate
+ Upd: Added TabCompletion to *-PSMDTemplate commands

## 2.2.0.10 (March 06th, 2018)

+ New: Command New-PSMDTemplate
+ New: Command Get-PSMDTemplate
+ New: Command Invoke-PSMDTemplate
+ New: Command Remove-PSMDTemplate

## 2.1.1.3 (February 06th, 2018)

+ New: Command New-PSMDModuleNugetPackage - A command that takes a module and writes it to a Nuget package.
+ Upd: Increased PSFramework required version to 0.9.9.19

## 2.1.0.1 (January 24th, 2018)

+ New: Included suite of tests, in order to provide a more reliable user experience.
+ New: Command New-PSMDDotNetProject - A wrapper around dotnet.exe

## 2.0.0.0 (December 18th, 2017)

+ Breaking change: Renamed all commands to include the PSMD prefix
+ New function: Find-PSMDFileContent (alias: find), to swiftly search in your current project
+ New function: New-PSMDHeader, to create headers for documentation
+ New function: Set-PSMDModulePath, to define the project currently being worked on
+ Suite of new functions that refactor a project:

```text
Rename-PSMDParameter: Renames a parameter, then updates the function's internal use, then updates the parameter usage across the entire module.
Set-PSMDCmdletBinding: Inserts a CmdletBinding-Attribute into all functions that need one
Set-PSMDParameterHelp: Globally updates parameter help for all commands that share a parameter across the project
Split-PSMDScriptFile: Exports all functions in a file and creates new files, one per function, named after the function
```

+ New function: New-PSMDFormatTableDefinition, creates format xml for input types that will present it by default as a table
+ New function: Expand-PSMDTypeName, returns a list of all type-names an object has (by default, the entire inheritance chain)
+ New function: Find-PSMDType, search currently imported assemblies for types
+ New function: Get-PSMDAssembly, return the currently imported assemblies
+ New function: Get-PSMDConstructor, return the constructor definitions for a type or the type of an input object
  
## 1.3.0.0 (October 19th, 2016)

+ New function: Measure-CommandEx
+ Renamed function: Get-ExHelp --> Get-HelpEx
+ New Alias: Get-ExHelp --> Get-HelpEx
+ New Alias: hex --> Get-HelpEx

## 1.2.0.0 (August 15th, 2016)

+ New function: Get-ExHelp
