$version         = '1.0.0'
$packageName     = 'haskell-language-server'
$ghcVersions     = ("8.10.4", "8.8.4", "8.6.5")
$binRoot         = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageFullName = Join-Path $binRoot "$packageName-$version"
$urlDownload     = "https://github.com/haskell/$packageName/releases/download"

$checkSums64=@{}
$checkSums64['8.10.4'] = 'BC88E03232C64C776BD7A9C7453DBEBA9558E0C736A8B2CFDADD869C89D9556D'
$checkSums64["8.8.4"]  = '3E90F588641CECBC59128DBEA31181BC97EE2347BEE6D5D3F6DBC8B48560D8DC'
$checkSums64["8.6.5"]  = '5A63124FA98CC5D6F28723383E010FE002E83A9D15B6F3EA4586C2033A3BEC4F'

$ErrorActionPreference = 'Stop'; # stop on all errors

function Get-MinorVersion($ghcVersion) {
  $minorVersion = $ghcVersion | Select-String -pattern "\d+\.\d+"
  return $minorVersion.Matches.Value
}

function Get-HlsInstallInfo($ghcVersion) {
  $info           = @{}
  $info.url       = "$urlDownload/$version/$packageName-Windows-$ghcVersion.exe.zip"
  $info.exePath   = Join-Path $packageFullName "$packageName-$ghcVersion.exe"
  $info.finalName = "$packageName-$(Get-MinorVersion($ghcVersion)).exe"
  $info.checkSum  = $checkSums64[$ghcVersion]
  return $info
}

function Install-Hls($ghcVersion) {

  $info = Get-HlsInstallInfo($ghcVersion)

  Install-ChocolateyZipPackage `
    -PackageName $packageName -UnzipLocation $packageFullName `
    -Url64bit $info.url -ChecksumType64 sha256 -Checksum64 $info.checksum

  Rename-Item $info.exePath $info.finalName
}

ForEach ($ghcVersion in $ghcVersions) {
  Install-Hls $ghcVersion
}

Write-Host "Downloading haskell-language-server-wrapper"

$wrapperName       = "$packageName-wrapper"
$zipFile           = "$wrapperName-Windows.exe.zip"
$urlWrapper64      = "$urlDownload/$version/$zipFile"
$checksumWrapper64 = 'EB93F3569B23C2CF46C07D4D324FBBC01E99694227BCF3CB78D7D5DF2F56C8FC'

Install-ChocolateyZipPackage `
  -PackageName $packageName -UnzipLocation $packageFullName `
  -Url64bit $urlWrapper64 -ChecksumType64 sha256 -Checksum64 $checkSumWrapper64
