param (
	[string]
	$Repository = 'PSGallery',

	[string]
	$AppRg,

	[string]
	$AppName
)
$workingDirectory = Split-Path $PSScriptRoot
$config = Import-PowerShellDataFile -Path "$PSScriptRoot\build.config.psd1"

# Prepare output path and copy function folder
Remove-Item -Path "$workingDirectory/publish" -Recurse -Force -ErrorAction Ignore
$buildFolder = New-Item -Path $workingDirectory -Name 'publish' -ItemType Directory -Force -ErrorAction Stop
Copy-Item -Path "$workingDirectory/function/*" -Destination $buildFolder.FullName -Recurse -Force

# Process Dependencies
$requiredModules = (Import-PowerShellDataFile -Path "$workingDirectory/þnameþ/þnameþ.psd1").RequiredModules
foreach ($module in $requiredModules) {
	Save-Module -Name $module -Path "$($buildFolder.FullName)/modules" -Force -Repository $Repository
}

# Process Function Module
Copy-Item -Path "$workingDirectory/þnameþ" -Destination "$($buildFolder.FullName)/modules" -Force -Recurse
$commands = Get-ChildItem -Path "$($buildFolder.FullName)/modules/þnameþ/Functions" -Recurse -Filter *.ps1 | ForEach-Object BaseName
Update-ModuleManifest -Path "$($buildFolder.FullName)/modules/þnameþ/þnameþ.psd1" -FunctionsToExport $commands

# Generate Http Trigger
$httpCode = Get-Content -Path "$PSScriptRoot\functionHttp\run.ps1" | Join-String -Separator "`n"
$httpConfig = Get-Content -Path "$PSScriptRoot\functionHttp\function.json" | Join-String -Separator "`n"
foreach ($command in Get-ChildItem -Path "$workingDirectory\þnameþ\functions\httpTrigger" -Recurse -File -Filter *.ps1) {
	$authLevel = $config.HttpTrigger.AuthLevel
	if ($config.HttpTrigger.AuthLevelOverrides.$($command.BaseName)) {
		$authLevel = $config.HttpTrigger.AuthLevelOverrides.$($command.BaseName)
	}
	$methods = $config.HttpTrigger.Methods
	if ($config.HttpTrigger.MethodOverrides.$($command.BaseName)) {
		$methods = $config.HttpTrigger.MethodOverrides.$($command.BaseName)
	}
	$endpointFolder = New-Item -Path $buildFolder.FullName -Name $command.BaseName -ItemType Directory
	$httpCode -replace '%COMMAND%',$command.BaseName | Set-Content -Path "$($endpointFolder.FullName)\run.ps1"
	$httpConfig -replace '%AUTHLEVEL%', $authLevel -replace '%METHODS%', ($methods -join '", "') | Set-Content -Path "$($endpointFolder.FullName)\function.json"
}

# Generate Timer Trigger
$timerCode = Get-Content -Path "$PSScriptRoot\functionTimer\run.ps1" | Join-String -Separator "`n"
$timerConfig = Get-Content -Path "$PSScriptRoot\functionTimer\function.json" | Join-String -Separator "`n"
foreach ($command in Get-ChildItem -Path "$workingDirectory\þnameþ\functions\timerTrigger" -Recurse -File -Filter *.ps1) {
	$schedule = $config.TimerTrigger.Schedule
	if ($config.TimerTrigger.ScheduleOverrides.$($command.BaseName)) {
		$schedule = $config.TimerTrigger.ScheduleOverrides.$($command.BaseName)
	}
	$endpointFolder = New-Item -Path $buildFolder.FullName -Name $command.BaseName -ItemType Directory
	$timerCode -replace '%COMMAND%',$command.BaseName | Set-Content -Path "$($endpointFolder.FullName)\run.ps1"
	$timerConfig -replace '%SCHEDULE%', $schedule | Set-Content -Path "$($endpointFolder.FullName)\function.json"
}

# Package & Cleanup
Remove-Item -Path "$workingDirectory/Function.zip" -Recurse -Force -ErrorAction Ignore
Compress-Archive -Path "$($buildFolder.FullName)/*" -DestinationPath "$workingDirectory/Function.zip"
Remove-Item -Path $buildFolder.FullName -Recurse -Force -ErrorAction Ignore

if ($AppRg -and $AppName) {
	Write-Host "Publishing Function App to $AppRg/$AppName"
	Publish-AzWebApp -ResourceGroupName $AppRG -Name $AppName -ArchivePath "$workingDirectory/Function.zip" -Confirm:$false -Force
}