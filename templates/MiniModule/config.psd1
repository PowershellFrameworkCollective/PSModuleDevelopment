<#
Project Configuration File
#>
@{
	# Automatically determine the new version of the module, based on what has currently been released in the specified repository
	AutoVersion = $false

	# Automatically publish all functions stored under the `functions` folder
	# Enabling this removes the need to manually maintain the list of functions to export in the module manifest
	ExportFunctions = $false

	# Whether a successful publishing should also lead to creating a Release on Github
	GithubRelease = $true
}