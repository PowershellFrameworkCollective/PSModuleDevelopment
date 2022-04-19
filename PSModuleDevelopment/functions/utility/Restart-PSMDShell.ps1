function Restart-PSMDShell {
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
    #>
	[Alias('rss', 'Restart-Shell')]
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	Param (
		[Switch]
		$NoExit,
		
		[Switch]
		$Admin,
		
		[switch]
		$NoProfile
	)
	
	begin {
		$process = Get-Process -Id $pid
		$powershellPath = $process.Path
		$isWindowsTerminal = $process.Parent.ProcessName -eq 'WindowsTerminal'
	}
	process {
		if (-not $PSCmdlet.ShouldProcess("Current shell", "Restart")) { return }

		if ($isWindowsTerminal) {
			$psVersionName = 'powershell'
			if ($PSVersionTable.PSVersion.Major -gt 5) { $psVersionName = 'pwsh' }

			$param = @{
				FilePath = 'wt'
				ArgumentList = @('-w', 0, 'nt','--title', $psVersionName, $powershellPath)
			}
			if ($NoProfile) { $param.ArgumentList = @('-w', 0, 'nt', '--title', $psVersionName, $powershellPath, '-NoProfile') }
			if ($Admin) { $param.Verb = 'RunAs' }
			Start-Process @param
		}
		else {
			$param = @{
				FilePath = $powershellPath
			}
			if ($NoProfile) { $param.ArgumentList = '-NoProfile' }
			if ($Admin) { $param.Verb = 'RunAs' }
			Start-Process @param
		}
	}
	end {
		if (-not $NoExit) { exit }
	}
}