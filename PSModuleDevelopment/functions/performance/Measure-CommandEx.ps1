function Measure-CommandEx
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
		
		.EXAMPLE
			PS C:\> Measure-CommandEx -ScriptBlock { dir \\Server\share } -Iterations 100
	
			This tries to use Get-ChildItem on a remote directory 100 consecutive times, then measures performance and reports common performance indicators (Average duration, Maximum, Minimum, Total)
		
		.NOTES
			Supported Interfaces:
			------------------------
			
			Author:       Friedrich Weinmann
			Company:      die netzwerker Computernetze GmbH
			Created:      06.07.2016
			LastChanged:  06.11.2016
			Version:      1.1
		
		.LINK
			Link to Website.
	#>
	[CmdletBinding()]
	Param (
		
	)
	
	
	#region Dynamic Parameter
	<#
		Whoever might read this script will probably wonder: Why use dynamic parameters?
	
	There's a reason:
	Dynamic parameters are included in the $PSBoundParameters automatic variable, but are NOT bound as variables.
	Thus it becomes possible - using dynamic parameters - to provide easy to use parameter names without hiding super-scope variables with the same name.
	Since this is designed to test other pieces of code - some not necessarily isolated functions, but rather only slight pieces of code that use other variables - I tried to
	minimize the footprint of the function internals, so that it will provide as consistent user experience as I can manage.
	#>
	DynamicParam
	{
		# Create the dictionary 
		$______RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		
		#region Prepare ScriptBlock Parameter
		# Create the collection of attributes
		$______AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		
		# Create and set the parameters' attributes
		$______ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
		$______ParameterAttribute.Position = 0
		$______ParameterAttribute.HelpMessage = "The scriptblock whose performance is to be measure."
		
		# Add the attributes to the attributes collection
		$______AttributeCollection.Add($______ParameterAttribute)
		
		# Create parameter and add it to dictionary
		$______RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter("ScriptBlock", [ScriptBlock], $______AttributeCollection)
		$______RuntimeParameterDictionary.Add("ScriptBlock", $______RuntimeParameter)
		#endregion Prepare ScriptBlock Parameter
		
		#region Prepare Iterations Parameter
		# Create the collection of attributes
		$______AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		
		# Create and set the parameters' attributes
		$______ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
		$______ParameterAttribute.Position = 1
		$______ParameterAttribute.HelpMessage = "How many times should this performance test be repeated."
		
		# Add the attributes to the attributes collection
		$______AttributeCollection.Add($______ParameterAttribute)
		
		# Create parameter and add it to dictionary
		$______RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter("Iterations", [Int], $______AttributeCollection)
		$______RuntimeParameter.Value = 1
		$______RuntimeParameterDictionary.Add("Iterations", $______RuntimeParameter)
		#endregion Prepare Iterations Parameter
		
		# Return dynamic parameter
		return $______RuntimeParameterDictionary
	}
	#endregion Dynamic Parameter
	
	Begin
	{
		$______Results = @()
		$______Int = 0
	}
	Process
	{
		while ($______Int -lt $PSBoundParameters["Iterations"])
		{
			$______Results += Measure-Command -Expression $PSBoundParameters["ScriptBlock"]
			$______Int++
		}
	}
	End
	{
		$______hash = @{ }
		$______hash["Results"] = $______Results
		$______hash["Max"] = $______Results | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
		$______hash["Sum"] = $______Results | Select-Object -ExpandProperty Ticks | Measure-Object -Sum | Select-Object -ExpandProperty Sum | ForEach-Object { New-Object System.TimeSpan($_) }
		$______hash["Min"] = $______Results | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
		$______hash["Average"] = $______Results | Select-Object -ExpandProperty Ticks | Measure-Object -Average | Select-Object -ExpandProperty Average | ForEach-Object { New-Object System.TimeSpan($_) }
		
		New-Object System.Management.Automation.PSObject -Property $______hash
	}
}