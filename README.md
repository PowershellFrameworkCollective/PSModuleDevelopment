# PSModuleDevelopment

Welcome to your one stop for PowerShell development tools!
This project is designed to help you with accelerating your coding workflows through a wide range of utilities.
Its flagship feature is a *templating engine* that allows you to swiftly create new projects - either by using some of the default templates or easily creating your own.

## Online Documentation

As this module is part of the PSFramework project, its documentation can be found on [PSFramework.org](https://psframework.org/documentation/documents/psmoduledevelopment/templates.html).

> As ever, documentation takes time out of _"more features!"_, so there could be more, but at least the templating is covered in depth.

## Install

To get read to use this module, run this:

```powershell
Install-Module PSModuleDevelopment -Scope CurrentUser
```

## Profit

With that you are ready to go and have fun with it.
A few examples of what it can do for you:

> Create a new module project

```powershell
Invoke-PSMDTemplate MiniModule
```

> Parse a script file and export all functions into dedicated files

```powershell
Split-PSMDScriptFile -File .\largescript.ps1 -Path .\functions
```

> Fix all the file encodings

```powershell
Get-ChildItem -Recurse -File | Set-PSMDEncoding
```

> Fix parameter blocks

```powershell
Get-ChildItem -Recurse -File | Set-PSMDCmdletBinding
```

> Get better members

```powershell
Get-Date | Get-PSMDMember -Name ToString
```

> Search for Assemblies and Types

```powershell
# List all assemblies
Get-PSMDAssembly

# Search for types in that assembly
Get-PSMDAssembly *ActiveDirectory* | Find-PSMDType

# Search for all types implementing IEnumerable
Find-PSMDType -Implements IEnumerable

# Get Constructors
[DateTime] | Get-PSMDConstructor
```
