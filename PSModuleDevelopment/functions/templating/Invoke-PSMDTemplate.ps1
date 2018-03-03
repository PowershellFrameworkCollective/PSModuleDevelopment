function Invoke-PSMDTemplate
{
	[CmdletBinding()]
	param (
		[string]
		$TemplateName,
		
		[string]
		$Path,
		
		[string]
		$Name,
		
		[switch]
		$NoFolder,
		
		[switch]
		$Raw
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