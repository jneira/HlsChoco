# HlsChoco

Chocolatey sources for [haskell-language-server](https://github.com/haskell/haskell-language-server/blob/master/README.md) installs.

This repository contains the sources for the haskell-language-server Chocolatey packages.

## Usage

To use these get [Chocolatey](https://chocolatey.org/) and then:

* for install `haskell-language-server` suited for the ghc versions you have in `PATH`:

```shell
choco install haskell-language-server
```

* for install `haskell-language-server` for some concrete ghc versions:

```shell
choco install haskell-language-server --params="/for-ghcs:8.6.5|8.8.4|8.10.7|9.0.1"
```

* for install `haskell-language-server` for *all* supported ghc versions (this could take quite time and disk space):

```shell
choco install haskell-language-server --params="/for-all-ghcs"
```

Actual ghc versions supported by `haskell-language-server` are: 9.0.1, 8.10.7, 8.10.6, 8.10.5, 8.8.4, 8.8.3 and 8.6.5.

## Dependencies

This package depends on chocolatey [ghc package](https://community.chocolatey.org/packages/ghc) which in turn depends on [the cabal one](https://community.chocolatey.org/packages/cabal) so this will install them if they are not already installed. If you want to avoid install them you can do:

```shell
choco install haskell-language-server --ignore-dependencies
```

## Using it with stack

If you are going to use stack, which manages ghc's internally, you still could use the package, ignoring dependencies and telling it what exact ghc versions you are gonna to use:

```shell
choco install haskell-language-server --params="/for-ghcs:8.6.5|8.8.4|8.10.7|9.0.1" --ignore-dependencies
```

## Release

1. Change all occurrences of the previous hls version with the new one (including `chocolateyuninstall.ps1`)
2. Update .nuspec with the range of supported ghc versions
3. Update PS script with the list of ghc supported versions with their checksums (including the wrapper)
4. run `cd ${HLS_VERSION}\haskell-language-server; choco pack --force`
5. run `choco push haskell-language-server.${HLS_VERSION}.nupkg -s https://push.chocolatey.org/ -apikey ${CHOCO_API_KEY}`
