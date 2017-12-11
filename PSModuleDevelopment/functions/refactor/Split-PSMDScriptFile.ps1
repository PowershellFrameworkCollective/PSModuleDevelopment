function Split-PSMDScriptFile
{
	<#
		.SYNOPSIS
			Parses a file and exports all top-level functions from it into a dedicated file, just for the function.
		
		.DESCRIPTION
			Parses a file and exports all top-level functions from it into a dedicated file, just for the function.
			The original file remains unharmed by this.
	
			Note: Any comments outside the function definition will not be copied.
		
		.PARAMETER File
			The file(s) to extract functions from.
		
		.PARAMETER Path
			The folder to export to
		
		.PARAMETER Encoding
			Default: UTF8
			The output encoding. Can usually be left alone.
		
		.EXAMPLE
			PS C:\> Split-PSMDScriptFile -File ".\module.ps1" -Path .\files
	
			Exports all functions in module.ps1 and puts them in individual files in the folder .\files.
	#>
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $true)]
		[string[]]
		$File,
		
		[string]
		$Path,
		
		$Encoding = "UTF8"
	)
	
	process
	{
		foreach ($item in $File)
		{
			$a = $null
			$b = $null
			$ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $item), [ref]$a, [ref]$b)
			
			foreach ($functionAst in ($ast.EndBlock.Statements | Where-Object { $_.GetType().FullName -eq "System.Management.Automation.Language.FunctionDefinitionAst" }))
			{
				$ast.Extent.Text.Substring($functionAst.Extent.StartOffset, ($functionAst.Extent.EndOffset - $functionAst.Extent.StartOffset)) | Set-Content "$Path\$($functionAst.Name).ps1" -Encoding UTF8
			}
		}
	}
}