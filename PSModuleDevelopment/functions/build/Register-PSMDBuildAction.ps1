function Register-PSMDBuildAction {
<#
	.SYNOPSIS
		Register a new action usable in build projects.
	
	.DESCRIPTION
		Register a new action usable in build projects.
		Actions are the actual implementation logic that turns the configuration in a build project file into ... well, actions.
		Anyway, these are basically named scriptblocks with some metadata.
		This command is used to provide all the builtin actions and can be used to freely define your own actions.
		
		Whenever you use a "script" action in your build projects, consider ... would it make a good configurable option valuable for other builds?
		If so, that might just mark the birth of the next action!
	
	.PARAMETER Name
		The name of the action.
	
	.PARAMETER Action
		The actual code implementing the action.
		Each action scriptblock will receive exactly one .
	
	.PARAMETER Description
		A description explaining what the action is all about.
	
	.PARAMETER Parameters
		The parameters the action accepts.
		Provider a hashtable, with the keys being the parameter names and the values being a description of its parameter.
	
	.EXAMPLE
		PS C:\> Register-PSMDBuildAction -Name 'script' -Action $actionCode -Description 'Execute a custom scriptfile as part of your workflow' -Parameters $parameters
	
		Creates / registers the action "script".
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true)]
		[ScriptBlock]
		$Action,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Description,
		
		[Parameter(Mandatory = $true)]
		[hashtable]
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
