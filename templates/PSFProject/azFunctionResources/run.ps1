param (
	$Request,
	
	$TriggerMetadata
)

$parameters = Convert-AzureFunctionParameter -Request $Request

try { $data = %functionname% @parameters }
catch
{
	Write-AzureFunctionOutput -Value "Failed to execute: $_" -Status InternalServerError
	return
}

# This is automatically updated by the build script if there is a custom override for function
$serialize = $true

Write-AzureFunctionOutput -Value $data -Serialize:$serialize