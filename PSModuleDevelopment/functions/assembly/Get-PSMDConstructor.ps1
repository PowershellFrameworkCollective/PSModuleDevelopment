function Get-PSMDConstructor
{
	<#
		.SYNOPSIS
			Returns information on the available constructors of a type.
		
		.DESCRIPTION
			Returns information on the available constructors of a type.
			Accepts any object as pipeline input:
			- if it's a type, it will retrieve its constructors.
			- If it's not a type, it will retrieve the constructor from the type of object passed
	
			Will not duplicate constructors if multiple objects of the same type are passed.
			In order to retrieve the constructor of an array, wrap it into another array.
		
		.PARAMETER InputObject
			The object the constructor of which should be retrieved.
		
		.EXAMPLE
			Get-ChildItem | Get-PSMDConstructor
	
			Scans all objects in the given path, than tries to retrieve the constructor for each kind of object returned
			(generally, this will return the constructors for file and folder objects)
	
		.EXAMPLE
			Get-PSMDConstructor $result
	
			Returns the constructors of objects stored in $result
	#>
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject
	)
	
	begin
	{
		$processedTypes = @()
	}
	process
	{
		foreach ($item in $InputObject)
		{
			if ($null -eq $item) { continue }
			if ($item -is [System.Type]) { $type = $item }
			else { $type = $item.GetType() }
			
			if ($processedTypes -contains $type) { continue }
			
			foreach ($constructor in $type.GetConstructors())
			{
				New-Object PSModuleDevelopment.PsmdAssembly.Constructor($constructor)
			}
			
			$processedTypes += $type
		}
	}
	end
	{
		
	}
}