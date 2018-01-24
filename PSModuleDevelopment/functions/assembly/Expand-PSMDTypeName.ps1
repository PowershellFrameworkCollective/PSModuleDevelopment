function Expand-PSMDTypeName
{
<#
	.SYNOPSIS
		Returns the full name of the input object's type, as well as the name of the types it inherits from, recursively until System.Object.
	
	.DESCRIPTION
		Returns the full name of the input object's type, as well as the name of the types it inherits from, recursively until System.Object.
	
	.PARAMETER InputObject
		The object whose typename to expand.
	
	.EXAMPLE
		PS C:\> Expand-PSMDTypeName -InputObject "test"
	
		Returns the typenames for the string test ("System.String" and "System.Object")
#>
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject
	)
	
	process
	{
		foreach ($item in $InputObject)
		{
			if ($null -eq $item) { continue }
			
			$type = $item.GetType()
			if ($type.FullName -eq "System.RuntimeType") { $type = $item }
			
			$type.FullName
			
			while ($type.FullName -ne "System.Object")
			{
				$type = $type.BaseType
				$type.FullName
			}
		}
	}
}