function Test-PSMDClmCompatibility {
	<#
	.SYNOPSIS
		Tests, whether the targeted file would have trouble executing under Constrained Language Mode.
	
	.DESCRIPTION
		Tests, whether the targeted file would have trouble executing under Constrained Language Mode (CLM).

		In CLM, various language features and commands are constrained in their ability to execute.
		This command uses the AST parser to scan for as many known issues as possible and gives a comprehensive report for concerns found.

		Detected Issues:
		- Custom Object creation using PSCustomObject
		- Calling methods on untrusted types
		- Converting to an untrusted type
		- Using Add-Type to load anything but trusted libraries
		- Using New-Object to instantiate an untrusted type
		- Assigning Values to properties*

		*This detection will likely have a large rate of false positives, due to inability to detect datatype of the object, the property of which is being set.
		Generally, assigning values to the properties of PSObjects is fine.

		Note:
		Many of the detections make allowances for "whitelisted types".
		In CLM, access to most types is constrained, except for a few, known to be trustworthy types.
		To get a full list of the constraints and what types are allowed, see the documentation:

		https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_modes?view=powershell-7.1#constrained-language-constrained-language
	
	.PARAMETER Path
		Path to the scriptfile to scan.
	
	.EXAMPLE
		PS C:\> Get-ChildItem C:\Scripts | Test-PSMDClmCompatibility

		Scans each file in C:\Scripts and returns any issues that might occur in CLM.
	
	.LINK
		https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_modes?view=powershell-7.1#constrained-language-constrained-language
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path
	)

	begin {
		#region Safe Types
		$safeTypes = @(
			[System.Array]
			[System.Boolean]
			[System.Byte]
			[System.Char]
			[System.DateTime]
			[System.Decimal]
			[System.Double]
			[System.Single]
			[System.Guid]
			[System.Collections.Hashtable]
			[System.Int32]
			[System.Int16]
			[System.Int64]
			[System.Management.Automation.Language.NullString]
			[System.Management.Automation.PSCredential]
			[System.Management.Automation.PSListModifier]
			[System.Management.Automation.PSObject]
			[System.Management.Automation.PSPrimitiveDictionary]
			[System.Management.Automation.PSTypeNameAttribute]
			[System.Text.RegularExpressions.Regex]
			[System.SByte]
			[System.String]
			[System.Globalization.CultureInfo]
			[System.Net.IPAddress]
			[System.Net.Mail.MailAddress]
			[System.Numerics.BigInteger]
			[System.Security.SecureString]
			[System.TimeSpan]
			[System.UInt16]
			[System.UInt32]
			[System.UInt64]
			[System.Management.Automation.AliasAttribute]
			[System.Management.Automation.AllowEmptyCollectionAttribute]
			[System.Management.Automation.AllowEmptyStringAttribute]
			[System.Management.Automation.AllowNullAttribute]
			[System.Management.Automation.CmdletBindingAttribute]
			[System.DirectoryServices.DirectoryEntry]
			[System.DirectoryServices.DirectorySearcher]
			[System.Management.ManagementClass]
			[System.Management.ManagementObject]
			[System.Management.ManagementObjectSearcher]
			[System.Management.Automation.OutputTypeAttribute]
			[System.Management.Automation.ParameterAttribute]
			[System.Management.Automation.PSDefaultValueAttribute]
			[System.Management.Automation.PSReference]
			[System.Management.Automation.SupportsWildcardsAttribute]
			[System.Management.Automation.SwitchParameter]
		)
		#endregion Safe Types

		#region Utility Functions
		function Search-Ast {
			[CmdletBinding()]
			param (
				[System.Management.Automation.Language.Ast]
				$Ast,

				[ScriptBlock]
				$Filter,

				[string]
				$Type,

				[string]
				$Explanation
			)

			$results = $Ast.FindAll($Filter, $true)

			foreach ($result in $results) {
				[PSCustomObject]@{
					Type        = $Type
					Line        = $result.Extent.StartLineNumber
					File        = $Ast.Extent.File
					Data        = $result
					Explanation = $Explanation
				}
			}
		}

		function Format-Result {
			[CmdletBinding()]
			param (
				[Parameter(ValueFromPipeline = $true)]
				$Result
			)

			begin {
				$defaultDisplaySet = 'Type', 'Line', 'File', 'Data'
				$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’, [string[]]$defaultDisplaySet)
				$standardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
			}
			process {
				$Result | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $standardMembers -PassThru
			}
		}

		function Find-PSCustomObject {
			[CmdletBinding()]
			param (
				[System.Management.Automation.Language.Ast]
				$Ast,

				$SafeTypes
			)

			$explanation = 'Custom object creation using PSCustomObject is not available in CLM. You can work around this issue by replacing it with "New-Object PSObject -Properties @{ ... }", which works in CLM.'
			Search-Ast -Ast $Ast -Type PSCustomObject -Explanation $explanation -Filter {
				if ($args[0] -isnot [System.Management.Automation.Language.ConvertExpressionAst]) { return }
				if ($args[0].Type.TypeName.Name -ne 'PSCustomObject') { return }

				$true
			} | Format-Result
		}

		function Find-MethodInvocation {
			[CmdletBinding()]
			param (
				[System.Management.Automation.Language.Ast]
				$Ast,

				$SafeTypes
			)

			$explanation = 'Cannot call methods on objects in CLM, other than ToString, unless the type is one of the few basic trusted types such as string or integer'
			Search-Ast -Ast $Ast -Type 'Method Invocation' -Explanation $explanation -Filter {
				if ($args[0] -isnot [System.Management.Automation.Language.InvokeMemberExpressionAst]) { return }
				if ($args[0].Expression.StaticType -in $SafeTypes) { return }
				if ($args[0].Member.Value -eq 'ToString') { return }
			
				$true
			} | Format-Result
		}
		
		function Find-TypeConversion {
			[CmdletBinding()]
			param (
				[System.Management.Automation.Language.Ast]
				$Ast,

				$SafeTypes
			)

			$explanation = 'Cannot convert to types not trusted in CLM. Trusted types are few, including very simple types such as string or integer.'
			Search-Ast -Ast $Ast -Type 'Type Conversion' -Explanation $explanation -Filter {
				if ($args[0] -isnot [System.Management.Automation.Language.ConvertExpressionAst]) { return }
				if ($args[0].StaticType -in $SafeTypes) { return }
				if ($args[0].Type.TypeName.Name -eq 'PSCustomObject' -and $args[0].Child.StaticType -eq [hashtable]) { return }

				$true
			} | Format-Result
		}

		function Find-AddType {
			[CmdletBinding()]
			param (
				[System.Management.Automation.Language.Ast]
				$Ast,

				$SafeTypes
			)

			$explanation = 'Add-Type can only load signed and trusted libraries. This includes core .NET assemblies loaded by name. If loading an assembly from file, this detection will trigger, as it does not verify the file referenced. If the targeted dll is signed and trusted, disregard this detection.'
			Search-Ast -Ast $Ast -Type 'Add-Type' -Explanation $explanation -Filter {
				if ($args[0] -isnot [System.Management.Automation.Language.CommandAst]) { return }
				if ($args[0].CommandElements[0].Value -ne 'Add-Type') { return }
				if ($args[0].CommandElements.ParameterName -contains 'AssemblyName') { return }

				$true
			} | Format-Result
		}

		function Find-NewObject {
			[CmdletBinding()]
			param (
				[System.Management.Automation.Language.Ast]
				$Ast,

				$SafeTypes
			)

			$explanation = 'New-Object cannot be used in CLM, except to create an object of one of a set of explicitly whitelisted types, such as strings, integers, DateTime, etc.'
			Search-Ast -Ast $Ast -Type 'New-Object' -Explanation $explanation -Filter {
				if ($args[0] -isnot [System.Management.Automation.Language.CommandAst]) { return }
				if ($args[0].CommandElements[0].Value -ne 'New-Object') { return }
				if ($args[0].CommandElements | Where-Object Value -In $SafeTypes.FullName) { return }
				if ($args[0].CommandElements | Where-Object Value -eq 'PSObject') { return }

				$true
			} | Format-Result
		}

		function Find-PropertyAssignment {
			[CmdletBinding()]
			param (
				[System.Management.Automation.Language.Ast]
				$Ast,

				$SafeTypes
			)

			$explanation = 'Under CLM, assigning values to properties doesn''t work, unless the type is explicitly whitelisted by the engine. Generic PSObject objects - such as returned by ConvertFrom-Json or Import-Csv - ARE whitelisted however, so this scan may have a few false positives, sorry.'
			Search-Ast -Ast $Ast -Type 'Property Assignment' -Explanation $explanation -Filter {
				if ($args[0] -isnot [System.Management.Automation.Language.AssignmentStatementAst]) { return }
				if ($args[0].Left -isnot [System.Management.Automation.Language.MemberExpressionAst]) { return }
				if ($args[0].CommandElements | Where-Object Value -In $SafeTypes.FullName) { return }

				$true
			} | Format-Result
		}

		function Find-ClassDefinition {
			[CmdletBinding()]
			param (
				[System.Management.Automation.Language.Ast]
				$Ast,

				$SafeTypes
			)

			$explanation = 'PowerShell classes are not supported in Constrained Language Mode.'
			Search-Ast -Ast $Ast -Type 'PowerShell Class' -Explanation $explanation -Filter {
				if ($args[0] -isnot [System.Management.Automation.Language.TypeDefinitionAst]) { return }
				if ($args[0].TypeAttributes -eq 'Enum') { return }
				
				$true
			} | Format-Result
		}
		#endregion Utility Functions
	}
	process {
		foreach ($file in ($Path | Resolve-Path).Path) {
			try { $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$null, [ref]$null) }
			catch {
				Write-PSFMessage -Level Warning -Message "Error parsing: $file" -ErrorRecord $_ -PSCmdlet $PSCmdlet -EnableException $true
				continue
			}

			$param = @{
				Ast       = $ast
				SafeTypes = $safeTypes
			}

			Find-PSCustomObject @param
			Find-MethodInvocation @param
			Find-TypeConversion @param
			Find-AddType @param
			Find-NewObject @param
			Find-PropertyAssignment @param
			Find-ClassDefinition @param
		}
	}
}