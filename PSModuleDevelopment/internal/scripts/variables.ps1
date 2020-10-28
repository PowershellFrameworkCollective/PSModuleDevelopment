if ($IsLinux -or $IsMacOs)
{
	# Defaults to the first value in $Env:XDG_CONFIG_DIRS on Linux or MacOS (or $HOME/.local/share/)
	$fileUserShared = @($Env:XDG_CONFIG_DIRS -split ([IO.Path]::PathSeparator))[0]
	if (-not $fileUserShared) { $fileUserShared = Join-Path $HOME .local/share/ }
	
	$path_FileUserShared = Join-Path (Join-Path $fileUserShared $psVersionName) "PSFramework"
}
else
{
	# Defaults to $Env:AppData on Windows
	$path_FileUserShared = Join-Path $Env:AppData "$psVersionName\PSFramework\Config"
	if (-not $Env:AppData) { $path_FileUserShared = Join-Path ([Environment]::GetFolderPath("ApplicationData")) "$psVersionName\PSFramework\Config" }
}