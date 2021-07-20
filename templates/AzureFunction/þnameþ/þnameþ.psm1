foreach ($file in Get-ChildItem $PSScriptRoot\functions -Recurse -Filter '*.ps1') {
    . $file.FullName
}