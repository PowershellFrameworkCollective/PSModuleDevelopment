$action = {
	param (
		$Parameters
	)
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	$actualParameters = Resolve-PSMDBuildStepParameter -Parameters $actualParameters -ProjectName $Parameters.ProjectName -StepName $Parameters.StepName
	
	if (-not $actualParameters.ArtifactName) { throw "No ArtifactName specified! Unable to publish remoting session for build." }
	if (-not ($actualParameters.VMName -or $actualParameters.ComputerName)) { throw "Neither ComputerName nor VMName specified, unable to connect to nothing!" }
	if ($actualParameters.VMName -and $actualParameters.ComputerName) { throw "Both ComputerName and VMName specified, unable to connect to both at once!" }
	
	$credential = $null
	if ($actualParameters.CredentialPath) {
		$path = $actualParameters.CredentialPath -replace '%ProjectRoot%', $rootPath
		try { $credential = Import-PSFClixml -Path $path -ErrorAction Stop }
		catch { throw "Error accessing credentials from $path : $_" }
	}
	
	$paramNewPSSession = @{ }
	if ($actualParameters.VMName) { $paramNewPSSession.VMName = $actualParameters.VMName }
	if ($actualParameters.ComputerName) { $paramNewPSSession.ComputerName = $actualParameters.ComputerName }
	if ($credential) { $paramNewPSSession.Credential = $credential }
	
	try { $session = New-PSSession @paramNewPSSession -ErrorAction Stop }
	catch { throw "Error establishing PS Remoting session: $_" }
	
	Publish-PSMDBuildArtifact -Name $actualParameters.ArtifactName -Value $session -Tag pssession
}

$params = @{
	Name	    = 'new-pssession'
	Action	    = $action
	Description = 'Establish a PSSession to a target computer and provide it as an artifact'
	Parameters  = @{
		ComputerName   = 'The Computer to connect to'
		VMName		   = 'The virtual machine to which to connect to via the HyperV VM Bus'
		CredentialPath = 'The path to the credentials to use for the connection. Use %ProjectRoot% to insert the folder path to where the buildfile is located'
		ArtifactName   = '(mandatory) The name under which to publish the session as an artifact'
	}
}

Register-PSMDBuildAction @params