BeforeDiscovery {
    $yamlFiles = Get-ChildItem -Path "$global:testroot\..\configurationdata" -Filter *.ym*l -Recurse -File | Foreach-Object { 
        @{
            FullName = $_.FullName
            BaseName = $_.BaseName
            Name     = $_.Name 
        } 
    }
}

Describe "YAML file integrity" {
    It "<Name> Convert from YAML without errors" -TestCases $yamlFiles {
        { Get-Content -Raw -Path $FullName | ConvertFrom-Yaml -ErrorAction Stop } | Should -Not -Throw
    }

    It "<Name> Contains only valid rule types" -TestCases $yamlFiles {
        $types = 'Dll', 'Exe', 'Msi', 'Script', 'Appx'

        $content = Get-Content -Raw -Path $FullName | ConvertFrom-Yaml -ErrorAction SilentlyContinue

        if (-not $content.ContainsKey('RuleCollections'))
        {
            return
        }

        $content.RuleCollections.Keys | Foreach-Object { $_ | Should -BeIn $types }
    }
}
