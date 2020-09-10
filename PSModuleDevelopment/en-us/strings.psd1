@{
	'Convert-PSMDMessage.Parameter.NonAffected'	       = 'No commands found that should be switched to strings in {0}' # $Path
	'Convert-PSMDMessage.SyntaxError'				   = 'Syntax error in result after converting the file {0}. Please validate your file and if it is valid, file an issue with the source file it failed to convert' # $Path
	
	'Get-PSMDFileCommand.SyntaxError'				   = 'Syntax error in file: {0}' # $pathItem
	
	'MeasurePSMDLinesOfCode.Processing'			       = 'Processing Path: {0}' # $fileItem
	
	'Publish-PSMDScriptFile.Module.Saving'			   = 'Saving module {0} from repository {1}' # $moduleName, (Get-PSFConfigValue -FullName 'PSModuleDevelopment.Script.StagingRepository')
	'Publish-PSMDScriptFile.Script.Command'		       = 'Processing command {0} (used {1} times) from module {2}' # $command.Name, $command.Count, $command.Module
	'Publish-PSMDScriptFile.Script.Command.NotKnown'   = 'The command {0} (used {1} times) cannot be resolved. Manually figure out where it came from if needed.' # $command.Name, $command.Count
	'Publish-PSMDScriptFile.Script.ParseError'		   = 'Syntax error in file: {0}' # $Path
	
	'Publish-PSMDStagedModule.Module.AlreadyPublished' = 'The module {0} at version {1} has already been published to this repository' # $moduleToPublish.Name, $moduleToPublish.Version
	'Publish-PSMDStagedModule.Module.NotFound'		   = 'The module {0} could not be found' # $Name
	'Publish-PSMDStagedModule.Module.PublishError'	   = 'Error publishing {0} from {1}' # $Name, $folder.Name
	
	'Remove-PSMDTemplate.Removing.Template'		       = 'Removing template {0} (v{1}) from store {2}' # $item.Name, $item.Version, $item.Store
	
	'Validate.File'								       = 'Path does not exist or is not a file: {0}' # <user input>, <validation item>
	'Validate.Path'								       = 'Path does not exist: {0}' # <user input>, <validation item>
}