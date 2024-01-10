param
(
    [string]
    $DependencyPath = (Resolve-Path "$PSScriptRoot\requiredModules.psd1").Path,

    [string]
    $OutputPath = (Resolve-Path "$PSScriptRoot\..\output").Path,

    [string]
    $SourcePath = "$PSScriptRoot\..\configurationdata"
)

$psdependConfig = Import-PowerShellDataFile -Path $DependencyPath
$modPath = Resolve-Path -Path $psdependConfig.PSDependOptions.Target
$modOld = $env:PSModulePath
$pathSeparator = [System.IO.Path]::PathSeparator
$env:PSModulePath = "$modPath$pathSeparator$modOld"
$datum = New-DatumStructure -DefinitionFile (Join-Path $SourcePath Datum.yml)
[hashtable[]] $rsops = Get-DatumRsop $datum (Get-DatumNodesRecursive -AllDatumNodes $Datum.AllNodes)

foreach ($policy in (Get-ChildItem -Path (Join-Path -Path $OutputPath -ChildPath Policies) -Recurse -Filter *.xml))
{
    $searcher = [adsisearcher]::new()
    $searcher.Filter = "(&(objectClass=groupPolicyContainer)(displayName=$($policy.BaseName)))"
    $policyFound = $searcher.FindOne()

    if (-not $policyFound)
    {
        $null = New-GPO -Name $policy.BaseName -Comment "Auto-updated applocker policy" -Domain $policy.Directory.Name
    }

    $rsop = $rsops | Where-Object { $_['PolicyName'] -eq $policy.BaseName }
    foreach ($link in $rsop.Links)
    {
        $param = @{
            Name    = $rsop.PolicyName
            Target  = $link.OrgUnitDn
            Domain  = $policy.Directory.Name
            Confirm = $false
        }

        if ($rsop.ContainsKey('Enabled'))
        {
            $param['LinkEnabled'] = $link.Enabled
        }
        if ($rsop.ContainsKey('Enforced'))
        {
            $param['Enforced'] = $link.Enforced
        }
        if ($rsop.ContainsKey('Order'))
        {
            $param['Order'] = $link.Order
        }

        Set-GPLink @param
    }

    $policyFound = $searcher.FindOne()

    Set-AppLockerPolicy -XmlPolicy $policy.FullName -Ldap $policyFound.Path
}

$env:PSModulePath = $modOld
