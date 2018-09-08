function Read-PSMDScript
{
<#
	.SYNOPSIS
		Parse the content of a script
	
	.DESCRIPTION
		Uses the powershell parser to parse the content of a script or scriptfile.
	
	.PARAMETER ScriptCode
		The scriptblock to parse.
	
	.PARAMETER Path
		Path to the scriptfile to parse.
		Silently ignores folder objects.
	
	.EXAMPLE
		PS C:\> Read-PSMDScript -ScriptCode $ScriptCode
	
		Parses the code in $ScriptCode
	
	.EXAMPLE
		PS C:\> Get-ChildItem | Read-PSMDScript
	
		Parses all script files in the current directory
#>
	[CmdletBinding()]
	param (
		[Parameter(Position = 0, ParameterSetName = 'Script', Mandatory = $true)]
		[System.Management.Automation.ScriptBlock]
		$ScriptCode,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'File', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ", ")" -Tag 'debug', 'start', 'param'
	}
	process
	{
		foreach ($file in $Path)
		{
			Write-PSFMessage -Level Verbose -Message "Processing $file" -Target $file
			$item = Get-Item $file
			if ($item.PSIsContainer)
			{
				Write-PSFMessage -Level Verbose -Message "is folder, skipping $file" -Target $file
				continue
			}
			
			$tokens = $null
			$errors = $null
			$ast = [System.Management.Automation.Language.Parser]::ParseFile($item.FullName, [ref]$tokens, [ref]$errors)
			[pscustomobject]@{
				PSTypeName = 'PSModuleDevelopment.Meta.ParseResult'
				Ast	       = $ast
				Tokens	   = $tokens
				Errors	   = $errors
				File	   = $item.FullName
			}
		}
		
		if ($ScriptCode)
		{
			$tokens = $null
			$errors = $null
			$ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptCode, [ref]$tokens, [ref]$errors)
			[pscustomobject]@{
				PSTypeName = 'PSModuleDevelopment.Meta.ParseResult'
				Ast	       = $ast
				Tokens	   = $tokens
				Errors	   = $errors
				Source	   = $ScriptCode
			}
		}
	}
}
Set-Alias -Name parse -Value Read-PSMDScript