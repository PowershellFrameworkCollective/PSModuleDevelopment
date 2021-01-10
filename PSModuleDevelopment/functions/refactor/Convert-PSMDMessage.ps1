function Convert-PSMDMessage
{
<#
	.SYNOPSIS
		Converts a file's use of PSFramework messages to strings.
	
	.DESCRIPTION
		Converts a file's use of PSFramework messages to strings.
	
	.PARAMETER Path
		Path to the file to convert.
	
	.PARAMETER OutPath
		Folder in which to generate the output ps1 and psd1 file.
	
	.PARAMETER EnableException
        Replaces user friendly yellow warnings with bloody red exceptions of doom!
        Use this if you want the function to throw terminating errors you want to catch.
	
	.EXAMPLE
		PS C:\> Convert-PSMDMessage -Path 'C:\Scripts\logrotate.ps1' -OutPath 'C:\output'
	
		Converts all instances of writing messages in logrotate.ps1 to use strings instead.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[string]
		$Path,
		
		[Parameter(Mandatory = $true, Position = 1)]
		[PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
		[string]
		$OutPath,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		#region Utility Functions
		function Get-Text
		{
			[CmdletBinding()]
			param (
				$Value
			)
			
			if (-not $Value.NestedExpressions) { return $Value.Extent.Text }
			
			$expressions = @{ }
			$expIndex = 0
			
			$builder = [System.Text.StringBuilder]::new()
			$baseIndex = $Value.Extent.StartOffset
			$astIndex = 0
			
			foreach ($nestedExpression in $Value.NestedExpressions)
			{
				$null = $builder.Append($Value.Extent.Text.SubString($astIndex, ($nestedExpression.Extent.StartOffset - $baseIndex - $astIndex)).Replace("{", "{{").Replace('}', '}}'))
				$astIndex = $nestedExpression.Extent.EndOffset - $baseIndex
				
				if ($expressions.ContainsKey($nestedExpression.Extent.Text)) { $effectiveIndex = $expressions[$nestedExpression.Extent.Text] }
				else
				{
					$expressions[$nestedExpression.Extent.Text] = $expIndex
					$effectiveIndex = $expIndex
					$expIndex++
				}
				
				$null = $builder.Append("{$effectiveIndex}")
			}
			
			$null = $builder.Append($Value.Extent.Text.SubString($astIndex).Replace("{", "{{").Replace('}', '}}'))
			$builder.ToString()
		}
		
		function Get-Insert
		{
			[CmdletBinding()]
			param (
				$Value
			)
			
			if (-not $Value.NestedExpressions) { return "" }
			
			$processed = @{ }
			$elements = foreach ($nestedExpression in $Value.NestedExpressions)
			{
				if ($processed[$nestedExpression.Extent.Text]) { continue }
				else { $processed[$nestedExpression.Extent.Text] = $true }
				
				if ($nestedExpression -is [System.Management.Automation.Language.SubExpressionAst])
				{
					if (
						($nestedExpression.SubExpression.Statements.Count -eq 1) -and
						($nestedExpression.SubExpression.Statements[0].PipelineElements.Count -eq 1) -and
						($nestedExpression.SubExpression.Statements[0].PipelineElements[0].Expression -is [System.Management.Automation.Language.MemberExpressionAst])
					) { $nestedExpression.SubExpression.Extent.Text }
					else { $nestedExpression.Extent.Text.SubString(1) }
				}
				else { $nestedExpression.Extent.Text }
			}
			$elements -join ", "
		}
		#endregion Utility Functions
		
		$parameterMapping = @{
			'Message' = 'String'
			'Action'  = 'ActionString'
		}
		$insertMapping = @{
			'String' = '-StringValues'
			'Action' = '-ActionStringValues'
		}
	}
	process
	{
		$ast = (Read-PSMDScript -Path $Path).Ast
		
		#region Parse Input
		$functionName = (Get-Item $Path).BaseName
		
		$commandAsts = $ast.FindAll({
				if ($args[0] -isnot [System.Management.Automation.Language.CommandAst]) { return $false }
				if ($args[0].CommandElements[0].Value -notmatch '^Invoke-PSFProtectedCommand$|^Write-PSFMessage$|^Stop-PSFFunction$|^Test-PSFShouldProcess$') { return $false }
				if (-not ($args[0].CommandElements.ParameterName -match '^Message$|^Action$')) { return $false }
				$true
			}, $true)
		if (-not $commandAsts)
		{
			Write-PSFMessage -Level Host -String 'Convert-PSMDMessage.Parameter.NonAffected' -StringValues $Path
			return
		}
		#endregion Parse Input
		
		#region Build Replacements table
		$currentCount = 1
		$replacements = foreach ($command in $commandAsts)
		{
			$parameter = $command.CommandElements | Where-Object ParameterName -in 'Message', 'Action'
			$paramIndex = $command.CommandElements.IndexOf($parameter)
			$parameterValue = $command.CommandElements[$paramIndex + 1]
			
			[PSCustomObject]@{
				OriginalText = $parameterValue.Value
				Text		 = Get-Text -Value $parameterValue
				Inserts	     = Get-Insert -Value $parameterValue
				String	     = "$($functionName).Message$($currentCount)"
				StartOffset  = $parameter.Extent.StartOffset
				EndOffset    = $parameterValue.Extent.EndOffset
				OldParameterName = $parameter.ParameterName
				NewParameterName = $parameterMapping[$parameter.ParameterName]
				Parameter    = $parameter
				ParameterValue = $parameterValue
			}
			$currentCount++
		}
		#endregion Build Replacements table
		
		#region Calculate new text body
		$fileText = [System.IO.File]::ReadAllText((Resolve-PSFPath -Path $Path))
		$builder = [System.Text.StringBuilder]::new()
		$index = 0
		foreach ($replacement in $replacements)
		{
			$null = $builder.Append($fileText.Substring($index, ($replacement.StartOffset - $index)))
			$null = $builder.Append("-$($replacement.NewParameterName) '$($replacement.String)'")
			if ($replacement.Inserts) { $null = $builder.Append(" $($insertMapping[$replacement.NewParameterName]) $($replacement.Inserts)") }
			$index = $replacement.EndOffset
		}
		$null = $builder.Append($fileText.Substring($index))
		$newDefinition = $builder.ToString()
		$testResult = Read-PSMDScript -ScriptCode ([Scriptblock]::create($newDefinition))
		
		if ($testResult.Errors)
		{
			Stop-PSFFunction -String 'Convert-PSMDMessage.SyntaxError' -StringValues $Path -Target $Path -EnableException $EnableException
			return
		}
		#endregion Calculate new text body
		
		$resolvedOutPath = Resolve-PSFPath -Path $OutPath
		$encoding = [System.Text.UTF8Encoding]::new($true)
		$filePath = Join-Path -Path $resolvedOutPath -ChildPath "$functionName.ps1"
		[System.IO.File]::WriteAllText($filePath, $newDefinition, $encoding)
		$stringsPath = Join-Path -Path $resolvedOutPath -ChildPath "$functionName.psd1"
		$stringsText = @"
@{
$($replacements | Format-String "`t'{0}' = {1} # {2}" -Property String, Text, Inserts | Join-String -Separator "`n")
}
"@
		[System.IO.File]::WriteAllText($stringsPath, $stringsText, $encoding)
	}
}