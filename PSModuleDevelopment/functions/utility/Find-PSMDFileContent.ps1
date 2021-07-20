function Find-PSMDFileContent
{
<#
	.SYNOPSIS
		Used to quickly search in module files.
	
	.DESCRIPTION
		This function can be used to quickly search files in your module's path.
		By using Set-PSMDModulePath (or Set-PSFConfig 'PSModuleDevelopment.Module.Path' '<path>') you can set the default path to search in.
		Using
		  Register-PSFConfig -FullName 'PSModuleDevelopment.Module.Path'
		allows you to persist this setting across sessions.
	
	.PARAMETER Pattern
		The text to search for, can be any regex pattern
	
	.PARAMETER Extension
		The extension of files to consider.
		Only files with this extension will be searched.
	
	.PARAMETER Path
		The path to use as search base.
		Defaults to the path found in the setting 'PSModuleDevelopment.Module.Path'
	
	.PARAMETER EnableException
        Replaces user friendly yellow warnings with bloody red exceptions of doom!
        Use this if you want the function to throw terminating errors you want to catch.
	
	.EXAMPLE
		PS C:\> Find-PSMDFileContent -Pattern 'Get-Test'
	
		Searches all module files for the string 'Get-Test'.
#>
    [Alias('find')]
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string]
		$Pattern,
		
		[string]
		$Extension = (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Find.DefaultExtensions'),
		
		[string]
		$Path = (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Module.Path'),
		
		[switch]
		$EnableException
	)
	
	begin
	{
		if (-not (Test-Path -Path $Path))
		{
			Stop-PSFFunction -Message "Path not found: $Path" -EnableException $EnableException -Category InvalidArgument -Tag "fail", "path", "argument"
			return
		}
	}
	process
	{
		if (Test-PSFFunctionInterrupt) { return }
		
		Get-ChildItem -Path $Path -Recurse | Where-Object Extension -Match $Extension | Select-String -Pattern $Pattern
	}
}