$action = {
	param (
		$Parameters
	)
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	
	#region Process Parameters
	if (-not $actualParameters.Path) {
		throw "Mandatory parameter: Path not specified"
	}
	
	$scriptPath = $actualParameters.Path -replace '%ProjectRoot%', $rootPath
	
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
	
	$inSession = $null
	if ($actualParameters.InSession) {
		if ($actualParameters.InSession -is [System.Management.Automation.Runspaces.PSSession]) {
			$inSession = $actualParameters.InSession
		}
		$artifactObject = Get-PSMDBuildArtifact -Name $actualParameters.InSession
		if (-not $artifactObject) { throw "Artifact for parameter InSession not found: $($actualParameters.InSession)" }
		if ($artifactObject.Value -isnot [System.Management.Automation.Runspaces.PSSession]) { throw "Artifact for parameter InSession ($($actualParameters.InSession)) is not a pssession!" }
		$inSession = $artifactObject.Value
	}
	#endregion Process Parameters
	
	#region Execution
	$invokeParam = @{
		FilePath	 = $scriptPath
		ArgumentList = $actualArguments
	}
	if ($inSession) { $invokeParam.Session = $inSession }
	try { Invoke-Command @invokeParam -ErrorAction Stop }
	catch { throw }
	#endregion Execution
}

$params = @{
	Name	    = 'script'
	Action	    = $action
	Description = 'Execute a scriptfile'
	Parameters  = @{
		Path		 = '(mandatory) Path to the scriptfile to run. Use %ProjectRoot% to reference the same folder the build action file is stored in.'
		ArgumentList = 'Any number of arguments to pass to the scripts. To insert artifacts, specify a string with the special notation "%!ArtifactName!%"'
		InSession    = 'Execute the scriptfile in the target PSSession. Either provide a full session object or an artifact name pointing at one.'
	}
}

Register-PSMDBuildAction @params