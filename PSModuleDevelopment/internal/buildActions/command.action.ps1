$action = {
	param (
		$Parameters
	)
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	$actualParameters = Resolve-PSMDBuildStepParameter -Parameters $actualParameters -FromArtifacts $Parameters.ParametersFromArtifacts -ProjectName $Parameters.ProjectName -StepName $Parameters.StepName
	
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