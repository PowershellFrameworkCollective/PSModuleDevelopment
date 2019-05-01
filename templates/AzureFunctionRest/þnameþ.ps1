function þnameþ
{
	<#
		.SYNOPSIS
			Insert Synopsis

		.DESCRIPTION
			Insert Description

		.PARAMETER Request
			Contains the Request Information the Azure Function was called with.
			Effectively the parameters.

		.PARAMETER TriggerMetadata
			Azure Functions Specific Vodoo. Don't touch unless you know what you do.

		.EXAMPLE
			PS C:\> Invoke-RestMethod '<insert function uri>'

			Invokes the Azure function without any parameter.
	#>
	[CmdletBinding()]
	param (
		$Request,
		
		$TriggerMetadata
	)
	
	begin
	{
		#region Convert input parameters from Azure Functions
		if ($env:Functions_EXTENSION_VERSION)
		{
			$PSBoundParameters.Clear()
			$PSBoundParameters = Convert-AzureFunctionParameter -Request $Request
		}
		#endregion Convert input parameters from Azure Functions
	}
	process
	{
		if ($failed)
		{
			Write-AzureFunctionOutput -Value 'Failed to execute successfully!' -Status InternalServerError
			return
		}
	}
	end
	{
		Write-AzureFunctionOutput -Value $results -Serialize
		return
	}
}
