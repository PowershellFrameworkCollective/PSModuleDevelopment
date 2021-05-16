$action = {
	param (
		$Parameters
	)
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	$actualParameters = Resolve-PSMDBuildStepParameter -Parameters $actualParameters -FromArtifacts $Parameters.ParametersFromArtifacts -ProjectName $Parameters.ProjectName -StepName $Parameters.StepName
	
	if (-not $actualParameters.Path) {
		throw "Invalid parameters! Specify a Path to delete."
	}
	
	$paths = $actualParameters.Path -replace '%ProjectRoot%', $rootPath
	$deleteParam = @{ }
	if ($actualParameters.Recurse) { $deleteParam.Recurse = $true }
	if ($actualParameters.Force) { $deleteParam.Force = $true }
	
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
	
	if ($inSession) {
		$failed = Invoke-Command -Session $inSession -ScriptBlock {
			param ($DeleteParam, $Paths)
			
			foreach ($path in $Paths) {
				if (-not (Get-Item -Path $path -Force -ErrorAction Ignore)) { continue }
				try { Remove-Item @DeleteParam -Path $path -ErrorAction Stop }
				catch { return $_ }
			}
		} -ArgumentList $deleteParam, $paths
		if ($failed) {
			throw $failed
		}
	}
	
	foreach ($path in $paths) {
		if (-not (Get-Item -Path $path -Force -ErrorAction Ignore)) { continue }
		try { Remove-Item @DeleteParam -Path $path -ErrorAction Stop }
		catch { throw }
	}
}

$params = @{
	Name	    = 'remove-item'
	Action	    = $action
	Description = 'Removes files or folders'
	Parameters  = @{
		Path	    = '(mandatory) Path(s) to the item(s) to delete. Use "%ProjectRoot%" to reference to the root path containing the build file.'
		InSession   = 'Artifact Name of the PSSession within which to execute the deletion'
		Recurse	    = 'Whether to delete child items'
		Force	    = 'Whether to use force'
	}
}

Register-PSMDBuildAction @params