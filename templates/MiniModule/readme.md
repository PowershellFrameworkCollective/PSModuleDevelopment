# þnameþ

ADD DESCRIPTION HERE

## Project Setup

> TODO: Delete this section from the readme, once you are done with it

> Setup step 1: Configuring the project

In the root folder - right beside this readme file - you can find a `config.psd1` file.
You can find and adjust settings there, such as whether you want the version automatically updated or the `FunctionsToExport` be auto-generated.

Each setting has a description, explaining what it does.
If this is your first module project, you may want to enable `ExportFunction`, to have one less thing to deal with.

> What you need to know & update

Essentially, your module is ready to roll, just needing your content, so these are the things you need to update:

```text
readme.md
þnameþ\þnameþ.psd1
þnameþ\functions
þnameþ\internal\functions
þnameþ\internal\scripts
```

+ `readme.md`: Add some description and examples on how to use your project, then delete the "Project Setup" section, which is for you only.
+ `þnameþ.psd1`: The module manifest. You may need to register your public functions here, maintain the version number or declare dependencies your module uses.
+ `functions`: The folder your public functions go. That is, functions your users should have access to. One function per file, file should have the same name as the function.
+ `internal\functions`: The folder where your internal functions should be placed, that users should not directly use. One function per file, file should have the same name as the function.
+ `internal\scripts`: The folder where scripts go, that are run on module import only. Use for declaring module-wide variables, do some cleanup, or whatever else needs to happen only once per session.

## Installation

To install the module, run:

```powershell
Install-Module -Name 'þnameþ' -Scope CurrentUser
```

Alternatively, if you have any trouble getting modules installed, this might work instead:

```powershell
Invoke-WebRequest 'https://raw.githubusercontent.com/PowershellFrameworkCollective/PSFramework.NuGet/refs/heads/master/bootstrap.ps1' -UseBasicParsing | Invoke-Expression
Install-PSFModule -Name 'þnameþ'
```

## Profit

ADD EXAMPLES HERE
