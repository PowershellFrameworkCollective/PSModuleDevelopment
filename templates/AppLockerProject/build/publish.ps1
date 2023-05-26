param
(
    [string]
    $OutputPath = (Resolve-Path "$PSScriptRoot\..\output").Path
)

foreach ($policy in (Get-ChildItem -Path (Join-Path -Path $OutputPath -ChildPath Policies) -Recurse -Filter *.xml))
{
    $searcher = [adsisearcher]::new()
    $searcher.Filter = "(&(objectClass=groupPolicyContainer)(displayName=$($policy.BaseName)))"
    $policyFound = $searcher.FindOne()

    if (-not $policyFound)
    {
        $null = New-GPO -Name $policy.BaseName -Comment "Auto-updated applocker policy" -Domain $policy.Directory.Name
    }

    $policyFound = $searcher.FindOne()

    Set-AppLockerPolicy -XmlPolicy (Get-Content -Path $policy.FullName) -Ldap $policyFound.Path
}
