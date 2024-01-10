@{
    PSDependOptions       = @{
        AddToPath  = $false
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository      = 'PSGallery'
            AllowPreRelease = $true
        }
    }

    'powershell-yaml'     = '0.4.7'
    PSScriptAnalyzer      = '1.21.0'
    Pester                = '5.4.1'
    'Sampler.DscPipeline' = '0.2.0-preview0015' # Unfortunately still in preview
    Datum                 = '0.40.1'
    'Datum.InvokeCommand' = '0.3.0'
    AppLockerFoundry      = '1.1.5'
}
