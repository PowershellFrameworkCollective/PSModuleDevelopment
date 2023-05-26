# Configuration Data

The `configurationdata` directory contains your overall merging configuration `Datum.yml` as
individual folders described in your merging configuration's Resolution Precedence. This
template assumes:

```yaml
ResolutionPrecedence:
  - AllNodes\$($Node.PolicyName)
  - '[x= { $Node.Apps | Foreach-Object {"Apps\$_"} } =]'
  - Domains\$($Node.Domain)
  - Generics\Windows
```

Generic Windows settings are applied first. Those are merged with all domain-specific
settings, taking into consideration which domain the policy is assigned to. Those are then
merged with all App-specific configurations that a policy should contain, and lastly
the policy itself adds its own specific settings like the policy name.

## Apps

The idea is to describe each app in a way that AppLocker knows about all required
binaries. Examine the sample App `Git` to learn more.

## Domains

The idea is to describe content that is relevant for each domain.

## Policies

Grouped by the domain, each policy should be a single yml file that contains
the Name, Domain and subscribed Apps for that policy.

## Generics

Currently only one generic configuration is recommended: Windows. This sample already
contains the recommended content and disables PowerShell 2.
