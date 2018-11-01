function Search-PSMDPropertyValue
{
	[CmdletBinding()]
	param (
		$Object,
		
		$Value,
		
		[switch]
		$Match,
		
		[int]
		$Depth = 3
	)
	
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
			$Elements
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
					[PSCustomObject]@{
						Parent = $path
						Path   = $tempPath
						Value  = $property.Value
						Type   = $property.Value.GetType()
						Depth  = $Elements.Count + 1
					}
				}
			}
			else
			{
				if ($Value -eq $property.Value)
				{
					[PSCustomObject]@{
						Parent = $path
						Path   = $tempPath
						Value  = $property.Value
						Type   = $property.Value.GetType()
						Depth  = $Elements.Count + 1
					}
				}
			}
			
			if ($Elements.Count -lt $Depth)
			{
				$newItems = New-Object System.Object[]($Elements.Count)
				$Elements.CopyTo($newItems, 0)
				$newItems += $property.Name
				Search-Value -Object $property.Value -Value $Value -Match $Match -Depth $Depth -Elements $newItems
			}
		}
	}
	
	Search-Value -Object $Object -Value $Value -Match $Match.ToBool() -Depth $Depth -Elements @()
}