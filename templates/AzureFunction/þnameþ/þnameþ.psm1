$script:moduleRoot = $PSScriptRoot
foreach ($file in Get-ChildItem $PSScriptRoot\internal\functions -Recurse -Filter '*.ps1') {
    . $file.FullName
}
foreach ($file in Get-ChildItem $PSScriptRoot\functions -Recurse -Filter '*.ps1') {
    . $file.FullName
}
foreach ($file in Get-ChildItem $PSScriptRoot\internal\scripts -Recurse -Filter '*.ps1') {
    . $file.FullName
}