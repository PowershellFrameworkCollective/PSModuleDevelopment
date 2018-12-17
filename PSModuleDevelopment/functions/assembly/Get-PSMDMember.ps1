function Get-PSMDMember
{
<#
.ForwardHelpTargetName Microsoft.PowerShell.Utility\Get-Member
.ForwardHelpCategory Cmdlet
#>
	[CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113322', RemotingCapability = 'None')]
	param (
		[Parameter(ValueFromPipeline = $true)]
		[psobject]
		$InputObject,
		
		[Parameter(Position = 0)]
		[ValidateNotNullOrEmpty()]
		[string[]]
		$Name,
		
		[Alias('Type')]
		[System.Management.Automation.PSMemberTypes]
		$MemberType,
		
		[System.Management.Automation.PSMemberViewTypes]
		$View,
		
		[string]
		$ArgumentType,
		
		[string]
		$ReturnType,		
		
		[switch]
		$Static,
		
		[switch]
		$Force
	)
	
	begin
	{
		try
		{
			$outBuffer = $null
			if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
			{
				$PSBoundParameters['OutBuffer'] = 1
			}
			if ($ArgumentType) { $PSBoundParameters.Remove("ArgumentType") }
			if ($ReturnType) { $PSBoundParameters.Remove("ReturnType") }
			$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Get-Member', [System.Management.Automation.CommandTypes]::Cmdlet)
			$scriptCmd = { & $wrappedCmd @PSBoundParameters }
			$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
			$steppablePipeline.Begin($true)
		}
		catch
		{
			throw
		}
		
		function Split-Member
		{
			[CmdletBinding()]
			param (
				[Parameter(ValueFromPipeline = $true)]
				[Microsoft.PowerShell.Commands.MemberDefinition]
				$Member
			)
			
			process
			{
				if ($Member.MemberType -notlike "Method") { return $Member }
				
				if ($Member.Definition -notlike "*), *") { return $Member }
				
				foreach ($definition in $Member.Definition.Replace("), ", ")þþþ").Split("þþþ"))
				{
					if (-not $definition) { continue }
					New-Object Microsoft.PowerShell.Commands.MemberDefinition($Member.TypeName, $Member.Name, $Member.MemberType, $definition)
				}
			}
		}
		
	}
	
	process
	{
		try
		{
			$members = $steppablePipeline.Process($_) | Split-Member
			
			if ($ArgumentType)
			{
				$tempMembers = @()
				foreach ($member in $members)
				{
					if ($member.MemberType -notlike "Method") { continue }
					
					if (($member.Definition -split "\(",2)[1] -match $ArgumentType) { $tempMembers += $member }
				}
				$members = $tempMembers
			}
			
			if ($ReturnType)
			{
				$members = $members | Where-Object Definition -match "^$ReturnType"
			}
			
			$members
		}
		catch
		{
			throw
		}
	}
	
	end
	{
		try
		{
			$steppablePipeline.End()
		}
		catch
		{
			throw
		}
	}
}