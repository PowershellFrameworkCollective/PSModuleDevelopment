# Input bindings are passed in via param block.
param ($Timer)

$ErrorActionPreference = 'Stop'
Write-Host "%COMMAND% start time: $((Get-Date).ToUniversalTime())"
try { %COMMAND% }
catch {
	Write-Warning "%COMMAND% failed: $_ $((Get-Date).ToUniversalTime())"
	throw "%COMMAND% failed: $_ $((Get-Date).ToUniversalTime())"
}
Write-Host "%COMMAND% end time: $((Get-Date).ToUniversalTime())"