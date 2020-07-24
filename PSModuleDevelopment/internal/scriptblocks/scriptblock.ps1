Set-PSFScriptblock -Name PSModuleDevelopment.Validate.Path -Scriptblock {
	Test-Path $_
}
Set-PSFScriptblock -Name PSModuleDevelopment.Validate.File -Scriptblock {
	Test-Path $_ -PathType Leaf
}