BeforeDiscovery {
    if (Get-DatumRsopCache)
    {
        Clear-DatumRsopCache
    }

    $policies = foreach ($file in (Get-ChildItem -Path (Resolve-Path "$global:testroot\..\configurationdata\Policies").Path -Recurse -Filter *.y*ml -File))
    {
        @{
            Name   = $file.BaseName
            Domain = $file.Directory.Name
        }
    }
}

Describe "Policy exists" {
    It "<Name> Policy exists in <Domain>" -TestCases $policies {
        $gpo = Get-GPO -Name $Name -Domain $Domain
        $ctx = [System.DirectoryServices.ActiveDirectory.DirectoryContext]::new('Domain', $Domain)
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($ctx)
        $domainDn = $domain.GetDirectoryEntry().DistinguishedName
        $appLockerGpo = try
        {
            Get-AppLockerPolicy -Domain -Ldap "LDAP://CN={$($gpo.Id)},CN=Policies,CN=System,$domainDn" -ErrorAction Stop
        }
        catch {} # Suppress exception from misbehaving cmdlet that does not like SilentlyContinue
        $appLockerGpo.RuleCollections | Should -Not -BeNullOrEmpty
    }
}
