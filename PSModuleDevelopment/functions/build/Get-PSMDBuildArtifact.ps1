function Get-PSMDBuildArtifact {
	[CmdletBinding()]
	param (
		[string]
		$Name = '*',
		
		[string[]]
		$Tag
	)
	
	process {
		$script:buildArtifacts.Values | Where-Object Name -Like $Name | Where-Object {
			if (-not $Tag) { return $true }
			foreach ($tagName in $Tag) {
				if ($_.Tags -contains $Tag) { return $true }
			}
			return $false
		}
	}
}
