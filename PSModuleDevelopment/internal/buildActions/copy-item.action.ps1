$action = {
	param (
		$Parameters
	)
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	$actualParameters = Resolve-PSMDBuildStepParameter -Parameters $actualParameters -ProjectName $Parameters.ProjectName -StepName $Parameters.StepName
	
	if (-not ($actualParameters.Path -and $actualParameters.Destination)) {
		throw "Invalid parameters! Specify both Path and Destination."
	}
	
	$paths = $actualParameters.Path -replace '%ProjectRoot%', $rootPath
	$copyParam = @{
		Destination = $actualParameters.Destination -replace '%ProjectRoot%', $rootPath
	}
	if ($actualParameters.Recurse) { $copyParam.Recurse = $true }
	if ($actualParameters.Force) { $copyParam.Force = $true }
	if ($actualParameters.FromSession) {
		$artifact = Get-PSMDBuildArtifact -Name $actualParameters.FromSession
		if (-not $artifact) {
			throw "FromSession $($actualParameters.FromSession) not found!"
		}
		$copyParam.FromSession = $artifact.Value
	}
	if ($actualParameters.ToSession) {
		$artifact = Get-PSMDBuildArtifact -Name $actualParameters.ToSession
		if (-not $artifact) {
			throw "ToSession $($actualParameters.ToSession) not found!"
		}
		$copyParam.ToSession = $artifact.Value
	}
	foreach ($path in $paths) {
		try { Copy-Item @copyParam -Path $path -ErrorAction Stop }
		catch { throw }
	}
}

$params = @{
	Name	    = 'copy-item'
	Action	    = $action
	Description = 'Copies files & folders from A to B'
	Parameters  = @{
		Path	    = '(mandatory) Path(s) to copy. Use "%ProjectRoot%" to reference to the root path containing the build file.'
		Destination = '(mandatory) Path to copy to. Use "%ProjectRoot%" to reference to the root path containing the build file.'
		FromSession = 'Artifact Name of the PSSession to copy from.'
		ToSession   = 'Artifact Name of the PSSession to copy to.'
		Recurse	    = 'Whether to copy child items'
		Force	    = 'Whether to use force (Remove destination items)'
	}
}

Register-PSMDBuildAction @params