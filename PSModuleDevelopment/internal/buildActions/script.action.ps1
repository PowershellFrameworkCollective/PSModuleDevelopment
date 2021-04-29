$action = {
    param (
        $Parameters
    )
	
    $rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	$actualParameters = Resolve-PSMDBuildStepParameter -Parameters $actualParameters -ProjectName $Parameters.ProjectName -StepName $Parameters.StepName
	
	if (-not $actualParameters.Path) {
		throw "Mandatory parameter: Path not specified"
	}
	
	if ($actualParameters.Path -notlike '%!*!%') {
		$scriptPath = $actualParameters.Path -replace '%ProjectRoot%', $rootPath
	}
	else {
		$artifactName = $actualParameters.Path -replace '^%!(.+)!%$', '$1'
		$artifactObject = Get-PSMDBuildArtifact -Name $artifactName
		if (-not $artifactObject) { throw "Artifact not found: $artifactName" }
		$scriptPath = $artifactObject.Value
	}
	
	if (-not (Test-Path $scriptPath)) {
		throw "Cannot find resolved script path: $scriptPath"
	}
	
	$actualArguments = foreach ($argument in $actualParameters.ArgumentList) {
		if ($argument -isnot [string]) {
			$argument
			continue
		}
		if ($argument -notlike '%!*!%') {
			$argument
			continue
		}
		$artifactName = $argument -replace '^%!(.+)!%$', '$1'
		$artifactObject = Get-PSMDBuildArtifact -Name $artifactName
		if (-not $artifactObject) { throw "Artifact for arguments not found: $artifactName" }
		$artifactObject.Value
	}
	
	try { Invoke-Command -FilePath $scriptPath -ArgumentList $actualArguments -ErrorAction Stop }
	catch { throw }
}

$params = @{
    Name        = 'script'
    Action      = $action
    Description = 'Execute a scriptfile'
    Parameters  = @{
        Path = '(mandatory) Path to the scriptfile to run. Use %ProjectRoot% to reference the same folder the build action file is stored in. To insert an artifact, wrap its name in both percent and exclamation-mark symbols like this: "%!ArtifactName!%"'
		ArgumentList = 'Any number of arguments to pass to the scripts. To insert artifacts, specify a string with the special notation "%!ArtifactName!%"'
    }
}

Register-PSMDBuildAction @params