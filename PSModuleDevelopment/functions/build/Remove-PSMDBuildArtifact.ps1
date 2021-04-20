function Remove-PSMDBuildArtifact
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string[]]
		$Name
	)
	
	process{
		foreach ($nameString in $Name) {
			$script:buildArtifacts.Remove($nameString)
		}
	}
}
