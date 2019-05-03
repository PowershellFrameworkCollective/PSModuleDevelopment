function Convert-AzureFunctionParameter
{
<#
	.SYNOPSIS
		Extracts the parameters passed into the rest method.
	
	.DESCRIPTION
		Extracts the parameters passed into the rest method of an Azure Function.
		Returns a hashtable, similar to what would be found on a $PSBoundParameters variable.
	
	.PARAMETER Request
		The request to process
	
	.EXAMPLE
		PS C:\> Convert-AzureFunctionParameter -Request $request
	
		Converts the $request object into a regular hashtable.
#>
	[CmdletBinding()]
	param (
		$Request
	)
	
	$parameters = @{ }
	
	foreach ($key in $Request.Query.Keys)
	{
		# Do NOT include the authentication key
		if ($key -eq 'code') { continue }
		$parameters[$key] = $Request.Query.$key
	}
	foreach ($key in $Request.Body.Keys)
	{
		$parameters[$key] = $Request.Body.$key
	}
	
	if (($parameters.Count -eq 1) -and ($parameters.__SerializedParameters))
	{
		return $parameters.__SerializedParameters | ConvertFrom-PSFClixml
	}
	
	$parameters
}