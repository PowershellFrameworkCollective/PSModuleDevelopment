BeforeDiscovery {
    if (Get-DatumRsopCache)
    {
        Clear-DatumRsopCache
    }

    $datum = New-DatumStructure -DefinitionFile (Join-Path "$global:testroot\..\configurationdata" Datum.yml)
    [hashtable[]] $rsops = (Get-DatumRsop $datum (Get-DatumNodesRecursive -AllDatumNodes $Datum.AllNodes)).RuleCollections.Values.Rules
}

Describe "RSOP correctness" {
    It "<Name> Policy rule has SID" -TestCases $rsops {
        $UserOrGroupSid | Should -Not -BeNullOrEmpty
    }
}
