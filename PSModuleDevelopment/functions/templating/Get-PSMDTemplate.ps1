function Get-PSMDTemplate
{
<#
	.SYNOPSIS
		Search for templates to create from.
	
	.DESCRIPTION
		Search for templates to create from.
	
	.PARAMETER TemplateName
		The name of the template to search for.
		Templates are filtered by this using wildcard comparison.
		Defaults to "*" (everything).
	
	.PARAMETER Store
		The template store to retrieve tempaltes from.
		By default, all stores are queried.
	
	.PARAMETER Path
		Instead of a registered store, look in this path for templates.
	
	.PARAMETER Tags
		Only return templates with the following tags.
	
	.PARAMETER Author
		Only return templates by this author.
	
	.PARAMETER MinimumVersion
		Only return templates with at least this version.
	
	.PARAMETER RequiredVersion
		Only return templates with exactly this version.
	
	.PARAMETER All
		Return all versions found.
		By default, only the latest matching version of a template will be returned.
	
	.PARAMETER EnableException
        Replaces user friendly yellow warnings with bloody red exceptions of doom!
        Use this if you want the function to throw terminating errors you want to catch.
	
	.EXAMPLE
		PS C:\> Get-PSMDTemplate
	
		Returns all templates
	
	.EXAMPLE
		PS C:\> Get-PSMDTemplate -TemplateName module
	
		Returns the latest version of the template named module.
#>
	[CmdletBinding(DefaultParameterSetName = 'Store')]
	Param (
		[Parameter(Position = 0)]
		[string]
		$TemplateName = "*",
		
		[Parameter(ParameterSetName = 'Store')]
		[string]
		$Store = "*",
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Path')]
		[string]
		$Path,
		
		[string[]]
		$Tags,
		
		[string]
		$Author,
		
		[version]
		$MinimumVersion,
		
		[version]
		$RequiredVersion,
		
		[switch]
		$All,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		$prospects = @()
	}
	process
	{
		#region Scan folders
		if (Test-PSFParameterBinding -ParameterName "Path")
		{
			$templateInfos = Get-ChildItem -Path $Path -Filter "$($TemplateName)-*.Info.xml" | Where-Object { ($_.Name -replace "-\d+(\.\d+){0,3}.Info.xml$") -like $TemplateName }
			
			foreach ($info in $templateInfos)
			{
				$data = Import-PSFClixml $info.FullName
				$data.Path = $info.FullName -replace '\.Info\.xml$','.xml'
				$prospects += $data
			}
		}
		#endregion Scan folders
		
		#region Search Stores
		else
		{
			$stores = Get-PsmdTemplateStore -Filter $Store
			
			foreach ($item in $stores)
			{
				if ($item.Ensure())
				{
					$templateInfos = Get-ChildItem -Path $item.Path -Filter "$($TemplateName)-*-Info.xml" | Where-Object { ($_.Name -replace "-\d+(\.\d+){0,3}-Info.xml$") -like $TemplateName }
					
					foreach ($info in $templateInfos)
					{
						$data = Import-PSFClixml $info.FullName
						$data.Path = $info.FullName -replace '-Info\.xml$', '.xml'
						$data.Store = $item.Name
						$prospects += $data
					}
				}
				# If the user asked for a specific store, it should error out on him
				elseif ($item.Name -eq $Store)
				{
					Stop-PSFFunction -Message "Could not find store $Store" -EnableException $EnableException -Category OpenError -Tag 'fail','template','store','open'
					return
				}
			}
		}
		#endregion Search Stores
	}
	end
	{
		$filteredProspects = @()
		
		#region Apply filters
		foreach ($prospect in $prospects)
		{
			if ($Author)
			{
				if ($prospect.Author -notlike $Author) { continue }
			}
			if (Test-PSFParameterBinding -ParameterName MinimumVersion)
			{
				if ($prospect.Version -lt $MinimumVersion) { continue }
			}
			if (Test-PSFParameterBinding -ParameterName RequiredVersion)
			{
				if ($prospect.Version -ne $RequiredVersion) { continue }
			}
			if ($Tags)
			{
				$test = $false
				foreach ($tag in $Tags)
				{
					if ($prospect.Tags -contains $tag)
					{
						$test = $true
						break
					}
				}
				if (-not $test) { continue }
			}
			
			$filteredProspects += $prospect
		}
		#endregion Apply filters
		
		#region Return valid templates
		if ($All) { return $filteredProspects | Sort-Object Type, Name, Version }
		
		$prospectHash = @{ }
		foreach ($prospect in $filteredProspects)
		{
			if ($prospectHash.Keys -notcontains $prospect.Name)
			{
				$prospectHash[$prospect.Name] = $prospect
			}
			elseif ($prospectHash[$prospect.Name].Version -lt $prospect.Version)
			{
				$prospectHash[$prospect.Name] = $prospect
			}
		}
		$prospectHash.Values | Sort-Object Type, Name
		#endregion Return valid templates
	}
}