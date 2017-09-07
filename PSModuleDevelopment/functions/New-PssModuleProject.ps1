function New-PssModuleProject
{
    <#
        .SYNOPSIS
            Builds a Sapien PowerShell Studio Module Project from a regular module.
        
        .DESCRIPTION
            Builds a Sapien PowerShell Studio Module Project, either a clean one, or imports from a regular module.
            Will ignore all hidden files and folders, will also ignore all files and folders in the root folder that start with a dot (".").
    
            Importing from an existing module requires the module to have a valid manifest.
        
        .PARAMETER Name
            The name of the folder to create the project in.
            Will also be used to name a blank module project. (When importing a module into a project, the name will be taken from the manifest file).
        
        .PARAMETER Path
            The path to create the new module-project folder in. Will default to the PowerShell Studio project folder.
            The function will fail if PSS is not found on the system and no path was specified.
        
        .PARAMETER SourcePath
            The path to the module to import from.
            Specify the path the the root folder the actual module files are in.
        
        .PARAMETER Force
            Force causes the function to overwrite all stuff in the destination folder ($Path\$Name), if it already exists.
        
        .EXAMPLE
            PS C:\> New-PssModuleProject -Name 'Foo'
    
            Creates a new module project named "Foo" in your default project folder.
    
        .EXAMPLE
            PS C:\> New-PssModuleProject -Name dbatools -SourcePath "C:\Github\dbatools"
    
            Imports the dbatools github repo's local copy into a new PSS module project in your default project folder.
    
        .EXAMPLE
            PS C:\> New-PssModuleProject -name 'Northwind' -SourcePath "C:\Github\Northwind" -Path "C:\Projects" -Force
    
            Will create a new module project, importing from "C:\Github\Northwind" and storing it in "C:\Projects". It will overwrite any existing folder named "Northwind" in the destination folder.
        
        .NOTES
            Author:      Friedrich Weinmann
            Editors:     -
            Created on:  01.03.2017
            Last Change: 01.03.2017
            Version:     1.0
            
            Release 1.0 (01.03.2017, Friedrich Weinmann)
            - Initial Release
    #>
    [CmdletBinding(DefaultParameterSetName = "Vanilla")]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,
        
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string]
        $Path,
        
        [Parameter(Mandatory = $true, ParameterSetName = "Import")]
        [string]
        $SourcePath,
        
        [switch]
        $Force
    )
    
    if (-not $PSBoundParameters.ContainsKey("Path"))
    {
        try
        {
            $pssRoot = (Get-ChildItem "HKCU:\Software\SAPIEN Technologies, Inc." -ErrorAction Stop | Where-Object Name -like "*PowerShell Studio*" | Select-Object -last 1 -ExpandProperty Name).Replace("HKEY_CURRENT_USER", "HKCU:")
            $Path = (Get-ItemProperty -Path "$pssRoot\Settings" -Name "DefaultProjectDirectory" -ErrorAction Stop).DefaultProjectDirectory
        }
        catch
        {
            throw "No local PowerShell Studio found and no path specified. Going to take a break now. Bye!"
        }
    }
    
    switch ($PSCmdlet.ParameterSetName)
    {
        #region Vanilla
        "Vanilla"
        {
            if ((-not $Force) -and (Test-Path (Join-Path $Path $Name)))
            {
                throw "There already is an existing folder in '$Path\$Name', cannot create module!"
            }
            
            $root = New-Item -Path $Path -Name $Name -ItemType Directory -Force:$Force
            $Guid = [guid]::NewGuid().Guid
            
            # Create empty .psm1 file
            Set-Content -Path "$($root.FullName)\$Name.psm1" -Value ""
            
            #region Create Manifest
            Set-Content -Path "$($root.FullName)\$Name.psd1" -Value @"
@{
	
	# Script module or binary module file associated with this manifest
	ModuleToProcess = '$Name.psm1'
	
	# Version number of this module.
	ModuleVersion = '1.0.0.0'
	
	# ID used to uniquely identify this module
	GUID = '$Guid'
	
	# Author of this module
	Author = ''
	
	# Company or vendor of this module
	CompanyName = ''
	
	# Copyright statement for this module
	Copyright = '(c) $((Get-Date).Year). All rights reserved.'
	
	# Description of the functionality provided by this module
	Description = 'Module description'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '2.0'
	
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
	RequiredModules = @()
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @()
	
	# Script files (.ps1) that are run in the caller's environment prior to
	# importing this module
	ScriptsToProcess = @()
	
	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess = @()
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @()
	
	# Modules to import as nested modules of the module specified in
	# ModuleToProcess
	NestedModules = @()
	
	# Functions to export from this module
	FunctionsToExport = '*' #For performanace, list functions explicity
	
	# Cmdlets to export from this module
	CmdletsToExport = '*' 
	
	# Variables to export from this module
	VariablesToExport = '*'
	
	# Aliases to export from this module
	AliasesToExport = '*' #For performanace, list alias explicity
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()
			
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
"@
            #endregion Create Manifest
            
            #region Create project file
            Set-Content -Path "$($root.FullName)\$Name.psproj" -Value @"
<Project>
  <Version>2.0</Version>
  <FileID>$Guid</FileID>
  <ProjectType>1</ProjectType>
  <Folders />
  <Files>
    <File Build="2">$Name.psd1</File>
    <File Build="0">$Name.psm1</File>
  </Files>
</Project>
"@
            #endregion Create project file
        }
        #endregion Vanilla

        #region Import
        "Import"
        {
            $SourcePath = Resolve-Path $SourcePath
            if (-not (Test-Path $SourcePath))
            {
                throw "Source path was not detectable!"
            }
            
            if ((-not $Force) -and (Test-Path (Join-Path $Path $Name)))
            {
                throw "There already is an existing folder in '$Path\$Name', cannot create module!"
            }
            
            $items = Get-ChildItem -Path $SourcePath | Where-Object Name -NotLike ".*"
            $root = New-Item -Path $Path -Name $Name -ItemType Directory -Force:$Force
            
            $items | Copy-Item -Destination $root.FullName -Recurse -Force
            
            $items_directories = Get-ChildItem -Path $root.FullName -Recurse -Directory
            $items_psd = Get-Item "$($root.FullName)\*.psd1" | Select-Object -First 1
            
            if (-not $items_psd)
            {
                throw "no module manifest found!"
            }
            
            $ModuleName = $items_psd.BaseName
            $items_files = Get-ChildItem -Path $root.FullName -Recurse -File | Where-Object { ($_.FullName -ne $items_psd.FullName) -and ($_.FullName -ne $items_psd.FullName.Replace(".psd1",".psm1")) }
            
            $Guid = (Get-Content $items_psd.FullName | Select-String "GUID = '(.+?)'").Matches[0].Groups[1].Value
            
            $string_Files = ($items_files | Select-Object -ExpandProperty FullName | ForEach-Object { "    <File Build=`"2`" Shared=`"True`">$(($_ -replace ([regex]::Escape(($root.FullName + "\"))), ''))</File>" }) -join "`n"
            $string_Directories = ($items_Directories | Select-Object -ExpandProperty FullName | ForEach-Object { "    <Folder>$(($_ -replace ([regex]::Escape(($root.FullName + "\"))), ''))</Folder>" }) -join "`n"
            Set-Content -Path "$($root.FullName)\$ModuleName.psproj" -Value @"
<Project>
  <Version>2.0</Version>
  <FileID>$Guid</FileID>
  <ProjectType>1</ProjectType>
  <Folders>
    $($string_Directories)
  </Folders>
  <Files>
    <File Build="2">$ModuleName.psd1</File>
    <File Build="0">$ModuleName.psm1</File>
    $($string_Files)
  </Files>
</Project>
"@
        }
        #endregion Import
    }
}