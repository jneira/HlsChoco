$version         = '1.1.0'
$packageName     = 'haskell-language-server'
$binRoot         = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageFullName = Join-Path $binRoot "$packageName-$version"
$urlDownload     = "https://github.com/haskell/$packageName/releases/download"
$pp              = Get-PackageParameters

$supportedGhcVersions  = ("8.10.4", "8.10.3", "8.10.2", "8.8.4", "8.6.5", "8.6.4")

$checkSums64=@{}
$checkSums64['8.10.4'] = '9FDD7F6BC8FA8D259DB731B2A86F3FCB062F6B8751D29D5FDF83CFC6BF5F8779'
$checkSums64['8.10.3'] = 'CEF8DED7183177EC34C9400F3405AB230401B0E7E558E88520B0DF98905D14DB'
$checkSums64['8.10.2'] = '63495C9B9F8815F7E97735CC2E54E89CE454EA4D130697B3E5905F53FB17AE2F'
$checkSums64["8.8.4"]  = '1072CC073D33B9B65470F93804D01CE4911123EC21454BFDAD4BAA1A1B22D9CC'
$checkSums64["8.6.5"]  = 'EAAFAFD702E0A26F72E2BC35E579E907BD3EA5A054E4F69F3F3FD7BFC03BC3A0'
$checkSums64["8.6.4"]  = '2D7FBA52D7F73923922F461FD911BE421EC6A43C6434B4AE702802F0CDCCC558'

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
  $ghcExes = $(Get-Command ghc -All).path

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
  $ghcVersions = Get-InstalledGhcVersions
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

Write-Host "Installing $packageName for the selected and supported ghc versions: $($ghcVersions -join ', ')"

ForEach ($ghcVersion in $supportedInstalledGhcs) {
  Write-Host "Installing $packageName $ghcVersion"
  Install-Hls $ghcVersion
}

Write-Host "Downloading $packageName-wrapper"

$wrapperName       = "$packageName-wrapper"
$zipFile           = "$wrapperName-Windows.exe.zip"
$urlWrapper64      = "$urlDownload/$version/$zipFile"
$checksumWrapper64 = '4528CD2F6BCEEF7BABD1CA0D0648C10387E4AC04BA5D9B86D76F92F47BC8A509'

Install-ChocolateyZipPackage `
 -PackageName $packageName -UnzipLocation $packageFullName `
 -Url64bit $urlWrapper64 -ChecksumType64 sha256 -Checksum64 $checkSumWrapper64
