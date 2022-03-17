$action = {
	param (
		$Parameters
	)
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters

	# Insert implementation here
}

$params = @{
	Name        = 'þnameþ'
	Action      = $action
	Description = 'þdescriptionþ'
	Parameters  = @{
		ParameterName = 'Add Description'
	}
}

Register-PSMDBuildAction @params