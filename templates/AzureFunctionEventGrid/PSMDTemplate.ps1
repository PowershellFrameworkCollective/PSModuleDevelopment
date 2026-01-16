@{
    TemplateName         = 'AzureFunctionEventGrid'
    Version              = "1.0.0.0"
    AutoIncrementVersion = $true
    Tags                 = 'azure', 'function', 'eventgrid'
    Author               = 'Jan-Hendrik Peters'
    Description          = 'Adds an Event Grid trigger function (function.json + run.ps1) to the base AzureFunction scaffold for handling Azure event notifications'
    Exclusions           = @("PSMDInvoke.ps1", ".PSMDDependency") # Contains list of files - relative path to root - to ignore when building the template
    Scripts              = @{ }
}
