<#
	.SYNOPSIS
		Builds the template files into finished packages.
	
	.DESCRIPTION
		Builds the template files into finished packages.
	
	.PARAMETER Path
		The path in which to work. Will be razed as part of the action.
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[string]
	$Path
)

# Prepare working directories
Remove-Item "$Path\staging" -Recurse -Force -ErrorAction Ignore
Remove-Item "$Path\output" -Recurse -Force -ErrorAction Ignore
$staging = New-Item -Path $Path -ItemType Directory -Name staging -Force
$output = New-Item -Path $Path -ItemType Directory -Name output -Force

<#
Template Dependency structure:
- Name # Name of the template to integrate
- Path # Relative path to integrate it
#>

$templateJoinList = @()
$folders = @()
foreach ($folder in (Get-ChildItem $PSScriptRoot | Where-Object PSIsContainer -EQ $true))
{
	Copy-Item -Path $folder.FullName -Destination $staging.FullName -Recurse
	if (Test-Path (Join-Path $folder.FullName '.PSMDDependency'))
	{
		Get-Content (Join-Path $folder.FullName '.PSMDDependency') | ConvertFrom-Json | Write-Output | Select-PSFObject 'Name as Parent from folder' -KeepInputObject | ForEach-Object { $templateJoinList += $_ }
	}
	$folders += $folder.Name
}

Get-ChildItem $staging.FullName -Recurse -Force | Where-Object Name -Like "*.temppoint.*" | Remove-Item -Force
$templateJoinList = $templateJoinList | Where-Object {
	if ($_.Name -notin $folders)
	{
		Write-PSFMessage -Level Warning -Message "Broken dependency: $($_.Parent) depends on $($_.Name), but $($_.Name) does not exist"
		return $false
	}
	$true
}

$listToProcess = $templateJoinList
while ($listToProcess)
{
	$processingThisTime = $listToProcess | Where-Object Name -NotIn $listToProcess.Parent
	if ($listToProcess -and (-not $processingThisTime))
	{
		Write-PSFMessage -Level Warning -Message "Infinite loop detected, interrupting"
		break
	}
	foreach ($item in $processingThisTime)
	{
		Get-ChildItem -Path "$($staging.FullName)\$($item.Name)\*" | Where-Object Name -NotMatch '\.PSMDDependency|PSMDInvoke\.ps1|PSMDTemplate\.ps1' | ForEach-Object {
			Write-PSFMessage -Level Verbose -Message "Copying from $($item.Name): $($_.FullName) to $($item.Parent)\$($item.Path)"
			Copy-Item $_.FullName -Destination (Join-Path (Join-Path $staging.FullName $item.Parent) $item.Path) -Force -Recurse
		}
		
		# Exception to counter weird copy bug
		if ($item.Name -eq "PSFTests")
		{
			$source = "$($staging.FullName)\$($item.Name)\functions"
			$destination = (Join-Path (Join-Path $staging.FullName $item.Parent) $item.Path)
			Copy-Item -Path $source -Destination $destination -Recurse -Force
		}
	}
	$listToProcess = $listToProcess | Where-Object { $_ -notin $processingThisTime }
}

foreach ($folder in (Get-ChildItem $staging.FullName))
{
	& "$($folder.FullName)\PSMDInvoke.ps1" -Path $output.FullName
}