[CmdletBinding()]
Param (
	[switch]
	$SkipTest,

	[string[]]
	$CommandPath = @("$global:testroot\..\functions", "$global:testroot\..\internal\functions")
)

BeforeDiscovery {
	if ($SkipTest) { return }

	$global:__pester_data.ScriptAnalyzer = New-Object System.Collections.ArrayList

	# Create an array containing the path and basename of all files to test
	$commandFiles = $CommandPath | ForEach-Object {
		Get-ChildItem -Path $_ -Recurse | Where-Object Name -like "*.ps1"
	} | ForEach-Object {
		@{
			BaseName = $_.BaseName
			FullName = $_.FullName
		}
	}

	# Create an array contain all rules
	$scriptAnalyzerRules = Get-ScriptAnalyzerRule | ForEach-Object {
		@{
			RuleName = $_.RuleName
		}
	}
}

Describe 'Invoking PSScriptAnalyzer against commandbase' {

	Context "Analyzing <BaseName>" -ForEach $commandFiles {
		BeforeAll {
			$analysis = Invoke-ScriptAnalyzer -Path $FullName -ExcludeRule PSAvoidTrailingWhitespace, PSShouldProcess
		}

		It "Should pass <RuleName>" -Foreach $scriptAnalyzerRules {
			# Test if the rule is present and if so create a string containing more info which will be shown in the details of the test output. If it's empty the test is succesfull as there is no problem with this rule.
			$analysis | Where-Object RuleName -EQ $RuleName | Foreach-Object {
				# Create a string
				"$($_.Severity) at Line $($_.Line) Column $($_.Column) with '$($_.Extent)'"
				# Add the data (and supress the output) to the global variable for later use
				$null = $global:__pester_data.ScriptAnalyzer.Add($_)
			} | Should -BeNullOrEmpty
		}
	}
}