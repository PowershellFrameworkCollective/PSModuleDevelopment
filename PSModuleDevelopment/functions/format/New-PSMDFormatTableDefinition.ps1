function New-PSMDFormatTableDefinition
{
<#
	.SYNOPSIS
		Generates a format XML for the input type.
	
	.DESCRIPTION
		Generates a format XML for the input type.
		Currently, only tables are supported.
		
		Note:
		Loading format files has a measureable impact on module import PER FILE.
		For the sake of performance, you should only generate a single file for an entire module.
	
		You can generate all items in a single call (which will probably be messy on many types at a time)
		Or you can use the -Fragment parameter to create individual fragments, and combine them by passing
		those items again to this command (the final time without the -Fragment parameter).
	
	.PARAMETER InputObject
		The object that will be used to generate the format XML for.
		Will not duplicate its work if multiple object of the same type are passed.
		Accepts objects generated when using the -Fragment parameter, combining them into a single document.
	
	.PARAMETER IncludeProperty
		Only properties in this list will be included.
	
	.PARAMETER ExcludeProperty
		Only properties not in this list will be included.
	
	.PARAMETER Fragment
		The function will only return a partial Format-XML object (an individual table definition per type).
	
	.PARAMETER DocumentName
		Adds a name to the document generated.
		Purely cosmetic.
	
	.PARAMETER SortColumns
		Enabling this will cause the command to sort columns alphabetically.
		Explicit order styles take precedence over alphabetic sorting.
	
	.PARAMETER ColumnOrder
		Specify a list of properties in the order they should appear.
		For properties with labels: Labels take precedence over selected propertyname.
	
	.PARAMETER ColumnOrderHash
		Allows explicitly defining the order of columns on a per-type basis.
		These hashtables need to have two properties:
		- Type: The name of the type it applies to (e.g.: "System.IO.FileInfo")
		- Properties: The list of properties in the order they should appear.
		Example: @{ Type = "System.IO.FileInfo"; Properties = "Name", "Length", "LastWriteTime" }
		This parameter takes precedence over ColumnOrder in instances where the
		processed typename is explicitly listed in a hashtable.
	
	.PARAMETER ColumnTransformations
		A complex parameter that allows customizing columns or even adding new ones.
		This parameter accepts a hashtable that can ...
		- Set column width
		- Set column alignment
		- Add a script column
		- Assign a label to a column
		It can be targeted by typename as well as propertyname. Possible properties (others will be ignored):
		Content          |  Type  | Possible Hashtable Keys
		Filter: Typename | string | T / Type / TypeName / FilterViewName
		Filter: Property | string | C / Column / Name / P / Property / PropertyName
		Append           |  bool  | A / Append
		ScriptBlock      | script | S / Script / ScriptBlock
		Label            | string | L / Label
		Width            |  int   | W / Width
		Alignment        | string | Align / Alignment
	
		Notes:
		- Append needs to be specified if a new column should be added if no property to override was found.
		  Use this to add a completely new column with a ScriptBlock.
		- Alignment: Expects a string, can be any choice of "Left", "Center", "Right"
	
		Example:
		$transform = @{
		    Type = "System.IO.FileInfo"
		    Append = $true
		    Script = { "{0} | {1}" -f $_.Extension, $_.Length }
		    Label = "Ext.Length"
		    Align = "Left"
		}
	
	.EXAMPLE
		PS C:\> Get-ChildItem | New-PSMDFormatTableDefinition
		
		Generates a format xml for the objects in the current path (files and folders in most cases)
	
	.EXAMPLE
		PS C:\> Get-ChildItem | New-PSMDFormatTableDefinition -IncludeProperty LastWriteTime, FullName
		
		Creates a format xml that only includes the columns LastWriteTime, FullName
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[OutputType([PSModuleDevelopment.Format.Document], ParameterSetName = "default")]
	[OutputType([PSModuleDevelopment.Format.TableDefinition], ParameterSetName = "fragment")]
	[CmdletBinding(DefaultParameterSetName = "default")]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		$InputObject,
		
		[string[]]
		$IncludeProperty,
		
		[string[]]
		$ExcludeProperty,
		
		[Parameter(ParameterSetName = "fragment")]
		[switch]
		$Fragment,
		
		[Parameter(ParameterSetName = "default")]
		[string]
		$DocumentName,
		
		[switch]
		$SortColumns,
		
		[string[]]
		$ColumnOrder,
		
		[hashtable[]]
		$ColumnOrderHash,
		
		[PSModuleDevelopment.Format.ColumnTransformation[]]
		$ColumnTransformations
	)
	
	begin
	{
		$typeNames = @()
		
		$document = New-Object PSModuleDevelopment.Format.Document
		$document.Name = $DocumentName
	}
	process
	{
		foreach ($object in $InputObject)
		{
			#region Input Type Processing
			if ($object -is [PSModuleDevelopment.Format.TableDefinition])
			{
				if ($Fragment)
				{
					$object
					continue
				}
				else
				{
					$document.Views.Add($object)
					continue
				}
			}
			
			if ($object.PSObject.TypeNames[0] -in $typeNames) { continue }
			else { $typeNames += $object.PSObject.TypeNames[0] }
			
			$typeName = $object.PSObject.TypeNames[0]
			#endregion Input Type Processing
			
			#region Process Properties
			$propertyNames = $object.PSOBject.Properties.Name
			if ($IncludeProperty)
			{
				$propertyNames = $propertyNames | Where-Object { $_ -in $IncludeProperty }
			}
			
			if ($ExcludeProperty)
			{
				$propertyNames = $propertyNames | Where-Object { $_ -notin $ExcludeProperty }
			}
			
			$table = New-Object PSModuleDevelopment.Format.TableDefinition
			$table.Name = $typeName
			$table.ViewSelectedByType = $typeName
			
			foreach ($name in $propertyNames)
			{
				$column = New-Object PSModuleDevelopment.Format.Column
				$column.PropertyName = $name
				$table.Columns.Add($column)
			}
			
			foreach ($transform in $ColumnTransformations)
			{
				$table.TransformColumn($transform)
			}
			#endregion Process Properties
			
			#region Sort Columns
			if ($SortColumns) { $table.Columns.Sort() }
			
			$appliedOrder = $false
			foreach ($item in $ColumnOrderHash)
			{
				if (($item.Type -eq $typeName) -and ($item.Properties -as [string[]]))
				{
					[string[]]$props = $item.Properties
					$table.SetColumnOrder($props)
					$appliedOrder = $true
				}
			}
			
			if ((-not $appliedOrder) -and ($ColumnOrder))
			{
				$table.SetColumnOrder($ColumnOrder)
			}
			#endregion Sort Columns
			
			$document.Views.Add($table)
			if ($Fragment) { $table }
		}
	}
	end
	{
		$document.Views.Sort()
		if (-not $Fragment) { $document }
	}
}