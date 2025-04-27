using module AnyPackage
using namespace AnyPackage.Provider

[PackageProvider('Npm')]
class NpmProvider : PackageProvider, IGetPackage {
    [void] GetPackage ([PackageRequest] $request) {
        $prefix = npm prefix --global
        $globalNpmPackagePath = Join-Path -Path $prefix -ChildPath 'node_modules'
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
}

[guid] $id = '977f95d8-f85d-4ae3-95fd-d6b5b55ae70e'
[PackageProviderManager]::RegisterProvider($id, [NpmProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    [PackageProviderManager]::UnregisterProvider($id)
}

function ConvertTo-Metadata {
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
