function New-PSMDDotNetProject
{
<#
	.SYNOPSIS
		Wrapper function around 'dotnet new'
	
	.DESCRIPTION
		This function is a wrapper around the dotnet.exe application with the parameter 'new'.
		It can be used to create projects from templates, as well as to administrate templates.
	
	.PARAMETER TemplateName
		The name of the template to create
	
	.PARAMETER List
		List the existing templates.
	
	.PARAMETER Help
		Ask for help / documentation.
		Particularly useful when dealing with project types that have a lot of options.
	
	.PARAMETER Force
		Overwrite existing files.
	
	.PARAMETER Name
		The name of the project to create
	
	.PARAMETER Output
		The folder in which to create it.
		Note: This folder will automatically be te root folder of the project.
		If this folder doesn't exist yet, it will be created.
		When used with -Force, it will automatically purge all contents.
	
	.PARAMETER Install
		Install the specified template from the VS marketplace.
	
	.PARAMETER Uninstall
		Uninstall an installed template.
	
	.PARAMETER Arguments
		Additional arguments to pass to the application.
		Generally used for parameters when creating a project from a template.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> dotnetnew -l
	
		Lists all installed templates.
	
	.EXAMPLE
		PS C:\> dotnetnew mvc foo F:\temp\projects\foo -au Windows --no-restore
	
		Creates a new MVC project named "foo" in folder "F:\Temp\projects\foo"
		- It will set authentication to windows
		- It will skip the automatic restore of the project on create
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [Alias('dotnetnew')]
	[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Create')]
	Param (
		[Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Create')]
		[Parameter(Position = 0, ParameterSetName = 'List')]
		[string]
		$TemplateName,
		
		[Parameter(ParameterSetName = 'List')]
		[Alias('l')]
		[switch]
		$List,
		
		[Alias('h')]
		[switch]
		$Help,
		
		[switch]
		$Force,
		
		[Parameter(Position = 1, ParameterSetName = 'Create')]
		[Alias('n')]
		[string]
		$Name,
		
		[Parameter(Position = 2, ParameterSetName = 'Create')]
		[Alias('o')]
		[string]
		$Output,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Install')]
		[Alias('i')]
		[string]
		$Install,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Uninstall')]
		[Alias('u')]
		[string]
		$Uninstall,
		
		[Parameter(ValueFromRemainingArguments = $true)]
		[Alias('a')]
		[string[]]
		$Arguments
	)
	
	begin
	{
		$parset = $PSCmdlet.ParameterSetName
		Write-PSFMessage -Level InternalComment -Message "Active parameterset: $parset" -Tag 'start'
		
		if (-not (Get-Command dotnet.exe))
		{
			throw "Could not find dotnet.exe! This should automatically be available on machines with Visual Studio installed."
		}
		
		$dotNetArgs = @()
		switch ($parset)
		{
			'Create'
			{
				if (Test-PSFParameterBinding -ParameterName TemplateName) { $dotNetArgs += $TemplateName }
				if ($Help) { $dotNetArgs += "-h" }
				if (Test-PSFParameterBinding -ParameterName Name)
				{
					$dotNetArgs += "-n"
					$dotNetArgs += $Name
				}
				if (Test-PSFParameterBinding -ParameterName Output)
				{
					$dotNetArgs += "-o"
					$dotNetArgs += $Output
				}
				if ($Force) { $dotNetArgs += "--Force" }
			}
			'List'
			{
				if (Test-PSFParameterBinding -ParameterName TemplateName) { $dotNetArgs += $TemplateName }
				$dotNetArgs += '-l'
				if ($Help) { $dotNetArgs += "-h" }
			}
			'Install'
			{
				$dotNetArgs += '-i'
				$dotNetArgs += $Install
				if ($Help) { $dotNetArgs += '-h'}
			}
			'Uninstall'
			{
				$dotNetArgs += '-u'
				$dotNetArgs += $Uninstall
				if ($Help) { $dotNetArgs += '-h' }
			}
		}
		
		foreach ($item in $Arguments)
		{
			$dotNetArgs += $item
		}
		Write-PSFMessage -Level Verbose -Message "Resolved arguments: $($dotNetArgs -join " ")" -Tag 'argument','start'
	}
	process
	{
		if ($PSCmdlet.ShouldProcess("dotnet", "Perform action: $parset"))
		{
			if ($parset -eq 'Create')
			{
				if ($Output)
				{
					if ((Test-Path $Output) -and $Force) { $null = New-Item $Output -ItemType Directory -Force -ErrorAction Stop }
					if (-not (Test-Path $Output)) { $null = New-Item $Output -ItemType Directory -Force -ErrorAction Stop }
				}
			}
			Write-PSFMessage -Level Verbose -Message "Executing with arguments: $($dotNetArgs -join " ")" -Tag 'argument', 'start'
			& dotnet.exe new $dotNetArgs
		}
	}
}