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
		
		This hashtable can have any number of the following values, in any desired combination:
		- Scripts: A Hashtable, of scriptblocks. These are scripts used for replacement parameters, the key is the name used on insertions.
		- TemplateName: Name of the template
		- Version: The version number for the template (See AutoIncrementVersion property)
		- AutoIncrementVersion: Whether the version number should be incremented
		- Tags: Tags to add to a template - makes searching and finding templates easier
		- Author: Name of the author of the template
		- Description: Description of the template
		- Exclusions: List of relative file/folder names to not process / skip.
		Each of those entries can also be overridden by specifying the corresponding parameter of this function.
		
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
		- Named Scriptblocks are created by using a template reference file (see section above)
	
	.PARAMETER ReferencePath
		Root path in which all files are selected for creating a template project.
		The folder will not be part of the template, only its content.
	
	.PARAMETER FilePath
		Path to a single file.
		Used to create a template for that single file, instead of a full-blown project.
		Note: Does not support template reference files.
	
	.PARAMETER TemplateName
		Name of the template.
	
	.PARAMETER Filter
		Only files matching this filter will be included in the template.
	
	.PARAMETER OutStore
		Where the template will be stored at.
		By default, it will push the template to the default store (A folder in appdata unless configuration was changed).
	
	.PARAMETER OutPath
		If the template should be written to a specific path instead.
		Specify a folder.
	
	.PARAMETER Exclusions
		The relative path of the files or folders to ignore.
		Ignoring folders will also ignore all items in the folder.
	
	.PARAMETER Version
		The version of the template.
	
	.PARAMETER Author
		The author of the template.
	
	.PARAMETER Description.
		A description text for the template itself.
		This will be visible to the user before invoking the template and should describe what this template is for.
	
	.PARAMETER Tags
		Tags to apply to the template, making it easier to filter & search.
	
	.PARAMETER Force
		If the template in the specified version in the specified destination already exists, this will fail unless the Force parameter is used.
	
	.PARAMETER EnableException
        Replaces user friendly yellow warnings with bloody red exceptions of doom!
        Use this if you want the function to throw terminating errors you want to catch.
	
	.EXAMPLE
		PS C:\> New-PSMDTemplate -FilePath .\þnameþ.Test.ps1 -TemplateName functiontest
	
		Creates a new template named 'functiontest', based on the content of '.\þnameþ.Test.ps1'
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
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
		
		[string]
		$OutStore = "Default",
		
		[string]
		$OutPath,
		
		[string[]]
		$Exclusions,
		
		[version]
		$Version = "1.0.0.0",
		
		[string]
		$Description,
		
		[string]
		$Author = (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Template.ParameterDefault.Author' -Fallback $env:USERNAME),
		
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
		$binaryExtensions = Get-PSFConfigValue -FullName 'PSModuleDevelopment.Template.BinaryExtensions' -Fallback @('.dll', '.exe', '.pdf', '.doc', '.docx', '.xls', '.xlsx')
		
		$template = New-Object PSModuleDevelopment.Template.Template
		$template.Name = $TemplateName
		$template.Version = $Version
		$template.Tags = $Tags
		$template.Description = $Description
		$template.Author = $Author
		
		if ($PSCmdlet.ParameterSetName -eq 'File')
		{
			$template.Type = 'File'
		}
		else
		{
			$template.Type = 'Project'
			
			$processedReferencePath = Resolve-Path $ReferencePath
			
			if (Test-Path (Join-Path $processedReferencePath "PSMDTemplate.ps1"))
			{
				$templateData = & (Join-Path $processedReferencePath "PSMDTemplate.ps1")
				foreach ($key in $templateData.Scripts.Keys)
				{
					$template.Scripts[$key] = New-Object PSModuleDevelopment.Template.ParameterScript($key, $templateData.Scripts[$key])
				}
				if ($templateData.TemplateName -and (Test-PSFParameterBinding -ParameterName TemplateName -Not)) { $template.Name = $templateData.TemplateName }
				if ($templateData.Version -and (Test-PSFParameterBinding -ParameterName Version -Not)) { $template.Version = $templateData.Version }
				if ($templateData.Tags -and (Test-PSFParameterBinding -ParameterName Tags -Not)) { $template.Tags = $templateData.Tags }
				if ($templateData.Description -and (Test-PSFParameterBinding -ParameterName Description -Not)) { $template.Description = $templateData.Description }
				if ($templateData.Author -and (Test-PSFParameterBinding -ParameterName Author -Not)) { $template.Author = $templateData.Author }
				
				if (-not $template.Name)
				{
					Stop-PSFFunction -Message "No template name detected: Make sure to specify it as parameter or include it in the 'PSMDTemplate.ps1' definition file!" -EnableException $EnableException
					return
				}
				
				if ($templateData.AutoIncrementVersion)
				{
					$oldTemplate = Get-PSMDTemplate -TemplateName $template.Name -WarningAction SilentlyContinue | Sort-Object Version | Select-Object -First 1
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
				
				if ($templateData.Exclusions -and (Test-PSFParameterBinding -ParameterName Exclusions -Not)) { $Exclusions = $templateData.Exclusions }
			}
			
			if ($Exclusions)
			{
				$oldExclusions = $Exclusions
				$Exclusions = @()
				foreach ($exclusion in $oldExclusions)
				{
					$Exclusions += Join-Path $processedReferencePath $exclusion
				}
			}
		}
		#endregion Insert basic meta-data
		
		#region Validate & ensure output folder
		$fileName = "$($template.Name)-$($template.Version).xml"
		$infoFileName = "$($template.Name)-$($template.Version)-Info.xml"
		if ($OutPath) { $exportFolder = $OutPath }
		else { $exportFolder = Get-PsmdTemplateStore -Filter $OutStore | Select-Object -ExpandProperty Path -First 1 }
		
		if (-not $exportFolder)
		{
			Stop-PSFFunction -Message "Unable to resolve a path to create the template in. Verify a valid template store or path were specified." -Category InvalidArgument -EnableException $EnableException -Tag 'fail', 'argument', 'path'
			return
		}
		
		if (-not (Test-Path $exportFolder))
		{
			if ($Force)
			{
				try { $null = New-Item -Path $exportFolder -ItemType Directory -Force -ErrorAction Stop }
				catch
				{
					Stop-PSFFunction -Message "Failed to create output path: $exportFolder" -ErrorRecord $_ -Tag 'fail', 'folder', 'create' -EnableException $EnableException
					return
				}
			}
			else
			{
				Stop-PSFFunction -Message "Output folder does not exist. Use '-Force' to have this function automatically create it: $exportFolder" -Category InvalidArgument -EnableException $EnableException -Tag 'fail', 'argument', 'path'
				return
			}
		}
		
		if ((Test-Path (Join-Path $exportFolder $fileName)) -and (-not $Force))
		{
			Stop-PSFFunction -Message "Template already exists in the current version. Use '-Force' if you want to overwrite it!" -Category InvalidArgument -EnableException $EnableException -Tag 'fail', 'argument', 'path'
			return
		}
		#endregion Validate & ensure output folder
		
		#region Utility functions
		function Convert-Item
		{
			[CmdletBinding()]
			param (
				[System.IO.FileSystemInfo]
				$Item,
				
				[PSModuleDevelopment.Template.TemplateItemBase]
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
			
			if ($Item.FullName -in $Exclusions) { return }
			
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
				
				foreach ($child in (Get-ChildItem -Path $Item.FullName -Filter $Filter))
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
							$null = $object.FileSystemParameterScript.Add($scriptName)
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
					$text = [System.IO.File]::ReadAllText($Item.FullName)
					foreach ($find in ([regex]::Matches($text, $pattern, 'IgnoreCase, Multiline')))
					{
						#region Fixed string replacement
						if ($find.Groups[1].Success)
						{
							if ($object.FileSystemParameterFlat -notcontains $find.Groups[1].Value)
							{
								$null = $object.ContentParameterFlat.Add($find.Groups[1].Value)
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
								$null = $object.ContentParameterScript.Add($scriptName)
							}
							else
							{
								throw "Unknown named scriptblock '$($scriptName)' in name of '$($Item.FullName)'. Make sure the named scriptblock exists in the configuration file."
							}
						}
						#endregion Named Scriptblock replacement
						
						#region Live Scriptblock replacement
						if ($find.Groups[3].Success)
						{
							$scriptCode = $find.Groups[3].Value
							$scriptBlock = [ScriptBlock]::Create($scriptCode)
							
							if ($scriptBlock.ToString() -in $Template.Scripts.Values.StringScript)
							{
								$scriptName = ($Template.Scripts.Values | Where-Object StringScript -EQ $scriptBlock.ToString() | Select-Object -First 1).Name
								if ($object.ContentParameterScript -notcontains $scriptName)
								{
									$null = $object.ContentParameterScript.Add($scriptName)
								}
								$text = $text -replace ([regex]::Escape("$($Identifier){$($scriptCode)}$($Identifier)")), "$($Identifier)!$($scriptName)!$($Identifier)"
							}
							
							else
							{
								do
								{
									$scriptName = "dynamicscript_$(Get-Random -Minimum 100000 -Maximum 999999)"
								}
								until ($Template.Scripts.Keys -notcontains $scriptName)
								
								$parameter = New-Object PSModuleDevelopment.Template.ParameterScript($scriptName, ([System.Management.Automation.ScriptBlock]::Create($scriptCode)))
								$Template.Scripts[$scriptName] = $parameter
								$null = $object.ContentParameterScript.Add($scriptName)
								$text = $text -replace ([regex]::Escape("$($Identifier){$($scriptCode)}$($Identifier)")), "$($Identifier)!$($scriptName)!$($Identifier)"
							}
						}
						#endregion Live Scriptblock replacement
					}
					$object.Value = $text
				}
				else
				{
					$bytes = [System.IO.File]::ReadAllBytes($Item.FullName)
					$object.Value = [System.Convert]::ToBase64String($bytes)
				}
				#endregion File Content
			}
			#endregion File
			
			# Set identifier, so that Invoke-PSMDTemplate knows what to use when creating the item
			# Needed for sharing templates between users with different identifiers
			$object.Identifier = $Identifier
			
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
		if (Test-PSFFunctionInterrupt) { return }
		
		#region Parse content and produce template
		if ($ReferencePath)
		{
			foreach ($item in (Get-ChildItem -Path $processedReferencePath -Filter $Filter))
			{
				if ($item.FullName -in $Exclusions) { continue }
				Convert-Item -Item $item -Filter $Filter -Exclusions $Exclusions -Template $template -ReferencePath $processedReferencePath -Identifier $identifier -BinaryExtensions $binaryExtensions
			}
		}
		else
		{
			$item = Get-Item -Path $FilePath
			Convert-Item -Item $item -Template $template -Identifier $identifier -BinaryExtensions $binaryExtensions
		}
		#endregion Parse content and produce template
	}
	end
	{
		if (Test-PSFFunctionInterrupt) { return }
		
		$template.CreatedOn = (Get-Date).Date
		
		$template | Export-Clixml -Path (Join-Path $exportFolder $fileName)
		$template.ToTemplateInfo() | Export-Clixml -Path (Join-Path $exportFolder $infoFileName)
	}
}