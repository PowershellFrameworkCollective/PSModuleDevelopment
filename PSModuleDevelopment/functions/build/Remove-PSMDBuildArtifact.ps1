function Remove-PSMDBuildArtifact
{
<#
	.SYNOPSIS
		Removes an artifact from the build pipeline.
	
	.DESCRIPTION
		Removes an artifact from the build pipeline.
		Only interacts with the PSModuleDevelopment build system.
	
	.PARAMETER Name
		Name of the artifact to remove.
	
	.EXAMPLE
		PS C:\> Remove-PSMDBuildArtifact -Name 'session'
	
		Removes the artifact 'session' from the build pipeline.
	
	.EXAMPLE
		PS C:\> Get-PSMDBuildArtifact -Tag pssession | Remove-PSMDBuildArtifact
	
		Removes all artifacts with the 'pssession' tag from the build pipeline.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Name
	)
	
	process{
		foreach ($nameString in $Name) {
			$script:buildArtifacts.Remove($nameString)
		}
	}
}
