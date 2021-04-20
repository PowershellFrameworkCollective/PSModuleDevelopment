function Get-PSMDBuildArtifact {
<#
	.SYNOPSIS
		Retrieve an artifact during a build project's execution.
	
	.DESCRIPTION
		Retrieve an artifact during a build project's execution.
		These artifacts are usually created during such an execution and discarded once completed.
	
	.PARAMETER Name
		The name by which to search for artifacts.
		Defaults to '*'
	
	.PARAMETER Tag
		Search for artifacts by tag.
		Artifacts can receive tag for better categorization.
		When specifying multiple tags, any artifact containing at least one of them will be returned.
	
	.EXAMPLE
		PS C:\> Get-PSMDBuildArtifact
	
		List all available artifacts.
	
	.EXAMPLE
		PS C:\> Get-PSMDBuildArtifact -Name ReleasePath
	
		Returns the artifact named "ReleasePath"
	
	.EXAMPLE
		PS C:\> Get-PSMDBuildArtifact -Tag pssession
	
		Returns all artifacts with the tag "pssession"
#>
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
