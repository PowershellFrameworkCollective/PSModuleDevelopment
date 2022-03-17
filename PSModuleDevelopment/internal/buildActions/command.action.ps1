$action = {
	param (
		$Parameters
	)
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	
	#region Process Parameters
	if (-not $actualParameters.Command) {
		throw "Mandatory parameter: Command not specified"
	}
	
	if ($actualParameters.Command -is [System.Management.Automation.ScriptBlock]) {
		$scriptblock = $actualParameters.Command
	}
	else {
		try { $scriptblock = [scriptblock]::Create($actualParameters.Command) }
		catch {
			throw "Error parsing command '$($actualParameters.Command)' : $_"
		}
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
		$inSession = foreach ($sessionInput in $actualParameters.InSession) {
			if ($sessionInput -is [System.Management.Automation.Runspaces.PSSession]) {
				$sessionInput
				continue
			}
			$artifactObject = Get-PSMDBuildArtifact -Name $sessionInput
			if ($artifactObject.Value -is [System.Management.Automation.Runspaces.PSSession]) {
				$artifactObject.Value
				continue
			}
			if (-not $artifactObject) { throw "Artifact for parameter InSession not found: $($sessionInput)" }
			throw "Artifact for parameter InSession ($($sessionInput)) is not a pssession!"
		}
	}
	#endregion Process Parameters
	
	#region Execution
	$invokeParam = @{
		ScriptBlock	 = $scriptblock
		ArgumentList = $actualArguments
	}
	if ($inSession) { $invokeParam.Session = $inSession }
	try { Invoke-Command @invokeParam -ErrorAction Stop }
	catch { throw }
	#endregion Execution
}

$params = @{
	Name	    = 'command'
	Action	    = $action
	Description = 'Execute a scriptblock'
	Parameters  = @{
		Command		 = '(mandatory) Scriptcode to run'
		ArgumentList = 'Any number of arguments to pass to the command. To insert artifacts, specify a string with the special notation "%!ArtifactName!%"'
		InSession    = 'Execute the scriptfile in the target PSSession. Either provide a full session object or an artifact name pointing at one.'
	}
}

Register-PSMDBuildAction @params