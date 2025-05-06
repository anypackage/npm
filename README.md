# AnyPackage.Npm

[![gallery-image]][gallery-site]
[![build-image]][build-site]
[![cf-image]][cf-site]

[gallery-image]: https://img.shields.io/powershellgallery/dt/AnyPackage.Npm
[build-image]: https://img.shields.io/github/actions/workflow/status/anypackage/npm/ci.yml
[cf-image]: https://img.shields.io/codefactor/grade/github/anypackage/npm
[gallery-site]: https://www.powershellgallery.com/packages/AnyPackage.Npm
[build-site]: https://github.com/anypackage/npm/actions/workflows/ci.yml
[cf-site]: https://www.codefactor.io/repository/github/anypackage/npm

`AnyPackage.Npm` is an AnyPackage provider that facilitates installing Node.js
NPM modules.

## Install AnyPackage.Npm

```powershell

Install-PSResource AnyPackage.Npm
```

## Import AnyPackage.Npm

```powershell
Import-Module AnyPackage.Npm
```

## Sample usages

### Search for a package

```powershell
Find-Package -Name posh-gulp
```

### Install a package

```powershell
Find-Package posh-gulp | Install-Package

Install-Package -Name posh-gulp
```

### Get list of installed packages

```powershell
Get-Package -Name posh-gulp
```

### Uninstall a package

```powershell
Get-Package -Name posh-gulp | Uninstall-Package

Uninstall-Package -Name posh-gulp
```

## Known Issues

### Custom repositories

The package provider currently does not support custom package repositories.
