﻿Describe "Verifying templating component" {
	BeforeAll {
		$tmpFolder = New-PSFTempDirectory -Name Template -ModuleName PSModuleDevelopment
		$resourcePath = Resolve-PSFPath -Path "$PSScriptRoot\..\resources"
		$templateName = 'TestTemplate-{0}' -f (Get-Random)
	}
	AfterAll {
		Write-Host "Path: $resourcePath"
		Remove-PSFTempItem -Name Template -ModuleName PSModuleDevelopment
	}

	It "Should Record the template correctly" {
		{ New-PSMDTemplate -TemplateName $templateName -FilePath "$resourcePath\þnameþ.txt" -EnableException -ErrorAction Stop } | Should -Not -Throw
		$templateInfo = Get-PSMDTemplate -TemplateName $templateName
		$templateRaw = Import-PSFClixml -Path $templateInfo.Path
		$template = [PSModuleDevelopment.Template.Template]$templateRaw
		$template.Name | Should -Be $templateName
		$template.Parameters.Count | Should -Be 1
		$template.Scripts.Count | Should -Be 1
		$template.Scripts.Values.ScriptBlock | Should -BeOfType ([scriptblock])
	}

	It "Should Invoke the template correctly" {
		{ Invoke-PSMDTemplate -TemplateName $templateName -OutPath $tmpFolder -Name Test -EnableException } | Should -Not -Throw
		$content = Get-Content -Path "$tmpFolder\Test.txt" -ErrorAction Stop
		$values = $content | ConvertFrom-StringData -ErrorAction Stop
		$values.Name | Should -Be Test
		$values.Value | Should -Be '123'
	}

	It "Should Remove the template correctly" {
		{ Remove-PSMDTemplate -TemplateName $templateName -EnableException -Confirm:$false } | Should -Not -Throw
		Get-PSMDTemplate -TemplateName $templateName | Should -BeNullOrEmpty
	}
}