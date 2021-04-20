function Publish-PSMDBuildArtifact {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true)]
		[AllowNull()]
		$Value,
		
		[string[]]
		$Tag = @()
	)
	
	process {
		$script:buildArtifacts[$Name] = [pscustomobject]@{
			PSTypeName = 'PSModuleDevelopment.Build.Artifact'
			Name	   = $Name
			Value	   = $Value
			Tags	   = $Tag
		}
	}
}
