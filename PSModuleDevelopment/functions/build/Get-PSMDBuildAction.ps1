function Get-PSMDBuildAction {
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
