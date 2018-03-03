function Get-PSMDTemplate
{
	[CmdletBinding()]
	Param (
		[string]
		$TemplateName
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ", ")" -Tag 'debug','start','param'
	}
	process
	{
	
	}
	end
	{
	
	}
}