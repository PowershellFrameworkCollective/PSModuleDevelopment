<#
This is the globl profile file for the Azure Function.
This file will have been executed first, before any function runs.
Use this to create a common execution environment,
but keep in mind that the profile execution time is added to the function startup time for ALL functions.
#>

$global:functionStatusCode = [System.Net.HttpStatusCode]::OK
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
	
	$parameters
}

function Set-AzureFunctionStatus
{
<#
	.SYNOPSIS
		Sets the return status of the function.
	
	.DESCRIPTION
		Sets the return status of the function.
		By default, the status is "OK"
	
	.PARAMETER Status
		Set the HTTP status for the return from Azure Functions.
		Any status other than OK will cause a terminating error if run outside of Azure Functions.
	
	.EXAMPLE
		PS C:\> Set-AzureFunctionStatus -Status BadRequest
	
		Updates the status to say "BadRequest"
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[System.Net.HttpStatusCode]
		$Status
	)
	
	$global:functionStatusCode = $Status
}

function Write-AzureFunctionOutput
{
<#
	.SYNOPSIS
		Write output equally well from Azure Functions or locally.
	
	.DESCRIPTION
		Write output equally well from Azure Functions or locally.
		When calling this command, call return straight after it.
		Use Write-AzureFunctionStatus first if an error should be returned, then specify an error text here.
	
	.PARAMETER Value
		The value data to return.
		Either an error message
	
	.PARAMETER Serialize
		Return the output object as compressed clixml string.
		You can use ConvertFrom-PSFClixml to restore the object on the recipient-side.
	
	.EXAMPLE
		PS C:\> Write-AzureFunctionOutput -Value $result
	
		Writes the content of $result as output.
	
	.EXAMPLE
		PS C:\> Write-AzureFunctionOutput -Value $result -Serialize
	
		Writes the content of $result as output.
		If called from Azure Functions, it will convert the output as compressed clixml string.
		
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Value,
		
		[switch]
		$Serialize,
		
		[System.Net.HttpStatusCode]
		$Status
	)
	
	if ($PSBoundParameters.ContainsKey('Status'))
	{
		Set-AzureFunctionStatus -Status $Status
	}
	
	# If not in function, just return value
	if (-not $env:Functions_EXTENSION_VERSION)
	{
		if ($global:functionStatusCode -ne [System.Net.HttpStatusCode]::OK)
		{
			throw $Value
		}
		return $Value
	}
	
	if ($Serialize)
	{
		$Value = $Value | ConvertTo-PSFClixml
	}
	
	Push-OutputBinding -Name Response -Value (
		[HttpResponseContext]@{
			StatusCode = $global:functionStatusCode
			Body	   = $Value
		}
	)
}