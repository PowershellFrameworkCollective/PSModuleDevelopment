function Set-PSMDEncoding
{
<#
	.SYNOPSIS
		Sets the encoding for the input file.
	
	.DESCRIPTION
		This command reads the input file using the default encoding interpreter.
		It then writes the contents as the specified enconded string back to itself.
	
		There is no inherent encoding conversion enacted, so special characters may break.
		This is a tool designed to reformat code files, where special characters shouldn't be used anyway.
	
	.PARAMETER Path
		Path to the files to be set.
		Silently ignores folders.
	
	.PARAMETER Encoding
		The encoding to set to (Defaults to "UTF8 with BOM")
	
	.PARAMETER EnableException
        Replaces user friendly yellow warnings with bloody red exceptions of doom!
        Use this if you want the function to throw terminating errors you want to catch.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Get-ChildItem -Recurse | Set-PSMDEncoding
	
		Converts all files in the current folder and subfolders to UTF8
#>
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	param (
		[Parameter(ValueFromPipeline = $true, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path,
		
		[PSFEncoding]
		$Encoding = (Get-PSFConfigValue -FullName 'psframework.text.encoding.defaultwrite' -Fallback 'utf-8'),
		
		[switch]
		$EnableException
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ", ")" -Tag 'debug', 'start', 'param'
	}
	process
	{
		foreach ($pathItem in $Path)
		{
			Write-PSFMessage -Level VeryVerbose -Message "Processing $pathItem" -Target $pathItem
			try { $pathResolved = Resolve-PSFPath -Path $pathItem -Provider FileSystem }
			catch { Stop-PSFFunction -Message " " -EnableException $EnableException -ErrorRecord $_ -Target $pathItem -Continue }
			
			foreach ($resolvedPath in $pathResolved)
			{
				if ((Get-Item $resolvedPath).PSIsContainer) { continue }
				
				Write-PSFMessage -Level Verbose -Message "Setting encoding for $resolvedPath" -Target $pathItem
				try
				{
					if (Test-PSFShouldProcess -PSCmdlet $PSCmdlet -Target $resolvedPath -Action "Set encoding to $($Encoding.EncodingName)")
					{
						$text = [System.IO.File]::ReadAllText($resolvedPath)
						[System.IO.File]::WriteAllText($resolvedPath, $text, $Encoding)
					}
				}
				catch
				{
					Stop-PSFFunction -Message "Failed to access file! $resolvedPath" -EnableException $EnableException -ErrorRecord $_ -Target $pathItem -Continue
				}
			}
		}
	}
}