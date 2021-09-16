$version         = '1.4.0'
$packageName     = 'haskell-language-server'
$binRoot         = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageFullName = Join-Path $binRoot "$packageName-$version"
$urlDownload     = "https://github.com/haskell/$packageName/releases/download"
$pp              = Get-PackageParameters

$supportedGhcVersions  = ("9.0.1", "8.10.7", "8.10.6", "8.10.5","8.10.4", "8.10.3", "8.10.2", "8.8.4", "8.6.5", "8.6.4")

$checkSums64=@{}
$checkSums64['9.0.1']  = '96e1863dc39726a6a0652561097f825716dae02beb7e2dcbb37c62077420764d'
$checkSums64['8.10.7'] = '9a9a0c7d34594ca54b9b276ca747a321edfea86156d9259f9caa6f867ebba907'
$checkSums64['8.10.6'] = '1913d2100d76022bada334f0dbcf1a7ac04b1b60ef63cc2d1b0d372623dc898c'
$checkSums64['8.10.5'] = 'e36cad1b345938f80f036303f1ab6d1d81206e0d29d45f0ff2265b078792495e'
$checkSums64['8.10.4'] = 'fa67caa8ac2eb55f5dc813894f5769aaa1ba252933652fdc0ae86e69a6aa9950'
$checkSums64['8.10.3'] = '3744e43f00227befb956a0da4c442f793087ab4da16f798dbc3b1283a71f02f8'
$checkSums64['8.10.2'] = 'f08d146621a454b40022e4681754bae570d173f157e6e7b684bd3771a34b7729'
$checkSums64["8.8.4"]  = 'ab9a5c163a0880f31c36759a540fc65890ca199c778c61b6e567b9ebe111b6e0'
$checkSums64["8.6.5"]  = '4b351db58835facf57813f3b9df366a3f740b662c363888a658befb73c0e664f'
$checkSums64["8.6.4"]  = '4c103fc450b6fef405fb69183ca7f418e8c6c5f9aa0c6efd3ea87da84b2d3ea5'

$checksumWrapper64     = 'b0447c7518afbd20c0924d28551356e4a1451967c1264ff1a27f861e324112c6'

$ErrorActionPreference = 'Stop'; # stop on all errors

function Get-HlsInstallInfo($ghcVersion) {
  $info           = @{}
  $info.url       = "$urlDownload/$version/$packageName-Windows-$ghcVersion.exe.zip"
  $info.exePath   = Join-Path $packageFullName "$packageName-$ghcVersion.exe"
  $info.checkSum  = $checkSums64[$ghcVersion]
  return $info
}

function Install-Hls($ghcVersion) {
  if ($supportedGhcVersions.Contains($ghcVersion)) {
    Write-Host "Downloading $packageName for ghc version $ghcVersion"
    $info = Get-HlsInstallInfo($ghcVersion)

    Install-ChocolateyZipPackage `
      -PackageName $packageName -UnzipLocation $packageFullName `
      -Url64bit $info.url -ChecksumType64 sha256 -Checksum64 $info.checksum
  } else {
    Write-Host "Unfortunately $ghcVersion is not supported by $packageName"
  }
}

function Get-InstalledGhcVersions() {
  Update-SessionEnvironment
  $ghcExes = $(Get-Command ghc -All -CommandType Application).path

  $versions = foreach ($ghc in $ghcExes) {
    Invoke-Expression "$ghc --numeric-version"
  }
  return $versions
}

$ghcVersions = @()

if ($pp['for-all-ghcs']) {
  $ghcVersions = $supportedGhcVersions
  Write-Host "Installing $packageName for all supported ghc versions: $($ghcVersions -join ', ')"
} elseif ($pp['for-ghcs']) {
  $ppForGhcs = $pp['for-ghcs']
  $forGhcs = $ppForGhcs.split("|")
  $ghcVersions = $supportedGhcVersions.Where({$forGhcs.Contains($_)})
  if ($ghcVersions.Count -le 0) {
    Write-Host "It has not been possible to select any supported ghc versions using the parameter value $ppForGhcs"
    Write-Host "The supported ghc versions are $($supportedGhcVersions -join ', ')"
  } else {
    Write-Host "Installing $packageName for the selected ghc versions: $($ghcVersions -join ', ')" 
  }
} else {
  $ghcVersions = Get-InstalledGhcVersions | Get-Unique
  if ($ghcVersions.Count -le 0) {
    Write-Host `
     "There is no ghc versions in PATH. Installing for the default ghc version $($supportedVersions[0])"
    $ghcVersions = @($supportedVersions[0])
  } else {
    Write-Host "Ghc versions found in PATH: $($ghcVersions -join ', ')"
  }
}


if ($ghcVersions.Count -le 0) {
  Write-Host `
   "There is no selected ghc versions so I can't determine which binaries should be downloaded."
  exit -1
}

$supportedInstalledGhcs = (Compare-Object $ghcVersions $supportedGhcVersions `
                            -IncludeEqual -ExcludeDifferent `
                          ).InputObject

if ($supportedInstalledGhcs.Count -le 0) {
  Write-Host `
    "None of the selected ghc versions is supported by $packageName so I can't determine which binaries should be downloaded."
  Write-Host "The supported ghc versions are $($supportedGhcVersions -join ', ')"
  exit -1
}

Write-Host "Installing $packageName for the selected and supported ghc versions: $($supportedInstalledGhcs -join ', ')"

ForEach ($ghcVersion in $supportedInstalledGhcs) {
  Write-Host "Installing $packageName $ghcVersion"
  Install-Hls $ghcVersion
}

Write-Host "Downloading $packageName-wrapper"

$wrapperName       = "$packageName-wrapper"
$zipFile           = "$wrapperName-Windows.exe.zip"
$urlWrapper64      = "$urlDownload/$version/$zipFile"

Install-ChocolateyZipPackage `
 -PackageName $packageName -UnzipLocation $packageFullName `
 -Url64bit $urlWrapper64 -ChecksumType64 sha256 -Checksum64 $checkSumWrapper64
