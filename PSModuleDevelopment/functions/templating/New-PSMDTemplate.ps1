function New-PSMDTemplate
{
<#
	.SYNOPSIS
		Creates a template from a reference file / folder.
	
	.DESCRIPTION
		This function creates a template based on an existing folder or file.
		It automatically detects parameters that should be filled in one creation time.
	
		# Template reference: #
		#---------------------#
		Project templates can be preconfigured by a special reference file in the folder root.
		This file must be named "PSMDTemplate.ps1" and will not be part of the template.
		It must emit a single hashtable with various pieces of information.
	
		<Insert Details here>
	
		# Parameterizing templates: #
		#---------------------------#
		The script will pick up any parameter found in the files and folders (including the file/folder name itself).
		There are three ways to do this:
		- Named text replacement: The user will need to specify what to insert into this when creating a new project from this template.
		- Scriptblock replacement: The included scriptblock will be executed on initialization, in order to provide a text to insert. Duplicate scriptblocks will be merged.
		- Named scriptblock replacement: The template reference file can define scriptblocks, their value will be inserted here.
		The same name can be reused any number of times across the entire project, it will always receive the same input.
		
		Naming Rules:
		- Parameter names cannot include the characters '!', '{', or '}'
		- Parameter names cannot include the parameter identifier. This is by default 'þ'.
		  This identifier can be changed by updating the 'psmoduledevelopment.template.identifier' configuration setting.
		- Names are not case sensitive.
		
		Examples:
		° Named for replacement:
		"Test þnameþ" --> "Test <inserted text of parameter>"
	
		° Scriptblock replacement:
		"Test þ{ $env:COMPUTERNAME }þ" --> "Test <Name of invoking computer>"
		- Important: No space between identifier and curly braces!
		- Scriptblock can have multiple lines.
		
		° Named Scriptblock replacement:
		"Test þ!ClosestDomainController!þ" --> "Test <Result of script ClosestDomainController>"
	
	.PARAMETER ReferencePath
		A description of the ReferencePath parameter.
	
	.PARAMETER FilePath
		A description of the FilePath parameter.
	
	.PARAMETER TemplateName
		A description of the TemplateName parameter.
	
	.PARAMETER Filter
		A description of the Filter parameter.
	
	.PARAMETER Exclusions
		A description of the Exclusions parameter.
	
	.PARAMETER Version
		A description of the Version parameter.
	
	.PARAMETER Tags
		A description of the Tags parameter.
	
	.PARAMETER Force
		A description of the Force parameter.
	
	.PARAMETER EnableException
		A description of the EnableException parameter.
	
	.EXAMPLE
		PS C:\> New-PSMDTemplate -ReferencePath 'value1'
#>
	[CmdletBinding(DefaultParameterSetName = 'Project')]
	param (
		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Project')]
		[string]
		$ReferencePath,
		
		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'File')]
		[string]
		$FilePath,
		
		[Parameter(Position = 1, ParameterSetName = 'Project')]
		[Parameter(Position = 1, ParameterSetName = 'File', Mandatory = $true)]
		[string]
		$TemplateName,
		
		[string]
		$Filter = "*",
		
		[string[]]
		$Exclusions,
		
		[version]
		$Version = "1.0.0.0",
		
		[string[]]
		$Tags,
		
		[switch]
		$Force,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ", ")" -Tag 'debug', 'start', 'param'
		#region Insert basic meta-data
		$identifier = [regex]::Escape(( Get-PSFConfigValue -FullName 'psmoduledevelopment.template.identifier' -Fallback 'þ' ))
		$binaryExtensions = Get-PSFConfigValue -FullName 'PSModuleDevelopment.Template.BinaryExtensions' -Fallback @('.dll','.exe')
		
		$template = New-Object PSModuleDevelopment.Template.Template
		$template.Name = $TemplateName
		$template.Version = $Version
		
		if ($PSCmdlet.ParameterSetName -eq 'File')
		{
			$template.Type = 'File'
		}
		else
		{
			$template.Type = 'Project'
			
			if (Test-Path (Join-Path $ReferencePath "PSMDTemplate.ps1"))
			{
				$templateData = & (Join-Path $ReferencePath "PSMDTemplate.ps1")
				foreach ($item in $templateData.Scripts.Values)
				{
					$template.Scripts[$item.Name] = New-Object PSModuleDevelopment.Template.ParameterScript($item.Name, $item.ScriptBlock)
				}
				if ($templateData.Name -and (Test-PSFParameterBinding -ParameterName Name -Not)) { $template.Name = $templateData.Name }
				if ($templateData.Version -and (Test-PSFParameterBinding -ParameterName Version -Not)) { $template.Version = $templateData.Version }
				if ($templateData.Tags -and (Test-PSFParameterBinding -ParameterName Tags -Not)) { $template.Tags = $templateData.Tags }
				
				if (-not $template.Name)
				{
					Stop-PSFFunction -Message "No template name detected: Make sure to specify it as parameter or include it in the 'PSMDTemplate.ps1' definition file!" -EnableException $EnableException
					return
				}
				
				if ($templateData.AutoIncrementVersion)
				{
					$oldTemplate = Get-PSMDTemplate -TemplateName $template.Name -WarningAction SilentlyContinue
					if (($oldTemplate) -and ($oldTemplate.Version -ge $template.Version))
					{
						$major = $oldTemplate.Version.Major
						$minor = $oldTemplate.Version.Minor
						$revision = $oldTemplate.Version.Revision
						$build = $oldTemplate.Version.Build
						
						# Increment lowest element
						if ($build -ge 0) { $build++ }
						elseif ($revision -ge 0) { $revision++ }
						elseif ($minor -ge 0) { $minor++ }
						else { $major++ }
						$template.Version = "$($major).$($minor).$($revision).$($build)" -replace "\.-1",''
					}
				}
			}
		}
		#endregion Insert basic meta-data
		
		#region Utility functions
		function Convert-Item
		{
			[CmdletBinding()]
			param (
				[System.IO.FileSystemInfo]
				$Item,
				
				[PSModuleDevelopment.Tempalte.TemplateItemBase]
				$Parent,
				
				[string]
				$Filter,
				
				[string[]]
				$Exclusions,
				
				[PSModuleDevelopment.Template.Template]
				$Template,
				
				[string]
				$ReferencePath,
				
				[string]
				$Identifier,
				
				[string[]]
				$BinaryExtensions
			)
			
			#region Regex
			<#
				Fixed string Replacement pattern:
				"$($Identifier)([^{}!]+?)$($Identifier)"
			
				Named script replacement pattern:
				"$($Identifier)!([^{}!]+?)!$($Identifier)"
			
				Live script replacement pattern:
				"$($Identifier){(.+?)}$($Identifier)"
			
				Chained together in a logical or, in order to avoid combination issues.
			#>
			$pattern = "$($Identifier)([^{}!]+?)$($Identifier)|$($Identifier)!([^{}!]+?)!$($Identifier)|$($Identifier){(.+?)}$($Identifier)"
			#endregion Regex
			
			$name = $Item.Name
			$relativePath = ""
			if ($ReferencePath)
			{
				$relativePath = ($Item.FullName -replace "^$([regex]::Escape($ReferencePath))","").Trim("\")
			}
			
			#region Folder
			if ($Item.GetType().Name -eq "DirectoryInfo")
			{
				$object = New-Object PSModuleDevelopment.Template.TemplateItemFolder
				$object.Name = $name
				$object.RelativePath = $relativePath
				
				foreach ($find in ([regex]::Matches($name, $pattern, 'IgnoreCase')))
				{
					#region Fixed string replacement
					if ($find.Groups[1].Success)
					{
						if ($object.FileSystemParameterFlat -notcontains $find.Groups[1].Value)
						{
							$null = $object.FileSystemParameterFlat.Add($find.Groups[1].Value)
						}
						if ($Template.Parameters -notcontains $find.Groups[1].Value)
						{
							$null = $Template.Parameters.Add($find.Groups[1].Value)
						}
					}
					#endregion Fixed string replacement
					
					#region Named Scriptblock replacement
					if ($find.Groups[2].Success)
					{
						$scriptName = $find.Groups[2].Value
						if ($Template.Scripts.Keys -eq $scriptName)
						{
							$object.FileSystemParameterScript($scriptName)
						}
						else
						{
							throw "Unknown named scriptblock '$($scriptName)' in name of '$($Item.FullName)'. Make sure the named scriptblock exists in the configuration file."
						}
					}
					#endregion Named Scriptblock replacement
				}
				
				foreach ($child in (Get-ChildItem -Path $Item.FullName))
				{
					$paramConvertItem = @{
						Item			   = $child
						Filter			   = $Filter
						Exclusions		   = $Exclusions
						Template		   = $Template
						ReferencePath	   = $ReferencePath
						Identifier		   = $Identifier
						BinaryExtensions   = $BinaryExtensions
						Parent			   = $object
					}
					
					Convert-Item @paramConvertItem
				}
			}
			#endregion Folder
			
			#region File
			else
			{
				$object = New-Object PSModuleDevelopment.Template.TemplateItemFile
				$object.Name = $name
				$object.RelativePath = $relativePath
				
				#region File Name
				foreach ($find in ([regex]::Matches($name, $pattern, 'IgnoreCase')))
				{
					#region Fixed string replacement
					if ($find.Groups[1].Success)
					{
						if ($object.FileSystemParameterFlat -notcontains $find.Groups[1].Value)
						{
							$null = $object.FileSystemParameterFlat.Add($find.Groups[1].Value)
						}
						if ($Template.Parameters -notcontains $find.Groups[1].Value)
						{
							$null = $Template.Parameters.Add($find.Groups[1].Value)
						}
					}
					#endregion Fixed string replacement
					
					#region Named Scriptblock replacement
					if ($find.Groups[2].Success)
					{
						$scriptName = $find.Groups[2].Value
						if ($Template.Scripts.Keys -eq $scriptName)
						{
							$object.FileSystemParameterScript($scriptName)
						}
						else
						{
							throw "Unknown named scriptblock '$($scriptName)' in name of '$($Item.FullName)'. Make sure the named scriptblock exists in the configuration file."
						}
					}
					#endregion Named Scriptblock replacement
				}
				#endregion File Name
				
				#region File Content
				if (-not ($Item.Extension -in $BinaryExtensions))
				{
					foreach ($find in ([regex]::Matches($name, $pattern, 'IgnoreCase, Multiline')))
					{
						
					}
				}
				#endregion File Content
			}
			#endregion File
			
			if ($Parent)
			{
				$null = $Parent.Children.Add($object)
			}
			else
			{
				$null = $Template.Children.Add($object)
			}
		}
		#endregion Utility functions
	}
	process
	{
		if ($ReferencePath)
		{
			foreach ($item in (Get-ChildItem -Path $ReferencePath -Filter "*"))
			{
				if ($item.FullName -in $Exclusions) { continue }
				Convert-Item -Item $item -Filter $Filter -Exclusions $Exclusions -Template $template -ReferencePath $ReferencePath -Identifier $identifier -BinaryExtensions $binaryExtensions
			}
		}
		else
		{
			$item = Get-Item -Path $FilePath
			Convert-Item -Item $item -Template $template -Identifier $identifier -BinaryExtensions $binaryExtensions
		}
	}
	end
	{
		
	}
}