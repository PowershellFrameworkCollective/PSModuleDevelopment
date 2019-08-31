function Restart-PSMDShell
{
    <#
        .SYNOPSIS
            A swift way to restart the PowerShell console.
        
        .DESCRIPTION
            A swift way to restart the PowerShell console.
            - Allows increasing elevation
            - Allows keeping the current process, thus in effect adding a new PowerShell process
        
        .PARAMETER NoExit
            The current console will not terminate.
        
        .PARAMETER Admin
            The new PowerShell process will be run as admin.
	
		.PARAMETER NoProfile
			The new PowerShell process will not load its profile.
	
		.PARAMETER Confirm
			If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
		
		.PARAMETER WhatIf
			If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
        
        .EXAMPLE
            PS C:\> Restart-PSMDShell
    
            Restarts the current PowerShell process.
    
        .EXAMPLE
            PS C:\> Restart-PSMDShell -Admin -NoExit
    
            Creates a new PowerShell process, run with elevation, while keeping the current console around.
        
        .NOTES
			Version 1.0.0.0
            Author: Friedrich Weinmann
            Created on: August 6th, 2016
    #>
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	Param (
		[Switch]
		$NoExit,
		
		[Switch]
		$Admin,
		
		[switch]
		$NoProfile
	)
	
	begin
	{
		$powershellPath = (Get-Process -id $pid).Path
	}
	process
	{
		if ($PSCmdlet.ShouldProcess("Current shell", "Restart"))
		{
			if ($NoProfile)
			{
				if ($Admin) { Start-Process $powershellPath -Verb RunAs -ArgumentList '-NoProfile' }
				else { Start-Process $powershellPath -ArgumentList '-NoProfile' }
			}
			else
			{
				if ($Admin) { Start-Process $powershellPath -Verb RunAs }
				else { Start-Process $powershellPath }
			}
			if (-not $NoExit) { exit }
		}
	}
}
New-Alias -Name Restart-Shell -Value Restart-PSMDShell -Option AllScope -Scope Global
New-Alias -Name rss -Value Restart-PSMDShell -Option AllScope -Scope Global