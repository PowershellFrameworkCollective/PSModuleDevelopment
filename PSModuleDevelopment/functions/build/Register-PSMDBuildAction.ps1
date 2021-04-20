function Register-PSMDBuildAction {
	[CmdletBinding()]
	param (
		[string]
		$Name,
		
		[ScriptBlock]
		$Action,
		
		[string]
		$Description,
		
		[hashtable[]]
		$Parameters
	)
	
	process {
		$script:buildActions[$Name] = [pscustomobject]@{
			PSTypeName  = 'PSModuleDevelopment.Build.Action'
			Name	    = $Name
			Action	    = $Action
			Description = $Description
			Parameters  = $Parameters
		}
	}
}
