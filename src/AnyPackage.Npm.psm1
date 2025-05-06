using module AnyPackage
using namespace AnyPackage.Provider
using namespace System.Management.Automation

[PackageProvider('Npm')]
class NpmProvider : PackageProvider, IGetPackage, IFindPackage, IInstallPackage, IUninstallPackage {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPositionalParameters', '')]
    [void] FindPackage ([PackageRequest] $request) {
        $npmPackages = npm search $request.Name --json | ConvertFrom-Json

        foreach ($item in $npmPackages) {
            if ($request.IsMatch($item.name)) {
                $config = npm config list registry -g --json | ConvertFrom-Json
                $url = "{0}/{1}" -f $config.registry, $item.name
                $packages = Invoke-WebRequest -Uri $url | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty versions
                $versions = $packages | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name

                $source = [PackageSourceInfo]::new($config.registry, $config.registry, $request.ProviderInfo)

                foreach ($version in $versions) {
                    if ($request.IsMatch([PackageVersion]$version)) {
                        $package = $packages.$version
                        $metadata = $package | ConvertTo-Metadata
                        $packageInfo = [PackageInfo]::new($package.name, $version, $source, $package.description, $null, $metadata, $request.ProviderInfo)
                        $request.WritePackage($packageInfo)
                    }
                }
            }
        }
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [void] GetPackage ([PackageRequest] $request) {
        $prefix = npm prefix --global

        if ($global:PSEdition -eq 'Desktop' -or $global:IsWindows) {
            $globalNpmPackagePath = Join-Path -Path $prefix -ChildPath 'node_modules'
        } else {
            $globalNpmPackagePath = Join-Path -Path $prefix -ChildPath 'lib/node_modules'
        }

        $request.WriteVerbose("Global installed packages directory: $globalNpmPackagePath")

        $packageJsonPath = Join-Path -Path $globalNpmPackagePath -ChildPath '*/package.json'
        foreach ($path in (Get-Item $packageJsonPath)) {
            $npmPackage = $path | Get-Content | ConvertFrom-Json

            if ($request.IsMatch($npmPackage.name, $npmPackage.version)) {
                $metadata = $npmPackage | ConvertTo-Metadata
                $path = Join-Path -Path $prefix -ChildPath "node_modules/$($npmPackage.name)"
                $source = [PackageSourceInfo]::new($path, $path, $request.ProviderInfo)
                $package = [PackageInfo]::new($npmPackage.name, $npmPackage.version, $source, $npmPackage.description, $null, $metadata, $request.ProviderInfo)
                $request.WritePackage($package)
            }
        }
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [void] InstallPackage ([PackageRequest] $request) {
        $findPackageParameters = @{
            Name        = $request.Name
            Provider    = $request.ProviderInfo.FullName
            ErrorAction = 'Stop'
        }

        if ($request.Version) {
            $findPackageParameters['Version'] = $request.Version
        }

        $package = Find-Package @findPackageParameters |
            Sort-Object -Property Version -Descending |
            Select-Object -First 1

        $spec = '{0}@{1}' -f $package.Name, $package.Version

        npm install $spec -g 2>&1 |
            ForEach-Object {
                if ($_ -is [ErrorRecord]) {
                    $request.WriteError($_)
                } else {
                    $request.WriteVerbose($_)
                }
            }

        if ($LASTEXITCODE -eq 0) {
            $request.WritePackage($package)
        }
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [void] UninstallPackage ([PackageRequest] $request) {
        $getPackageParameters = @{
            Name        = $request.Name
            Provider    = $request.ProviderInfo.FullName
            ErrorAction = 'SilentlyContinue'
        }

        if ($request.Version) {
            $getPackageParameters['Version'] = $request.Version
        }

        $package = Get-Package @getPackageParameters

        if (!$package) {
            return
        }

        npm uninstall $request.Name -g 2>&1 |
            ForEach-Object {
                if ($_ -is [ErrorRecord]) {
                    $request.WriteError($_)
                } else {
                    $request.WriteVerbose($_)
                }
            }

        if ($LASTEXITCODE -eq 0) {
            $request.WritePackage($package)
        }
    }
}

[guid] $id = '977f95d8-f85d-4ae3-95fd-d6b5b55ae70e'
[PackageProviderManager]::RegisterProvider($id, [NpmProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    [PackageProviderManager]::UnregisterProvider($id)
}

function ConvertTo-Metadata {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [PSObject]
        $InputObject
    )

    process {
        $ht = @{ }

        $properties = $InputObject |
            Get-Member -MemberType Properties |
            Select-Object -ExpandProperty Name

        foreach ($prop in $properties) {
            $ht[$prop] = $InputObject.$prop
        }

        $ht
    }
}
