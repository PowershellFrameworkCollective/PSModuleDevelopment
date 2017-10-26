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
	[CmdletBinding()]
	Param (
		[Switch]
		$NoExit,
		
		[Switch]
		$Admin
	)
	
	if ($Admin) { Start-Process powershell.exe -Verb RunAs }
	else { Start-Process powershell.exe }
	if (-not $NoExit) { exit }
}
New-Alias -Name Restart-Shell -Value Restart-PSMDShell -Option AllScope -Scope Global
New-Alias -Name rss -Value Restart-PSMDShell -Option AllScope -Scope Global