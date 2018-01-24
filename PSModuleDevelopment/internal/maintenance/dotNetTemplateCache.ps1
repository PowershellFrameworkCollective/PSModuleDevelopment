$scriptBlock = {
	$webclient = New-Object System.Net.WebClient
	$string = $webclient.DownloadString("http://dotnetnew.azurewebsites.net/")
	$templates = $string -split "`n" | Select-String '<a href="/template/(.*?)/.*?">.*?</a>' | ForEach-Object { $_.Matches.Groups[1].Value } | Select-Object -Unique | Sort-Object
	
	Set-PSFTaskEngineCache -Module PSModuleDevelopment -Name "dotNetTemplates" -Value $templates
}
Register-PSFTaskEngineTask -Name "psmd_dotNetTemplateCache" -ScriptBlock $scriptBlock -Priority Low -Once -Description "Builds up the cache of installable templates for dotnet"