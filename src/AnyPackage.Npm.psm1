using module AnyPackage
using namespace AnyPackage.Provider
using namespace System.Management.Automation

[PackageProvider('Npm')]
class NpmProvider : PackageProvider, IGetPackage, IFindPackage, IInstallPackage {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPositionalParameters', '')]
    [void] FindPackage ([PackageRequest] $request) {
        $npmPackages = npm search $request.Name --json | ConvertFrom-Json

        foreach ($item in $npmPackages) {
            if ($request.IsMatch($item.name, $item.version)) {
                $metadata = $item | ConvertTo-Metadata
                $package = [PackageInfo]::new($item.name, $item.version, $null, $item.description, $null, $metadata, $request.ProviderInfo)
                $request.WritePackage($package)
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
