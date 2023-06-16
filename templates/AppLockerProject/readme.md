# þnameþ

Add your project description here. Configuration data can be generated using
the build dependency `AppLockerFoundry`.

```powershell
Get-ChildItem -Path "C:\Program Files" -Recurse -Filter *.exe | Get-AlfYamlFileInfo
```

## Build and release workflow

The integrated build workflows for GitHub and Azure DevOps (Server) can be
used out-of-the-box, nearly. If you want to publish your policies in a domain
environment, you will ned to run your build worker with an account
that is capable of updating the required policy objects. This is
due to constraints with the AppLocker cmdlets and their missing capability to specify
alternative credentials.

The ideal workflow should you need or want to build it your self would look like this:

1. Ensure prerequisites `.\build\prerequisites.ps1`
1. Validate Configuration Data: `.\build\validate.ps1 -TestType ConfigurationData`
1. Build policies and optional RSOP from configuration data: `.\build\build.ps1 -IncludeRsop`
1. Validate Integration into environment: `.\build\validate.ps1 -TestType Integration`
1. Publish:  `.\build\publish.ps1`

## Advanced setup

Most CI tools support a concept like Environments to which you can attach certain
gates like a manual approval or a scheduled release in a specific time frame. Play
around with this a little bit to further improve your AppLocker pipeline.
