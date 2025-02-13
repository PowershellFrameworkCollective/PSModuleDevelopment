param (
	$EventGridEvent,
	
	$TriggerMetadata
)


Write-Host "Trigger: %COMMAND% has been invoked"

$parameters = Get-RestParameter -Request $Request -Command %COMMAND%

try {
	$results = %COMMAND% @parameters -ErrorAction Stop
}
catch {
	$_ | Out-String | ForEach-Object {
		foreach ($line in ($_ -split "`n")) {
			Write-Warning $line
		}
	}
	Write-FunctionResult -Status InternalServerError -Body "$_"
	return
}
Write-FunctionResult -Status OK -Body $results