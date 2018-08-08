function Invoke-PsmdTemplateV1
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		$TemplateInfo,
		
		[string]
		$OutPath,
		
		[bool]
		$NoFolder,
		
		[hashtable]
		$Parameters,
		
		[bool]
		$Raw,
		
		[bool]
		$Silent
	)
	Write-PSFMessage -Level Verbose -Message "Processing template $($item)" -Tag 'template', 'invoke' -FunctionName Invoke-PSMDTemplate
	
	#region Helper Function
	function Write-TemplateItem
	{
		[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
		[CmdletBinding()]
		param (
			[PSModuleDevelopment.Template.TemplateItemBase]
			$Item,
			
			[string]
			$Path,
			
			[hashtable]
			$ParameterFlat,
			
			[hashtable]
			$ParameterScript,
			
			[bool]
			$Raw
		)
		
		Write-PSFMessage -Level Verbose -Message "Creating file: $($Item.Name) ($($Item.RelativePath))" -FunctionName Invoke-PSMDTemplate -ModuleName PSModuleDevelopment -Tag 'create', 'template'
		
		$identifier = $Item.Identifier
		$isFile = $Item.GetType().Name -eq 'TemplateItemFile'
		
		#region File
		if ($isFile)
		{
			$fileName = $Item.Name
			if (-not $Raw)
			{
				foreach ($param in $Item.FileSystemParameterFlat)
				{
					$fileName = $fileName -replace "$($identifier)$([regex]::Escape($param))$($identifier)", $ParameterFlat[$param]
				}
				foreach ($param in $Item.FileSystemParameterScript)
				{
					$fileName = $fileName -replace "$($identifier)!$([regex]::Escape($param))!$($identifier)", $ParameterScript[$param]
				}
			}
			$destPath = Join-Path $Path $fileName
			
			if ($Item.PlainText)
			{
				$text = $Item.Value
				if (-not $Raw)
				{
					foreach ($param in $Item.ContentParameterFlat)
					{
						$text = $text -replace "$($identifier)$([regex]::Escape($param))$($identifier)", $ParameterFlat[$param]
					}
					foreach ($param in $Item.ContentParameterScript)
					{
						$text = $text -replace "$($identifier)!$([regex]::Escape($param))!$($identifier)", $ParameterScript[$param]
					}
				}
				[System.IO.File]::WriteAllText($destPath, $text)
			}
			else
			{
				$bytes = [System.Convert]::FromBase64String($Item.Value)
				[System.IO.File]::WriteAllBytes($destPath, $bytes)
			}
		}
		#endregion File
		
		#region Folder
		else
		{
			$folderName = $Item.Name
			if (-not $Raw)
			{
				foreach ($param in $Item.FileSystemParameterFlat)
				{
					$folderName = $folderName -replace "$($identifier)$([regex]::Escape($param))$($identifier)", $ParameterFlat[$param]
				}
				foreach ($param in $Item.FileSystemParameterScript)
				{
					$folderName = $folderName -replace "$($identifier)!$([regex]::Escape($param))!$($identifier)", $ParameterScript[$param]
				}
			}
			$folder = New-Item -Path $Path -Name $folderName -ItemType Directory
			
			foreach ($child in $Item.Children)
			{
				Write-TemplateItem -Item $child -Path $folder.FullName -ParameterFlat $ParameterFlat -ParameterScript $ParameterScript -Raw $Raw
			}
		}
		#endregion Folder
	}
	#endregion Helper Function
	
	$templateData = Import-Clixml -Path $TemplateInfo.Path -ErrorAction Stop
	#region Process Parameters
	foreach ($parameter in $templateData.Parameters)
	{
		if (-not $parameter) { continue }
		if (-not $Parameters.ContainsKey($parameter))
		{
			if ($Silent) { throw "Parameter not specified: $parameter" }
			try
			{
				$value = Read-Host -Prompt "Enter value for parameter '$parameter'" -ErrorAction Stop
				$Parameters[$parameter] = $value
			}
			catch { throw }
		}
	}
	#endregion Process Parameters
	
	#region Scripts
	$scriptParameters = @{ }
	
	if (-not $Raw)
	{
		foreach ($scriptParam in $templateData.Scripts.Values)
		{
			if (-not $scriptParam) { continue }
			try { $scriptParameters[$scriptParam.Name] = "$([scriptblock]::Create($scriptParam.StringScript).Invoke())" }
			catch
			{
				if ($Silent) { throw (New-Object System.Exception("Scriptblock $($scriptParam.Name) failed during execution: $_", $_.Exception)) }
				else
				{
					Write-PSFMessage -Level Warning -Message "Scriptblock $($scriptParam.Name) failed during execution. Please specify a custom value or use CTRL+C to terminate creation" -ErrorRecord $_ -FunctionName "Invoke-PSMDTemplate" -ModuleName 'PSModuleDevelopment'
					$scriptParameters[$scriptParam.Name] = Read-Host -Prompt "Value for script $($scriptParam.Name)"
				}
			}
		}
	}
	#endregion Scripts
	
	switch ($templateData.Type.ToString())
	{
		#region File
		"File"
		{
			foreach ($child in $templateData.Children)
			{
				Write-TemplateItem -Item $child -Path $OutPath -ParameterFlat $Parameters -ParameterScript $scriptParameters -Raw $Raw
			}
			if ($Raw -and $templateData.Scripts.Values)
			{
				$templateData.Scripts.Values | Export-Clixml -Path (Join-Path $OutPath "_PSMD_ParameterScripts.xml")
			}
		}
		#endregion File
		
		#region Project
		"Project"
		{
			#region Resolve output folder
			if (-not $NoFolder)
			{
				if ($Parameters["Name"])
				{
					$projectName = $Parameters["Name"]
					$projectFullName = Join-Path $OutPath $projectName
					if ((Test-Path $projectFullName) -and (-not $Force))
					{
						throw "Project root folder already exists: $projectFullName"
					}
					$newFolder = New-Item -Path $OutPath -Name $Parameters["Name"] -ItemType Directory -ErrorAction Stop -Force
				}
				else
				{
					throw "Parameter Name is needed to create a project without setting the -NoFolder parameter!"
				}
			}
			else { $newFolder = Get-Item $OutPath }
			#endregion Resolve output folder
			
			foreach ($child in $templateData.Children)
			{
				Write-TemplateItem -Item $child -Path $newFolder.FullName -ParameterFlat $Parameters -ParameterScript $scriptParameters -Raw $Raw
			}
			
			#region Write Config File (Raw)
			if ($Raw)
			{
				$guid = [System.Guid]::NewGuid().ToString()
				$optionsTemplate = @"
@{
	TemplateName = "$($TemplateInfo.Name)"
	Version = ([Version]"$($TemplateInfo.Version)")
	Tags = $(($TemplateInfo.Tags | ForEach-Object { "'$_'" }) -join ",")
	Author = "$($TemplateInfo.Author)"
	Description = "$($TemplateInfo.Description)"
þþþPLACEHOLDER-$($guid)þþþ
}
"@
				if ($params = $templateData.Scripts.Values)
				{
					$list = @()
					foreach ($param in $params)
					{
						$list += @"
	$($param.Name) = {
		$($param.StringScript)
	}
"@
					}
					$optionsTemplate = $optionsTemplate -replace "þþþPLACEHOLDER-$($guid)þþþ", ($list -join "`n`n")
				}
				else
				{
					$optionsTemplate = $optionsTemplate -replace "þþþPLACEHOLDER-$($guid)þþþ", ""
				}
				
				$configFile = Join-Path $newFolder.FullName "PSMDTemplate.ps1"
				Set-Content -Path $configFile -Value $optionsTemplate -Encoding UTF8
			}
			#endregion Write Config File (Raw)
		}
		#endregion Project
	}
}