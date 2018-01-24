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
		
		.PARAMETER InputObject
			The object that will be used to generate the format XML for.
			Will not duplicate its work if multiple object of the same type are passed.
		
		.PARAMETER IncludeProperty
			Only properties in this list will be included.
		
		.PARAMETER ExcludeProperty
			Only properties not in this list will be included.
		
		.PARAMETER Fragment
			The function will only return a partial Format-XML object.
			This is useful when combining multiple objects into a single file:
			Simply create a full format XML for the first type, then use fragments on the subsequent ones and paste them into the first one's structure.
		
		.EXAMPLE
			PS C:\> Get-ChildItem | New-PSMDFormatTableDefinition
	
			Generates a format xml for the objects in the current path (files and folders in most cases)
	
		.EXAMPLE
			PS C:\> Get-ChildItem | New-PSMDFormatTableDefinition -IncludeProperty LastWriteTime, FullName
	
			Creates a format xml that only includes the columns LastWriteTime, FullName
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		$InputObject,
		
		[string[]]
		$IncludeProperty,
		
		[string[]]
		$ExcludeProperty,
		
		[switch]
		$Fragment
	)
	
	begin
	{
		$typeNames = @()
		
		#region Xml Definitions
		$xmlFull = @"
<?xml version="1.0" encoding="utf-16"?>
<Configuration>
	<ViewDefinitions>
		<!-- %TypeName% -->
		<View>
			<Name>%TypeName%</Name>
			<ViewSelectedBy>
				<TypeName>%TypeName%</TypeName>
			</ViewSelectedBy>
			<TableControl>
				<AutoSize/>
				<TableHeaders>
%Headers%
				</TableHeaders>
				<TableRowEntries>
					<TableRowEntry>
						<TableColumnItems>
%Columns%
						</TableColumnItems>
					</TableRowEntry>
				</TableRowEntries>
			</TableControl>
		</View>
	</ViewDefinitions>
<Configuration>
"@
		$xmlFragment = @"
		<!-- %TypeName% -->
		<View>
			<Name>%TypeName%</Name>
			<ViewSelectedBy>
				<TypeName>%TypeName%</TypeName>
			</ViewSelectedBy>
			<TableControl>
				<AutoSize/>
				<TableHeaders>
%Headers%
				</TableHeaders>
				<TableRowEntries>
					<TableRowEntry>
						<TableColumnItems>
%Columns%
						</TableColumnItems>
					</TableRowEntry>
				</TableRowEntries>
			</TableControl>
		</View>
"@
		$xmlColumnHeaderItem = "					<TableColumnHeader/>"
		$xmlColumnItem = @"
							<TableColumnItem>
								<PropertyName>%PropertyName%</PropertyName>
							</TableColumnItem>
"@
		#endregion Xml Definitions
	}
	process
	{
		foreach ($object in $InputObject)
		{
			if ($object.PSObject.TypeNames[0] -in $typeNames) { continue }
			else { $typeNames += $object.PSObject.TypeNames[0] }
			
			$typeName = $object.PSObject.TypeNames[0]
			$propertyNames = $object.PSOBject.Properties.Name
			
			if ($IncludeProperty)
			{
				$propertyNames = $propertyNames | Where-Object { $_ -in $IncludeProperty }
			}
			
			if ($ExcludeProperty)
			{
				$propertyNames = $propertyNames | Where-Object { $_ -notin $ExcludeProperty }
			}
			
			if ($Fragment) { $baseXml = $xmlFragment }
			else { $baseXml = $xmlFull }
			
			$baseHeader = ( ,$xmlColumnHeaderItem * $propertyNames.Count) -join ([System.Environment]::NewLine)
			
			$columns = @()
			foreach ($property in $propertyNames)
			{
				$columns += $xmlColumnItem -replace "%PropertyName%", $property
			}
			$baseColumn = $columns -join ([System.Environment]::NewLine)
			
			$baseXml -replace "%TypeName%", "$typeName" -replace "%Headers%", $baseHeader -replace "%Columns%", $baseColumn
		}
	}
	end
	{
		
	}
}