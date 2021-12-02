$version         = '1.5.1'
$packageName     = 'haskell-language-server'
$binRoot         = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageFullName = Join-Path $binRoot "$packageName-$version"
$urlDownload     = "https://github.com/haskell/$packageName/releases/download"
$pp              = Get-PackageParameters

$supportedGhcVersions  = ("9.0.1", "8.10.7", "8.10.6", "8.10.5", "8.8.4", "8.6.5")

$checkSums64=@{}
$checkSums64['9.0.1']  = '77ed208e6ed4bb23a827b65c6838331536a7468193236cfe38990a422dab13f1'
$checkSums64['8.10.7'] = '4f46a3df324b68fe9a26b28c29576778d1b0546c5b9a42fcd089a3edd2bf41b6'
$checkSums64['8.10.6'] = 'e9e0dc53d4c8f63136b6e3210664eb95abb84aa46a6a1cab89e97efcbb2afc22'
$checkSums64['8.10.5'] = 'c92c3a9f6b8b7a3387b39868f3ae43e43c252dc3a68376d818417d8939fa3a55'
$checkSums64["8.8.4"]  = '3fe34fb51a501236a4c2aed2366b664c25f0e86309d7cc2085fda876199d4193'
$checkSums64["8.6.5"]  = '799fe1e3b197268e37aa70df84c24accd32926bbe5a73bdd09dc6e23fe1b6fa6'

$checksumWrapper64     = 'cd1362f46c5462e5aa8ea99cf18384385abb53bebd84b08137b0a1ea8de7184a'

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
