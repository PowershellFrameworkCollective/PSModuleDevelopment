Describe "þnameþ Unit Tests" -Tag "Unit" {
	BeforeAll {
		# Place here all things needed to prepare for the tests
	}
	AfterAll {
		# Here is where all the cleanup tasks go
	}
	
	Describe "Ensuring unchanged command signature" {
		It "should have the expected parameter sets" {
			(Get-Command þnameþ).ParameterSets.Name | Should -Be þ{ ((Get-Command $Parameters.Name).ParameterSets.Name | ForEach-Object { "'{0}'" -f $_ }) -join ', ' }þ
		}
		
þ{
			$lines = @()
			$commonParameters = 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'Confirm', 'WhatIf'
			foreach ($parameter in ((Get-Command $Parameters.Name).Parameters.Values | Where-Object Name -NotIn $commonParameters))
			{
				$lines += "		It 'Should have the expected parameter $($parameter.Name)' {"
				$lines += "			`$parameter = (Get-Command $($Parameters.Name)).Parameters['$($parameter.Name)']"
				$lines += "			`$parameter.Name | Should -Be '$($parameter.Name)'"
				$lines += "			`$parameter.ParameterType.ToString() | Should -Be $($parameter.ParameterType.ToString())"
				$lines += "			`$parameter.IsDynamic | Should -Be `$$($parameter.IsDynamic)"
				$lines += "			`$parameter.ParameterSets.Keys | Should -Be $(($parameter.ParameterSets.Keys | ForEach-Object { "'{0}'" -f $_ }) -join ', ')"
				foreach ($key in $parameter.ParameterSets.Keys)
				{
					$lines += "			`$parameter.ParameterSets.Keys | Should -Contain '$($key)'"
					$lines += "			`$parameter.ParameterSets['$($key)'].IsMandatory | Should -Be `$$($parameter.ParameterSets[$key].IsMandatory)"
					$lines += "			`$parameter.ParameterSets['$($key)'].Position | Should -Be $($parameter.ParameterSets[$key].Position)"
					$lines += "			`$parameter.ParameterSets['$($key)'].ValueFromPipeline | Should -Be `$$($parameter.ParameterSets[$key].ValueFromPipeline)"
					$lines += "			`$parameter.ParameterSets['$($key)'].ValueFromPipelineByPropertyName | Should -Be `$$($parameter.ParameterSets[$key].ValueFromPipelineByPropertyName)"
					$lines += "			`$parameter.ParameterSets['$($key)'].ValueFromRemainingArguments | Should -Be `$$($parameter.ParameterSets[$key].ValueFromRemainingArguments)"
				}
				$lines += "		}"
			}
			$lines -join "`n"
		}þ
	}
	
þ{
		$commonParameters = 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'Confirm', 'WhatIf'
		foreach ($parameterSet in (Get-Command $Parameters.Name).ParameterSets)
		{
			$name = $parameterSet.Name
			$allParam = $parameterSet.Parameters | Where-Object Name -NotIn $commonParameters
			$mandatory = $allParam | Where-Object IsMandatory -EQ $true
			
			@"
	Describe "Testing parameterset $($name)" {
		<#
		$($parameterSet.Name) -$($mandatory.Name -join " -")
		$($parameterSet.Name) -$($allParam.Name -join " -")
		#>
	}

"@
		}
	}þ
}