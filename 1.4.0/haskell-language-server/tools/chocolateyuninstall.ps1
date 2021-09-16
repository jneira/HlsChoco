$version         = '1.0.0.0'
$packageName     = 'haskell-language-server'
$binRoot         = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageFullName = Join-Path $binRoot "$packageName-$version"

Remove-Item -Force -Recurse $packageFullName