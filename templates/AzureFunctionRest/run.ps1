param (
	$Request,
	
	$TriggerMetadata
)


Write-Host "Trigger: þnameþ has been invoked"

$parameters = Get-RestParameter -Request $Request -Command þnameþ

try { $results = þnameþ @parameters -ErrorAction Stop }
catch {
	Write-FunctionResult -Status InternalServerError -Body $_
	$_ | Out-Host
	return
}
Write-FunctionResult -Status OK -Body $results