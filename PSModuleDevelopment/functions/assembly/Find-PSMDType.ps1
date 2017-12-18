function Find-PSMDType
{
<#
	.SYNOPSIS
		Searches assemblies for types.
	
	.DESCRIPTION
		This function searches the currently imported assemblies for a specific type.
		It is not inherently limited to public types however, and can search interna just as well.
	
		Can be used to scan for dependencies, to figure out what libraries one needs for a given type and what dependencies exist.
	
	.PARAMETER Name
		Default: "*"
		The name of the type to search for.
		Accepts wildcards.
	
	.PARAMETER FullName
		Default: "*"
		The FullName of the type to search for.
		Accepts wildcards.
	
	.PARAMETER Assembly
		Default: (Get-PSMDAssembly)
		The assemblies to search. By default, all loaded assemblies are searched.
	
	.PARAMETER Public
		Whether the type to find must be public.
	
	.PARAMETER Enum
		Whether the type to find must be an enumeration.
	
	.PARAMETER Implements
		Whether the type to find must implement this interface
	
	.PARAMETER InheritsFrom
		The type must directly inherit from this type.
		Accepts wildcards.
	
	.EXAMPLE
		Find-PSMDType -Name "*String*"
	
		Finds all types whose name includes the word "String"
		(This will be quite a few)
	
	.EXAMPLE
		Find-PSMDType -InheritsFrom System.Management.Automation.Runspaces.Runspace
	
		Finds all types that inherit from the Runspace class
#>
	[CmdletBinding()]
	Param (
		[string]
		$Name = "*",
		
		[string]
		$FullName = "*",
		
		[Parameter(ValueFromPipeline = $true)]
		[System.Reflection.Assembly[]]
		$Assembly = (Get-PSMDAssembly),
		
		[switch]
		$Public,
		
		[switch]
		$Enum,
		
		[string]
		$Implements,
		
		[string]
		$InheritsFrom
	)
	
	begin
	{
		$boundEnum = Test-PSFParameterBinding -ParameterName Enum
		$boundPublic = Test-PSFParameterBinding -ParameterName Public
	}
	process
	{
		foreach ($item in $Assembly)
		{
			if ($boundPublic)
			{
				if ($Public) { $types = $item.ExportedTypes }
				else { $types = $item.GetTypes() | Where-Object IsPublic -EQ $false }
			}
			else
			{
				$types = $item.GetTypes()
			}
			
			foreach ($type in $types)
			{
				if ($type.Name -notlike $Name) { continue }
				if ($type.FullName -notlike $FullName) { continue }
				if ($Implements -and ($type.ImplementedInterfaces.Name -notcontains $Implements)) { continue }
				if ($boundEnum -and ($Enum -ne $type.IsEnum)) { continue }
				if ($InheritsFrom -and ($type.BaseType.FullName -notlike $InheritsFrom)) { continue }
				
				$type
			}
		}
	}
	end
	{
		
	}
}