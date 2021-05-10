$version         = '1.0.0.0'
$packageName     = 'haskell-language-server'
$binRoot         = Get-ToolsLocation
$packageFullName = Join-Path $binRoot "$packageName-$version"

Remove-Item -Force -Recurse $packageFullName