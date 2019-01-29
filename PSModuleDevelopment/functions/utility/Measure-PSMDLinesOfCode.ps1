function Measure-PSMDLinesOfCode
{
<#
	.SYNOPSIS
		Measures the lines of code ina PowerShell scriptfile.
	
	.DESCRIPTION
		Measures the lines of code ina PowerShell scriptfile.
		This scan uses the AST to figure out how many lines contain actual functional code.
	
	.PARAMETER Path
		Path to the files to scan.
		Folders will be ignored.
	
	.EXAMPLE
		PS C:\> Measure-PSMDLinesOfCode -Path .\script.ps1
	
		Measures the lines of code in the specified file.
	
	.EXAMPLE
		PS C:\> Get-ChildItem C:\Scripts\*.ps1 | Measure-PSMDLinesOfCode
	
		Measures the lines of code for every single file in the folder c:\Scripts.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path
	)
	
	begin
	{
		#region Utility Functions
		function Invoke-AstWalk
		{
			[CmdletBinding()]
			param (
				$Ast,
				
				[string[]]
				$Command,
				
				[string[]]
				$Name,
				
				[string]
				$NewName,
				
				[bool]
				$IsCommand,
				
				[bool]
				$NoAlias,
				
				[switch]
				$First
			)
			
			#Write-PSFMessage -Level Host -Message "Processing $($Ast.Extent.StartLineNumber) | $($Ast.Extent.File) | $($Ast.GetType().FullName)"
			$typeName = $Ast.GetType().FullName
			
			switch ($typeName)
			{
				'System.Management.Automation.Language.StringConstantExpressionAst'
				{
					$Ast.Extent.StartLineNumber .. $Ast.Extent.EndLineNumber
				}
				'System.Management.Automation.Language.IfStatementAst'
				{
					$Ast.Extent.StartLineNumber
					$Ast.Extent.EndLineNumber
					
					foreach ($clause in $Ast.Clauses)
					{
						Invoke-AstWalk -Ast $clause.Item1 -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand
						Invoke-AstWalk -Ast $clause.Item2 -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand
					}
					if ($null -ne $Ast.ElseClause)
					{
						Invoke-AstWalk -Ast $Ast.ElseClause -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand
					}
				}
				default
				{
					if (-not $First)
					{
						$Ast.Extent.StartLineNumber
						$Ast.Extent.EndLineNumber
					}
					
					foreach ($property in $Ast.PSObject.Properties)
					{
						if ($property.Name -eq "Parent") { continue }
						if ($null -eq $property.Value) { continue }
						
						if (Get-Member -InputObject $property.Value -Name GetEnumerator -MemberType Method)
						{
							foreach ($item in $property.Value)
							{
								if ($item.PSObject.TypeNames -contains "System.Management.Automation.Language.Ast")
								{
									Invoke-AstWalk -Ast $item -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand
								}
							}
							continue
						}
						
						if ($property.Value.PSObject.TypeNames -contains "System.Management.Automation.Language.Ast")
						{
							Invoke-AstWalk -Ast $property.Value -Command $Command -Name $Name -NewName $NewName -IsCommand $IsCommand
						}
					}
				}
			}
		}
		#endregion Utility Functions
	}
	process
	{
		#region Process Files
		foreach ($fileItem in $Path)
		{
			Write-PSFMessage -Level VeryVerbose -String MeasurePSMDLinesOfCode.Processing -StringValues $fileItem
			foreach ($resolvedPath in (Resolve-PSFPath -Path $fileItem -Provider FileSystem))
			{
				if ((Get-Item $resolvedPath).PSIsContainer) { continue }
				
				$parsedItem = Read-PSMDScript -Path $resolvedPath
				
				$object = New-Object PSModuleDevelopment.Utility.LinesOfCode -Property @{
					Path    = $resolvedPath
				}
				
				if ($parsedItem.Ast)
				{
					$object.Ast = $parsedItem.Ast
					$object.Lines = Invoke-AstWalk -Ast $parsedItem.Ast -First | Sort-Object -Unique
					$object.Count = ($object.Lines | Measure-Object).Count
					$object.Success = $true
				}
				
				$object
			}
		}
		#endregion Process Files
	}
}