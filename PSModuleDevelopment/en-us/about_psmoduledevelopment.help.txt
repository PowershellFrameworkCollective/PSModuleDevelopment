TOPIC
	about_psmoduledevelopment
	
SHORT DESCRIPTION
	Explains how the PSModuleDevelopment module can enhance your module
	development experience

LONG DESCRIPTION
	Welcome to the introductory guide of the PSModuleDevelopment module.
	
	This module is designed to help you develop PowerShell modules faster,
	easier and more reliably, than would otherwise be possible.
	
	For brevity's sake, the module shall henceforth be abbreviated to "PSMD"
	
	
	#-------------------------------------------------------------------------#
	#                                  Index                                  #
	#-------------------------------------------------------------------------#
	
	- The Little Helpers
	- Refactoring
	- Gaming the Type System
	- Multilingual Help
	- The Need for Speed
	- Optimizing the debugging cycle
	
	
	#-------------------------------------------------------------------------#
	#                           The Little Helpers                            #
	#-------------------------------------------------------------------------#
	
	Often it is the small things that make all the difference. PSMD provides a
	few small helpers, that can make all the difference:
	
	# find (Find-PSMDFileContent) #
	#-----------------------------#
	
	"find" allows you to swiftly search the module you are working on. For
	example, the following line:
	
	  find "Get-Test"
	
	Will search the entire module for all instances of "Get-Test"
	
	In order to set this up, you need to point the command to where your module
	is being stored:
	
	  Set-PSMDModulePath -Path "<path to module folder>"
	
	If you want that path to persist across multiple sessions, you can register
	it, which will set the same path again each time you import PSMD:
	
	  Register-PSFConfig -FullName 'PSModuleDevelopment.Module.Path'
	
	# rss (Restart-PSMDShell) #
	#-------------------------#
	
	The best we to reset your test environment is to start a new console. This
	can be cumbersome though ... unless you use PSMD, in which case it is a
	matter of typing "rss" and sending the command.
	You can further use one (or multiple) of its parameters for extra benefit:
	- NoExit: Instead of closing the old console, you clone it
	- Admin: The new console will be started with elevation
	- NoProfile: The new console will not load the user profile
	
	
	#-------------------------------------------------------------------------#
	#                               Refactoring                               #
	#-------------------------------------------------------------------------#
	
	Sometimes you need to fix something at scale. Globally rename a parameter
	maybe? Change the help text for the same parameter across all commands?
	This is where the refactoring suite of commands of PSMD comes into play:
	
	- Rename-PSMDParameter
	- Set-PSMDCmdletBinding
	- Set-PSMDParameterHelp
	- Split-PSMDScriptFile
	
	More detailed guidance on how to use them shall follow in a dedicated
	article, but they already have full Comment Based Help (with examples).
	
	
	#-------------------------------------------------------------------------#
	#                         Gaming the Type System                          #
	#-------------------------------------------------------------------------#
	
	Sometimes we need to look beneath the hood of C# and .NET. This is when the
	suite of commands dealing with assemblies, types at all come in handy.
	
	# New-PSMDFormatTableDefinition
	Give this command any type of object, it will create an XML definition you
	can use in your module to style the layout of your objects.
	
	# Expand-PSMDTypeName
	Returns the full name of the input object's type, as well as the name of
	the types it inherits from, recursively until System.Object.
	
	# Find-PSMDType
	Searches assemblies for types.
	
	# Get-PSMDAssembly
	Returns the assemblies currently loaded.
	
	# Get-PSMDConstructor
	Returns information on the available constructors of a type.
	
	
	#-------------------------------------------------------------------------#
	#                            Multilingual Help                            #
	#-------------------------------------------------------------------------#
	
	In some instances, you may want to provide multilingual help for your
	module. If you're wondering how to do that, here's a guide that will walk
	you through the details:
	
	  https://allthingspowershell.blogspot.com/2016/08/powershell-modules-multilingual-help.html
	
	That said, the PSMD module ships with a command that lets you test out help
	text on commands in multiple languages:
	
	  Get-PSMDHelpEx (Alias: hex)
	
	It comes with a few gotchas (the main one being that PowerShell caches the
	first help retrieved for a command. Testing help in another language
	requires a restart of the console).
	
	
	#-------------------------------------------------------------------------#
	#                           The Need for Speed                            #
	#-------------------------------------------------------------------------#
	
	Speed matters.
	In order to develop high performance code however, you need to have the
	tools to measure speed accurately. PowerShell has out of the box a tool
	that helps with that: 'Measure-Command'
	However, while Measure-Command is powerful (and you really should master it
	if you haven't already), sometimes you need to measure many repetitions of
	code in deeper details. This is where PSMD comes into play with:
	
	  Measure-PSMDCommandEx
	
	It's basically a Measure-Command, but can run the same snippet dozens or
	hundreds of time in a row and measure duration statistics (total, average,
	minimum, ...).
	
	
	#-------------------------------------------------------------------------#
	#                     Optimizing the debugging cycle                      #
	#-------------------------------------------------------------------------#
	
	The module provides, using its *-PSMDModuleDebug commands, a system to
	automatedly perform tests. It can reduce the test workflow in your console
	window to the simple act of restarting the shell.
	
	For more details on how to set up your computer and module for this
	automated testing cycle, see the following blog post:
	
	  https://allthingspowershell.blogspot.com/2016/08/module-development-optimizing-test-and.html
	
KEYWORDS
	module development debugging