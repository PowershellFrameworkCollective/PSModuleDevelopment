function Measure-PSMDCommand
{
	
	<#
		.SYNOPSIS
			Measures command performance with consecutive tests.
		
		.DESCRIPTION
			This function measures the performance of a scriptblock many consective times.
	
			Warning: Running a command repeatedly may not yield reliable information, since repeated executions may benefit from caching or other performance enhancing features, depending on the script content.
			This is best suited for measuring the performance of tasks that will later be run repeatedly as well.
			It also is useful for mitigating local performance fluctuations when comparing performances.
	
		PARAMETER ScriptBlock
			The scriptblock whose performance is to be measure.
	
		PARAMETER Iterations
			How many times should this performance test be repeated.
	
		.PARAMETER TestSet
			Accepts a hashtable, mapping a name to a specific scriptblock to measure.
			This will generate a result grading the performance of the various sets offered.
		
		.EXAMPLE
			PS C:\> Measure-PSMDCommand -ScriptBlock { dir \\Server\share } -Iterations 100
	
			This tries to use Get-ChildItem on a remote directory 100 consecutive times, then measures performance and reports common performance indicators (Average duration, Maximum, Minimum, Total)
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Script')]
		[scriptblock]
		$ScriptBlock,
		
		[int]
		$Iterations = 1,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Set')]
		[hashtable]
		$TestSet
	)
	
	Process
	{
		#region Running an individual testrun
		if ($ScriptBlock)
		{
			[System.Collections.ArrayList]$results = @()
			$count = 0
			while ($count -lt $Iterations)
			{
				$null = $results.Add((Measure-Command -Expression $ScriptBlock))
				$count++
			}
			$measured = $results | Measure-Object -Maximum -Minimum -Average -Sum -Property Ticks
			[pscustomobject]@{
				PSTypeName = 'PSModuleDevelopment.Performance.TestResult'
				Results = $results.ToArray()
				Max	    = (New-Object System.TimeSpan($measured.Maximum))
				Sum	    = (New-Object System.TimeSpan($measured.Sum))
				Min	    = (New-Object System.TimeSpan($measured.Minimum))
				Average = (New-Object System.TimeSpan($measured.Average))
			}
		}
		#endregion Running an individual testrun
		
		#region Performing a testset
		if ($TestSet)
		{
			$setResult = @{ }
			foreach ($testName in $TestSet.Keys)
			{
				$setResult[$testName] = Measure-PSMDCommand -ScriptBlock $TestSet[$testName] -Iterations $Iterations
			}
			$fastestResult = $setResult.Values | Sort-Object Average | Select-Object -First 1
			
			$finalResult = foreach ($setName in $setResult.Keys)
			{
				$resultItem = $setResult[$setName]
				[pscustomobject]@{
					PSTypeName = 'PSModuleDevelopment.Performance.TestSetItem'
					Name = $setName
					Efficiency = $resultItem.Average.Ticks / $fastestResult.Average.Ticks
					Average    = $resultItem.Average
					Result	   = $resultItem
					
				}
			}
			$finalResult | Sort-Object Efficiency
		}
		#endregion Performing a testset
	}
}