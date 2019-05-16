param (
	$Request,
	
	$TriggerMetadata
)

$parameters = Convert-AzureFunctionParameter -Request $Request
if ($parameters.__PSSerialize)
{
	$usePSSerialize = $true
	$parameters.Remove('__PSSerialize')
}
else { $usePSSerialize = $false }

try { $data = %functionname% @parameters }
catch
{
	Write-AzureFunctionOutput -Value "Failed to execute: $_" -Status InternalServerError
	return
}

Write-AzureFunctionOutput -Value $data -Serialize:$usePSSerialize