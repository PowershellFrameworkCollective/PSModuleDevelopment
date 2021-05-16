$action = {
	param (
		$Parameters
	)
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	$actualParameters = Resolve-PSMDBuildStepParameter -Parameters $actualParameters -FromArtifacts $Parameters.ParametersFromArtifacts -ProjectName $Parameters.ProjectName -StepName $Parameters.StepName
	
	#region Utility Functions
	function ConvertTo-PSSession {
		[CmdletBinding()]
		param (
			[Parameter(ValueFromPipeline = $true)]
			$InputObject
		)
		process {
			if ($InputObject -is [System.Management.Automation.Runspaces.PSSession]) {
				return $InputObject
			}
			$artifactValue = (Get-PSMDBuildArtifact -Name $InputObject).Value
			if ($artifactValue -is [System.Management.Automation.Runspaces.PSSession]) {
				return $artifactValue
			}
		}
	}
	#endregion Utility Functions
	
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
		$fromSession = $actualParameters.FromSession | ConvertTo-PSSession
		if (-not $fromSession) {
			throw "FromSession $($actualParameters.FromSession) not found!"
		}
		$copyParam.FromSession = $fromSession
	}
	if ($actualParameters.ToSession) {
		$toSession = $actualParameters.ToSession | ConvertTo-PSSession
		if (-not $toSession) {
			throw "ToSession $($actualParameters.ToSession) not found!"
		}
		$copyParam.ToSession = $toSession
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