$action = {
	param (
		$Parameters
	)
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	
	if ($actualParameters.All) {
		foreach ($artifact in Get-PSMDBuildArtifact -Tag pssession) {
			try {
				$artifact.Value | Remove-PSSession -ErrorAction Stop
				Remove-PSMDBuildArtifact -Name $artifact.Name
			}
			catch {
				throw "Failed to remove PSSession artifact $($artifact.Name) to $($artifact.Value) | $_"
			}
		}
	}
	elseif ($actualParameters.ArtifactName) {
		$artifact = Get-PSMDBuildArtifact -Name $actualParameters.ArtifactName
		if ($artifact) {
			try {
				$artifact.Value | Remove-PSSession -ErrorAction Stop
				Remove-PSMDBuildArtifact -Name $artifact.Name
			}
			catch {
				throw "Failed to remove PSSession artifact $($artifact.Name) to $($artifact.Value) | $_"
			}
		}
	}
	else {
		throw "Invalid parameters! Specify either 'All' or 'ArtifactName' in step definition."
	}
}

$params = @{
	Name	    = 'remove-pssession'
	Action	    = $action
	Description = 'Removes a PSSession that was previously established with the new-pssession action'
	Parameters  = @{
		ArtifactName = 'The name under which to publish the session as an artifact'
		All		     = 'Whether all PSSession artifacts should be removed'
	}
}

Register-PSMDBuildAction @params