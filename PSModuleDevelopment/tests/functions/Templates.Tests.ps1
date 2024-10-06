Describe "Verifying templating component" {
	BeforeAll {
		$outPath = [System.IO.Path]::GetTempPath().Trim("\/")
		$resourcePath = Resolve-PSFPath -Path "$PSScriptRoot\..\resources"
		$templateName = 'TestTemplate-{0}' -f (Get-Random)
	}
	AfterAll {
		Remove-Item -Path "$outPath\Test.txt" -ErrorAction Ignore
	}

	It "Should Record the template correctly" {
		{ New-PSMDTemplate -TemplateName $templateName -FilePath "$resourcePath\þnameþ.txt" -OutPath $outPath -EnableException -ErrorAction Stop } | Should -Not -Throw
		$templateInfo = Get-PSMDTemplate -TemplateName $templateName -Path $outPath
		$templateRaw = Import-PSFClixml -Path $templateInfo.Path
		try { $template = [PSModuleDevelopment.Template.Template]$templateRaw }
		catch {
			Write-Warning "Conversion to template Failed!"
			Write-Warning "======================================================================="
			$_ | Format-List -Force | Out-Host
			Write-Warning "======================================================================="
			$_.Exception | Format-List -Force | Out-Host
			Write-Warning "======================================================================="
			throw
		}
		$template.Name | Should -Be $templateName
		$template.Parameters.Count | Should -Be 1
		$template.Scripts.Count | Should -Be 1
		$template.Scripts.Values.ScriptBlock | Should -BeOfType ([scriptblock])
	}

	It "Should Invoke the template correctly" {
		{ Invoke-PSMDTemplate -TemplateName $templateName -Path $outPath -OutPath $outPath -Name Test -EnableException } | Should -Not -Throw
		$content = Get-Content -Path "$outPath\Test.txt" -ErrorAction Stop
		$values = $content | ConvertFrom-StringData -ErrorAction Stop
		$values.Name | Should -Be Test
		$values.Value | Should -Be '123'
	}

	It "Should Remove the template correctly" {
		{ Remove-PSMDTemplate -TemplateName $templateName -EnableException -Confirm:$false } | Should -Not -Throw
		Get-PSMDTemplate -TemplateName $templateName | Should -BeNullOrEmpty
	}
}