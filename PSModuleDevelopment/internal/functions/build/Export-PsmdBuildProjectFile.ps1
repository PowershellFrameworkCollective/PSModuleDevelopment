function Export-PsmdBuildProjectFile {
<#
	.SYNOPSIS
		Exports a build project object to file.
	
	.DESCRIPTION
		Exports a build project object to file.
		Strips out all superfluous properties on steps to improve readability of output.
	
	.PARAMETER OutPath
		The path to write the file to.
	
	.PARAMETER ProjectObject
		The build project to export.
	
	.EXAMPLE
		PS C:\> $projectObject | Export-PsmdBuildProjectFile -OutPath $outPath
	
		Exports the specified build project object to file.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$OutPath,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		$ProjectObject
	)
	
	process {
		$steps = foreach ($step in $ProjectObject.Steps) {
			$newStep = $step | ConvertTo-PSFHashtable -Include Name, Weight, Action
			if ($step.Dependency) { $newStep.Dependency = $step.Dependency }
			if ($step.Parameters) {
				$parameters = $step.Parameters | ConvertTo-PSFHashtable
				if ($parameters.Count -gt 0) { $newStep.Parameters = $parameters }
			}
			if ($step.Condition -and $step.ConditionSet) {
				$newStep.Condition = $step.Condition
				$newStep.ConditionSet = $step.ConditionSet
			}
			[PSCustomObject]$newStep
		}
		$ProjectObject.Steps = $steps | Sort-Object Weight
		$ProjectObject | ConvertTo-Json -Depth 10 | Set-Content -Path $OutPath -Encoding UTF8 -ErrorAction Stop
	}
}