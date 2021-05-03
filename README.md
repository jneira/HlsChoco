# HlsChoco

Chocolatey sources for haskell-language-server installs.

This repository contains the sources for the haskell-language-server Chocolatey packages.

To use these get Chocolatey https://chocolatey.org/

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

The actual ghc versions supported by `haskell-language-server`are: 8.10.4, 8.10.3, 8.10.2, 8.8.4, 8.6.5 and 8.6.4.
