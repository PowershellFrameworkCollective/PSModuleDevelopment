function Search-PSMDPropertyValue
{
<#
	.SYNOPSIS
		Recursively search an object for property values.
	
	.DESCRIPTION
		Recursively search an object for property values.
		This can be useful to determine just where an object stores a given piece of information in scenarios, where objects either have way too many properties or a deeply nested data structure.
	
	.PARAMETER Object
		The object to search.
	
	.PARAMETER Value
		The value to search for.
	
	.PARAMETER Match
		Search by comparing with regex, rather than equality comparison.
	
	.PARAMETER Depth
		Default: 3
		How deep should the query recurse.
		The deeper, the longer it can take on deeply nested objects.
	
	.EXAMPLE
		PS C:\> Get-Mailbox Max.Mustermann | Search-PSMDPropertyValue -Object 'max.mustermann@contoso.com' -Match
	
		Searches all properties on the mailbox of Max Mustermann for his email address.
#>
	[CmdletBinding()]
	param (
		[AllowNull()]
		$Value,
		
		[Parameter(ValueFromPipeline = $true, Mandatory = $true)]
		$Object,
		
		[switch]
		$Match,
		
		[int]
		$Depth = 3
	)
	
	begin
	{
		function Search-Value
		{
			[CmdletBinding()]
			param (
				$Object,
				
				$Value,
				
				[bool]
				$Match,
				
				[int]
				$Depth,
				
				[string[]]
				$Elements,
				
				$InputObject
			)
			
			$path = $Elements -join "."
			Write-PSFMessage -Level Verbose -Message "Processing $path"
			
			foreach ($property in $Object.PSObject.Properties)
			{
				if ($path) { $tempPath = $path, $property.Name -join "." }
				else { $tempPath = $property.Name }
				if ($Match)
				{
					if ($property.Value -match $Value)
					{
						New-Object PSModuleDevelopment.Utility.PropertySearchResult($property.Name, $Elements, $property.Value, $InputObject)
					}
				}
				else
				{
					if ($Value -eq $property.Value)
					{
						New-Object PSModuleDevelopment.Utility.PropertySearchResult($property.Name, $Elements, $property.Value, $InputObject)
					}
				}
				
				if ($Elements.Count -lt $Depth)
				{
					$newItems = New-Object System.Object[]($Elements.Count)
					$Elements.CopyTo($newItems, 0)
					$newItems += $property.Name
					Search-Value -Object $property.Value -Value $Value -Match $Match -Depth $Depth -Elements $newItems -InputObject $InputObject
				}
			}
		}
	}
	
	process
	{
		Search-Value -Object $Object -Value $Value -Match $Match.ToBool() -Depth $Depth -Elements @() -InputObject $Object
	}
}