function Get-PSMDArgumentCompleter
{
<#
	.SYNOPSIS
		Gets the registered argument completers.

    .DESCRIPTION
        This function can be used to serach the argument completers registered using either the Register-ArgumentCompleter command or created using the ArgumentCompleter attribute.

	.PARAMETER CommandName
		Filter the results to a specific command. Wildcards are supported.

	.PARAMETER ParameterName
		Filter results to a specific parameter name. Wildcards are supported.

	.EXAMPLE
		PS C:\> Get-PSMDArgumentCompleter

        Get all argument completers in use in the current PowerShell session.

#>
	[CmdletBinding()]
	Param (
        [Parameter(Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [String]
        $CommandName = '*',

        [String]
        $ParameterName = '*'
    )

	begin
	{
		$internalExecutionContext = [PSFramework.Utility.UtilityHost]::GetExecutionContextFromTLS()
		$customArgumentCompleters = [PSFramework.Utility.UtilityHost]::GetPrivateProperty('CustomArgumentCompleters', $internalExecutionContext)
	}
	process
	{
        foreach ($argumentCompleter in $customArgumentCompleters.Keys)
        {
            $name, $parameter = $argumentCompleter -split ':'

            if ($name -like $CommandName)
            {
                if ($parameter -like $ParameterName)
                {
                    [pscustomobject]@{
                        CommandName   = $name
                        ParameterName = $parameter
                        Definition    = $customArgumentCompleters[$argumentCompleter]
                    }
                }
            }
        }
    }
}