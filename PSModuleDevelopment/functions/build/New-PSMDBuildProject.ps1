function New-PSMDBuildProject
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true)]
		[PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
		[string]
		$Path,
		
		[string]
		$Condition,
		
		[string]
		$ConditionSet = 'PSFramework Environment',
		
		[switch]
		$NoSelect,
		
		[switch]
		$Register
	)
	
	process
	{
		$project = [pscustomobject]@{
			Name = $Name
			Condition = $Condition
			ConditionSet = $ConditionSet
			Steps = @()
		}
		$outPath = Join-Path -Path $Path -ChildPath "$Name.build.Json"
		$project | ConvertTo-Json -Depth 10 | Set-Content -Path $outPath -Encoding UTF8 -ErrorAction Stop
		if (-not $NoSelect) {
			Set-PSFConfig -Module PSModuleDevelopment -Name 'Build.Project.Selected' -Value $outPath
			if ($Register) { Register-PSFConfig -Module PSModuleDevelopment -Name 'Build.Project.Selected' }
		}
	}
}
