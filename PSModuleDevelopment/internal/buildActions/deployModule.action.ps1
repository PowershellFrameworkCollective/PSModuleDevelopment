$action = {
	param (
		$Parameters
	)

	trap {
		if ($workingDirectory) {
			Remove-Item -Path $workingDirectory -Recurse -Force -ErrorAction SilentlyContinue
		}
		throw $_
	}
	
	$rootPath = $Parameters.RootPath
	$actualParameters = $Parameters.Parameters
	
	#region Validate Input
	if (-not $actualParameters.Session) {
		throw "No Sessions specified!"
	}
	
	if ($actualParameters.Session | Where-Object State -NE Opened) {
		throw "Sessions not open!"
	}
	if ($actualParameters.Repository -and (-not (Get-PSRepository -Name $actualParameters.Repository -ErrorAction Ignore))) {
		throw "Repository $($actualParameters.Repository) not found!"
	}
	
	foreach ($module in $actualParameters.Module) {
		if ($module -notmatch '\\|/') { continue }
		
		try { $null = Resolve-PSFPath -Path $module -Provider FileSystem }
		catch { throw "Unable to resolve path: $module"}
	}
	#endregion Validate Input
	
	#region Prepare modules to transfer
	$workingDirectory = Join-Path -Path (Get-PSFPath -Name temp) -ChildPath "psmd_action_$(Get-Random)"
	$null = New-Item -Path $workingDirectory -ItemType Directory -Force -ErrorAction Stop
	
	$saveModuleParam = @{
		Path = $workingDirectory
		Repository = $actualParameters.Repository
	}
	
	foreach ($module in $actualParameters.Module) {
		if ($module -notmatch '\\|/') {
			if ($actualParameters.Repository) {
				Save-Module $module @saveModuleParam
				continue
			}
			$moduleObject = Get-Module -Name $module -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
			if (-not $moduleObject) {
				throw "Cannot find module $module!"
			}
			Copy-Item -Path $moduleObject.ModuleBase -Destination "$workingDirectory\$($moduleObject.Name)" -Recurse -Force
			continue
		}
		
		foreach ($path in Resolve-PSFPath -Path $module -Provider FileSystem) {
			if (Test-Path -LiteralPath $path -PathType Leaf) { $path = Split-Path -LiteralPath $path }
			Copy-Item -LiteralPath $path -Destination $workingDirectory -Recurse -Force
		}
	}
	#endregion Prepare modules to transfer
	
	foreach ($moduleFolder in Get-ChildItem -Path $workingDirectory) {
		if (-not $actualParameters.NoDelete) {
			Invoke-Command -Session $actualParameters.Session -ScriptBlock {
				param ($Name)
				if (-not (Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\$Name")) { return }
				Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\$Name" -Recurse -Force
			} -ArgumentList $moduleFolder.Name
		}
		foreach ($session in $actualParameters.Session) {
			Copy-Item -LiteralPath $moduleFolder.FullName -Destination "$env:ProgramFiles\WindowsPowerShell\Modules" -Recurse -Force -ToSession $session -ErrorAction Stop
		}
	}
}

$params = @{
	Name	    = 'deployModule'
	Action	    = $action
	Description = 'Deploys a module to the target computer(s)'
	Parameters  = @{
		Session    = '(mandatory) The PSRemoting sessions to deploy the module through.'
		Module	   = '(mandatory) A list of names or paths of modules to deploy. Can be used in any combination, specifying by name will use the latest version found on the local computer unless also using he "Repository" parameter to specify an alternate source.'
		Repository = 'The repository from which to download the module(s) (and any dependencies). Modules will be sourced locally if empty.'
		NoDelete   = '[bool] Whether to keep other versions of the target module on the remote machine. By default, all other versions will be deleted.'
	}
}

Register-PSMDBuildAction @params