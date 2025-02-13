@{
    TemplateName         = 'AzureFunctionEventGrid'
    Version              = "1.0.0.0"
    AutoIncrementVersion = $true
    Tags                 = 'azure', 'function', 'eventgrid'
    Author               = 'Jan-Hendrik Peters'
    Description          = 'Event Grid trigger endpoint for the basic Azure Function Template'
    Exclusions           = @("PSMDInvoke.ps1", ".PSMDDependency") # Contains list of files - relative path to root - to ignore when building the template
    Scripts              = @{ }
}
