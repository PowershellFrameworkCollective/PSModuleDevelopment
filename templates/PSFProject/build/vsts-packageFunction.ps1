
<#
	.SYNOPSIS
		Packages a Azure Functions project, ready to release.
	
	.DESCRIPTION
		Packages a Azure Functions project, ready to release.
		Should be part of the release pipeline, after ensuring validation.

		Look into the 'AzureFunctionRest' template for generating functions for the module if you do.
	
	.PARAMETER WorkingDirectory
		The root folder to work from.
	
	.PARAMETER Repository
		The name of the repository to use for gathering dependencies from.
#>
param (
	$WorkingDirectory = "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\_þnameþ",
	
	$Repository = 'PSGallery'
)

$moduleName = 'þnameþ'

# Prepare Paths
Write-PSFMessage -Level Host -Message "Creating working folders"
$moduleRoot = Join-Path -Path $WorkingDirectory -ChildPath 'publish'
$workingRoot = New-Item -Path $WorkingDirectory -Name 'working' -ItemType Directory
$modulesFolder = New-Item -Path $workingRoot.FullName -Name Modules -ItemType Directory

# Fill out the modules folder
Write-PSFMessage -Level Host -Message "Transfering built module data into working directory"
Copy-Item -Path "$moduleRoot\$moduleName" -Destination $modulesFolder.FullName -Recurse -Force
foreach ($dependency in (Import-PowerShellDataFile -Path "$moduleRoot\$moduleName\$moduleName.psd1").RequiredModules)
{
	$param = @{
		Repository = $Repository
		Name	   = $dependency.ModuleName
		Path	   = $modulesFolder.FullName
	}
	if ($dependency -is [string]) { $param['Name'] = $dependency }
	if ($dependency.RequiredVersion)
	{
		$param['RequiredVersion'] = $dependency.RequiredVersion
	}
	Write-PSFMessage -Level Host -Message "Preparing Dependency: $($param['Name'])"
	Save-Module @param
}

# Generate function configuration
Write-PSFMessage -Level Host -Message 'Generating function configuration'
foreach ($functionName in (Get-ChildItem -Path "$($moduleRoot)\$moduleName\functions" -Recurse -Filter '*.ps1'))
{
	Write-PSFMessage -Level Host -Message "  Processing function: $functionName"
	$condensedName = $functionName.BaseName -replace '-', ''
	$functionFolder = New-Item -Path $workingRoot.FullName -Name $condensedName -ItemType Directory
	
	Set-Content -Path "$($functionFolder.FullName)\function.json" -Value @"
{
    "entryPoint": "$($functionName.BaseName)",
    "scriptFile": "../Modules/$($moduleName)/$($moduleName).psm1",
    "bindings": [
        {
        "authLevel": "function",
        "type": "httpTrigger",
        "direction": "in",
        "name": "Request",
        "methods": [
            "get",
            "post"
        ]
        },
        {
        "type": "http",
        "direction": "out",
        "name": "Response"
        }
    ],
    "disabled": false
}
"@
	# Implement overrides where specified by the user
	if (Test-Path -Path "$($WorkingDirectory)\azFunctionResources\$($functionName.BaseName).json")
	{
		Copy-Item -Path "$($WorkingDirectory)\azFunctionResources\$($functionName.BaseName).json" -Destination "$($functionFolder.FullName)\function.json" -Force
	}
	if (Test-Path -Path "$($WorkingDirectory)\azFunctionResources\$($condensedName).json")
	{
		Copy-Item -Path "$($WorkingDirectory)\azFunctionResources\$($condensedName).json" -Destination "$($functionFolder.FullName)\function.json" -Force
	}
}

# Transfer common files
Write-PSFMessage -Level Host -Message "Transfering core function data"
Copy-Item -Path "$($WorkingDirectory)\azFunctionResources\host.json" -Destination "$($workingroot.FullName)\"
Copy-Item -Path "$($WorkingDirectory)\azFunctionResources\local.settings.json" -Destination "$($workingroot.FullName)\"
Copy-Item -Path "$($WorkingDirectory)\azFunctionResources\profile.ps1" -Destination "$($workingroot.FullName)\"
Copy-Item -Path "$($WorkingDirectory)\azFunctionResources\root.psm1" -Destination "$($workingroot.FullName)\"

# Zip It
Write-PSFMessage -Level Host -Message "Creating function archive in '$($WorkingDirectory)\$moduleName.zip'"
Compress-Archive -Path "$($workingroot.FullName)\*" -DestinationPath "$($WorkingDirectory)\$moduleName.zip" -Force