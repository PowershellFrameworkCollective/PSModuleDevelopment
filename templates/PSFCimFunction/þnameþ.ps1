function þnameþ
{
<#
	.SYNOPSIS
		<Insert Synopsis here>.
	
	.DESCRIPTION
		<Insert Description here>.
	
	.PARAMETER ComputerName
		The computer(s) to connect to.
		Can be an established CimSession, which will then be reused.
	
	.PARAMETER Credential
		The credentials to use to connect to remote computer(s) with.
		This parameter is ignored for local queries.
		This parameter is ignored if passing an established Cim Session for ComputerName.
	
	.PARAMETER Authentication
		The authentication method to use to when authenticating to remote computer(s).
		Uses the system default settings by default.
		This parameter is ignored for local queries.
		This parameter is ignored if passing an established Cim Session for ComputerName.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> þnameþ
	
		<insert description for local execution>.
	
	.EXAMPLE
		PS C:\> Get-Content servers.txt | þnameþ
	
		<insert description for remote execution from file>
	
	.EXAMPLE
		PS C:\> Get-ADComputer -Filter "name -like 'Desktop*'" | þnameþ
	
		<insert description for remote execution from AD Computer>
#>
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $true)]
		[PSFComputer[]]
		$ComputerName = $env:COMPUTERNAME,
		
		[System.Management.Automation.CredentialAttribute()]
		[System.Management.Automation.PSCredential]
		$Credential,
		
		[Microsoft.Management.Infrastructure.Options.PasswordAuthenticationMechanism]
		$Authentication = [Microsoft.Management.Infrastructure.Options.PasswordAuthenticationMechanism]::Default,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ", ")" -Tag 'debug','start','param'
	}
	process
	{
		#region Process by Computer Name
		foreach ($Computer in $ComputerName)
		{
			#region Remote Connection
			Write-PSFMessage -Level VeryVerbose -Message "[$Computer] Establishing connection" -Target $Computer -Tag 'connect', 'start'
			try
			{
				if (-not $Computer.IsLocalhost)
				{
					if ($Computer.Type -like "CimSession") { $session = $Computer.InputObject }
					else { $session = New-CimSession -ComputerName $Computer -Credential $Credential -Authentication $Authentication -ErrorAction Stop }
					
					# Some dummy code, replace with actual logic
					Write-PSFMessage -Level SomewhatVerbose -Message "[$Computer] Retrieving OS information" -Target $Computer -Tag 'os', 'get'
					$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session -ErrorAction Stop
					
					if ($Computer.Type -notlike "CimSession") { Remove-CimSession -CimSession $session }
				}
				else
				{
					# Some dummy code, replace with actual logic
					# No point in establishing a session to localhost, custom credentials also not supported
					Write-PSFMessage -Level SomewhatVerbose -Message "[$Computer] Retrieving OS information" -Target $Computer -Tag 'os', 'get'
					$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
				}
			}
			catch
			{
				Stop-PSFFunction -Message "[$Computer] Failed to connect to target computer" -Target $Computer -Tag 'connect', 'fail' -ErrorRecord $_ -EnableException $EnableException -Continue
			}
			#endregion Remote Connection
			
			# Dummy data, replace with actual data object to build
			#region Process Data
			$systemInfo = New-Object Fred.IronScripter2018.SystemInformation -Property @{
				ComputerName       = $Computer.ComputerName
				Name		       = $operatingSystem.Caption
				Version	           = $operatingSystem.Version
				ServicePack        = "{0}.{1}" -f $operatingSystem.ServicePackMajorVersion, $operatingSystem.ServicePackMinorVersion
				Manufacturer       = $operatingSystem.Manufacturer
				WindowsDirectory   = $operatingSystem.WindowsDirectory
				Locale		       = $operatingSystem.Locale
				FreePhysicalMemory = $operatingSystem.FreePhysicalMemory * 1024 # Comes in KB
				VirtualMemory      = $operatingSystem.TotalVirtualMemorySize * 1024 # Comes in KB
				FreeVirtualMemory  = $operatingSystem.FreeVirtualMemory * 1024 # Comes in KB
			}
			
			Write-PSFMessage -Level Verbose -Message "[$Computer] Finished gathering information" -Target $Computer -Tag 'success', 'finished'
			$systemInfo
			#endregion Process Data
		}
		#endregion Process by Computer Name
	}
	end
	{
		
	}
}