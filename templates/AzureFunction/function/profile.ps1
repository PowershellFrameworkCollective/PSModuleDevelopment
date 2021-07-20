# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution
# Authenticate with Azure PowerShell using MSI.
# Remove this if you are not planning on using MSI or Azure PowerShell.

if ($env:MSI_SECRET -and (Get-Module -ListAvailable Az.Accounts))
{
	Connect-AzAccount -Identity
}

# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias
# You can also define functions or aliases that can be referenced in any of your PowerShell functions.

function Write-FunctionResult {
	<#
	.SYNOPSIS
		Reports back the output / result of the function app.
	
	.DESCRIPTION
		Reports back the output / result of the function app.
	
	.PARAMETER Status
		Whether the function succeeded or not.
	
	.PARAMETER Body
		Any data to include in the response.
	
	.EXAMPLE
		PS C:\> Write-FunctionResult -Status OK -Body $newUser

		Reports success while returning the content of $newUser as output
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Net.HttpStatusCode]
        $Status,

		[AllowNull()]
        $Body
    )

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = $Status
            Body       = $Body
        })
}

function Get-RestParameterValue {
	<#
	.SYNOPSIS
		Extract the exact value of a parameter provided by the user.
	
	.DESCRIPTION
		Extract the exact value of a parameter provided by the user.
		Expects either query or body parameters from the rest call to the http trigger.
	
	.PARAMETER Request
		The request object provided as part of the function call.
	
	.PARAMETER Name
		The name of the parameter to provide.
	
	.EXAMPLE
		PS C:\> Get-RestParameterValue -Request $Request -Name Type

		Returns the value of the parameter "Type", as provided by the caller
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Request,

        [Parameter(Mandatory = $true)]
        [string]
        $Name
    )

    if ($Request.Query.$Name) {
        return $Request.Query.$Name
    }
    $Request.Body.$Name
}

function Get-RestParameter {
	<#
	.SYNOPSIS
		Parses the rest request parameters for all values matching parameters on the specified command.
	
	.DESCRIPTION
		Parses the rest request parameters for all values matching parameters on the specified command.
		Returns a hashtable ready for splatting.
		Does NOT assert mandatory parameters are specified, so command invocation may fail.
	
	.PARAMETER Request
		The original rest request object, containing the caller's information such as parameters.
	
	.PARAMETER Command
		The command to which to bind input parameters.
	
	.EXAMPLE
		PS C:\> Get-RestParameter -Request $Request -Command Get-AzUser

		Retrieves all parameters on the incoming request that match a parameter on Get-AzUser
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		$Request,

		[Parameter(Mandatory = $true)]
		[string]
		$Command
	)

	$commandInfo = Get-Command -Name $Command
	$results = @{ }
	foreach ($parameter in $commandInfo.Parameters.Keys) {
		$value = Get-RestParameterValue -Request $Request -Name $parameter
		if ($null -ne $value) { $results[$parameter] = $value }
	}
	$results
}