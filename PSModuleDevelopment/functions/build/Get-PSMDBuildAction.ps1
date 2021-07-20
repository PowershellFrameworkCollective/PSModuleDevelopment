function Get-PSMDBuildAction {
<#
	.SYNOPSIS
		Get a list of registered build actions.
	
	.DESCRIPTION
		Get a list of registered build actions.
		Actions are the scriptblocks that are used to execute the build logic when running Invoke-PSMDBuildProject.
	
	.PARAMETER Name
		The name by which to filter the actions returned.
		Defaults to '*'
	
	.EXAMPLE
		PS C:\> Get-PSMDBuildAction
	
		Get a list of all registered build actions.
#>
	[CmdletBinding()]
	param (
		[PsfArgumentCompleter('PSModuleDevelopment.Build.Action')]
		[string]
		$Name = '*'
	)
	
	process {
		$script:buildActions.Values | Where-Object Name -Like $Name
	}
}
