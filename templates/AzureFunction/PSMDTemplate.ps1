@{
    TemplateName         = 'AzureFunction'
    Version              = "2.0.5"
    AutoIncrementVersion = $true
    Tags                 = 'azure', 'function'
    Author               = 'Friedrich Weinmann'
    Description          = 'Basic Azure Function Template'
    Exclusions           = @("PSMDInvoke.ps1", ".PSMDDependency") # Contains list of files - relative path to root - to ignore when building the template
    Scripts              = @{ }
    NoFolder             = $true # Whether invoking this template should generate a new folder ... or not.
}