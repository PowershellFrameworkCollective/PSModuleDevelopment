function Export-PSMDString
{
<#
	.SYNOPSIS
		Parses a module that uses the PSFramework localization feature for strings and their value.
	
	.DESCRIPTION
		Parses a module that uses the PSFramework localization feature for strings and their value.
		This command can be used to generate and update the language files used by the module.
		It is also used in automatic tests, ensuring no abandoned string has been left behind and no key is unused.
	
	.PARAMETER ModuleRoot
		The root of the module to process.
		Must be the root folder where the psd1 file is stored in.
	
	.EXAMPLE
		PS C:\> Export-PSMDString -ModuleRoot 'C:\Code\Github\MyModuleProject\MyModule'
	
		Generates the strings data for the MyModule module.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('ModuleBase')]
		[string]
		$ModuleRoot
	)
	
	process
	{
		#region Find Language Files : $languageFiles
		$languageFiles = @{ }
		$languageFolders = Get-ChildItem -Path $ModuleRoot -Directory | Where-Object Name -match '^\w\w-\w\w$'
		foreach ($languageFolder in $languageFolders)
		{
			$languageFiles[$languageFolder.Name] = @{ }
			foreach ($file in (Get-ChildItem -Path $languageFolder.FullName -Filter *.psd1))
			{
				$languageFiles[$languageFolder.Name] += Import-PSFPowerShellDataFile -Path $file.FullName
			}
		}
		#endregion Find Language Files : $languageFiles
		
		#region Find Keys : $foundKeys
		$foundKeys = foreach ($file in (Get-ChildItem -Path $ModuleRoot -Recurse | Where-Object Extension -match '^\.ps1$|^\.psm1$'))
		{
			$ast = (Read-PSMDScript -Path $file.FullName).Ast
			$commandAsts = $ast.FindAll({
					if ($args[0] -isnot [System.Management.Automation.Language.CommandAst]) { return $false }
					if ($args[0].CommandElements[0].Value -notmatch '^Invoke-PSFProtectedCommand$|^Write-PSFMessage$|^Stop-PSFFunction$') { return $false }
					if (-not ($args[0].CommandElements.ParameterName -match '^String$|^ActionString$')) { return $false }
					$true
				}, $true)
			
			foreach ($commandAst in $commandAsts)
			{
				$stringParam = $commandAst.CommandElements | Where-Object ParameterName -match '^String$|^ActionString$'
				$stringParamValue = $commandAst.CommandElements[($commandAst.CommandElements.IndexOf($stringParam) + 1)].Value
				
				$stringValueParam = $commandAst.CommandElements | Where-Object ParameterName -match '^StringValues$|^ActionStringValues$'
				if ($stringValueParam)
				{
					$stringValueParamValue = $commandAst.CommandElements[($commandAst.CommandElements.IndexOf($stringValueParam) + 1)].Extent.Text
				}
				else { $stringValueParamValue = '' }
				[PSCustomObject]@{
					PSTypeName = 'PSModuleDevelopment.String.ParsedItem'
					File	   = $file.FullName
					Line	   = $commandAst.Extent.StartLineNumber
					CommandName = $commandAst.CommandElements[0].Value
					String	   = $stringParamValue
					StringValues = $stringValueParamValue
				}
			}
            
             # Additional checks for splatted commands
            # find all splatted commands
            $splattedVariables = $ast.FindAll( {
                if ($args[0] -isnot [System.Management.Automation.Language.VariableExpressionAst ]) { return $false }
                if (-not ($args[0].Splatted -eq $true)) { return $false }
                $true
            }, $true)

            foreach ($splattedVariable in $splattedVariables)
            {
                #get the variable name
                $splatParamName = $splattedVariable.VariablePath.UserPath 
                if ($splatParamName)
                {
                    # match the $param = @{
                    $splatParamNameRegex = "^\s?\`$$($splatParamName)\s?=\s?\@\{"
                    # get all variable assignments where the
                    # left side matches our param
                    # operator is =
                    # matches our assignment regex
                    $splatAssignmentAsts = $ast.FindAll( {                                                                                                                                             
                            if ($args[0] -isnot [System.Management.Automation.Language.AssignmentStatementAst ]) { return $false }
                            if (-not ($args[0].Left -match $splatParamName)) { return $false }
                            if (-not ($args[0].Operator -eq 'Equals')) { return $false }
                            if (-not ($args[0].Extent -match $splatParamNameRegex)) { return $false }
                            $true
                        }, $true)
                    foreach ($splatAssignmentAst in $splatAssignmentAsts)
                    {
                        # get the hashtable
                        $splatHashTable = $splatAssignmentAst.Right.Expression
                        # see if its an empty assignment or null
                        if ($splatHashTable -and $splatHashTable.KeyValuePairs.Count -gt 0)
                        {
                            # find any String or ActionString
                            $splatParam = $splatAssignmentAst.Right.Expression.KeyValuePairs |  Where-Object Item1 -match '^String$|^ActionString$'
                            # The kvp.item.extent.text returns nested quotes where as the commandast.extent.text doesn't so strip them off
                            $splatParamValue = $splatParam.Item2.Extent.Text.Trim('"').Trim("'")
                            # find any StringValue or ActionStringValue
                            $splatValueParam = $splatAssignmentAst.Right.Expression.KeyValuePairs |  Where-Object Item1 -match '^StringValues$|^ActionStringValues$'
                            if ($splatValueParam)
                            {
                                # The kvp.item.extent.text returns nested quotes whereas the commandast.extent.text doesn't so strip them off
                                $splatValueParamValue = $splatValueParam.Item2.Extent.Text.Trim('"').Trim("'")
                            }
                            else { $splatValueParamValue = '' }

                            [PSCustomObject]@{
                                PSTypeName   = 'PSModuleDevelopment.String.ParsedItem'
                                File         = $file.FullName
                                Line         = $splatHashTable.Extent.StartLineNumber
                                CommandName  = $splattedVariable.Parent.CommandElements[0].Value
                                String       = $splatParamValue
                                StringValues = $splatValueParamValue
                            }
                        }
                    }
                }
            }

			$validateAsts = $ast.FindAll({
					if ($args[0] -isnot [System.Management.Automation.Language.AttributeAst]) { return $false }
					if ($args[0].TypeName -notmatch '^PsfValidateScript$|^PsfValidatePattern$') { return $false }
					if (-not ($args[0].NamedArguments.ArgumentName -eq 'ErrorString')) { return $false }
					$true
				}, $true)
			
			foreach ($validateAst in $validateAsts)
			{
				[PSCustomObject]@{
					PSTypeName = 'PSModuleDevelopment.String.ParsedItem'
					File	   = $file.FullName
					Line	   = $commandAst.Extent.StartLineNumber
					CommandName = '[{0}]' -f $validateAst.TypeName
					String	   = (($validateAst.NamedArguments | Where-Object ArgumentName -eq 'ErrorString').Argument.Value -split "\.", 2)[1] # The first element is the module element
					StringValues = '<user input>, <validation item>'
				}
			}
		}
		#endregion Find Keys : $foundKeys
		
		#region Report Findings
		$totalResults = foreach ($languageFile in $languageFiles.Keys)
		{
			#region Phase 1: Matching parsed strings to language file
			$results = @{ }
			foreach ($foundKey in $foundKeys)
			{
				if ($results[$foundKey.String])
				{
					$results[$foundKey.String].Entries += $foundKey
					continue
				}
				
				$results[$foundKey.String] = [PSCustomObject] @{
					PSTypeName = 'PSmoduleDevelopment.String.LanguageFinding'
					Language   = $languageFile
					Surplus    = $false
					String	   = $foundKey.String
					StringValues = $foundKey.StringValues
					Text	   = $languageFiles[$languageFile][$foundKey.String]
					Line	   = "'{0}' = '{1}' # {2}" -f $foundKey.String, $languageFiles[$languageFile][$foundKey.String], $foundKey.StringValues
					Entries    = @($foundKey)
				}
			}
			$results.Values
			#endregion Phase 1: Matching parsed strings to language file
			
			#region Phase 2: Finding unneeded strings
			foreach ($key in $languageFiles[$languageFile].Keys)
			{
				if ($key -notin $foundKeys.String)
				{
					[PSCustomObject] @{
						PSTypeName   = 'PSmoduleDevelopment.String.LanguageFinding'
						Language	 = $languageFile
						Surplus	     = $true
						String	     = $key
						StringValues = ''
						Text		 = $languageFiles[$languageFile][$key]
						Line		 = ''
						Entries	     = @()
					}
				}
			}
			#endregion Phase 2: Finding unneeded strings
		}
		$totalResults | Sort-Object String
		#endregion Report Findings
	}
}