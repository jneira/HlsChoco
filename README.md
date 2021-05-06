# HlsChoco

Chocolatey sources for [haskell-language-server](https://github.com/haskell/haskell-language-server/blob/master/README.md) installs.

This repository contains the sources for the haskell-language-server Chocolatey packages.

## Usage

To use these get [Chocolatey](https://chocolatey.org/) and then:

and then:

- for install `haskell-language-server` suited for the ghc versions you have installed using chocolatey:

```powershell
> choco install haskell-language-server
```

- for install `haskell-language-server` for some concrete ghc versions:

```powershell
> choco install haskell-language-server --params="/for-ghcs:8.6.5|8.8.4|8.10.4"
```

- for install `haskell-language-server` for *all* supported ghc versions (this could take quite time and disk space):

```powershell
> choco install haskell-language-server --params="/for-all-ghcs"
```

Actual ghc versions supported by `haskell-language-server`are: 8.10.4, 8.10.3, 8.10.2, 8.8.4, 8.6.5 and 8.6.4.

## Dependencies

This package depends on chocolatey [ghc package](https://community.chocolatey.org/packages/ghc) which in turn depends on [the cabal one](https://community.chocolatey.org/packages/cabal) so this will install them if they are not already installed. If you want to avoid install them you can do:

```powershell
> choco install haskell-language-server --ignore-dependencies
```

## Using it with stack

If you are going to use stack, which manages ghc's internally, you still could use the package, ignoring dependencies and telling the it what exact ghc versions you are gonna to use:

```powershell
> choco install haskell-language-server --params="/for-ghcs:8.6.5|8.8.4|8.10.4" --ignore-dependencies
```
