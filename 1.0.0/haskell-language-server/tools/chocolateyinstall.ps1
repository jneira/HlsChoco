
# https://github.com/haskell/haskell-language-server/releases/download/1.0.0/haskell-language-server-Windows-8.10.4.exe.zip
$version         = '1.0.0'
$ghcVersion      = '8.10.4'
$packageName     = 'haskell-language-server'
$binRoot         = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageFullName = Join-Path $binRoot "$packageName-$version"
$urlDownload     = "https://github.com/haskell/$packageName/releases/download"
$checkSum64      = 'BC88E03232C64C776BD7A9C7453DBEBA9558E0C736A8B2CFDADD869C89D9556D'
function Get-HlsInstallUrl($ghcVersion) {
  return "$urlDownload/$version/$packageName-Windows-$ghcVersion.exe.zip"
}

$installUrl      =  Get-HlsInstallUrl $ghcVersion
$ErrorActionPreference = 'Stop'; # stop on all errors

Install-ChocolateyZipPackage `
  -PackageName $packageName -UnzipLocation $packageFullName `
  -Url64bit $installUrl -ChecksumType64 sha256 -Checksum64 $checkSum64

Write-Host "Downloading haskell-language-server-wrapper"
Write-Host "It will be used to use "

$wrapperName       = "$packageName-wrapper"
$zipFile           = "$wrapperName-Windows.exe.zip"
$urlWrapper64      = "$urlDownload/$version/$zipFile"
$checksumWrapper64 = 'EB93F3569B23C2CF46C07D4D324FBBC01E99694227BCF3CB78D7D5DF2F56C8FC'

Install-ChocolateyZipPackage `
  -PackageName $packageName -UnzipLocation $packageFullName `
  -Url64bit $urlWrapper64 -ChecksumType64 sha256 -Checksum64 $checkSumWrapper64

