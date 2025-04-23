using module AnyPackage
using namespace AnyPackage.Provider

[PackageProvider('Npm')]
class NpmProvider : PackageProvider {

}

[guid] $id = '977f95d8-f85d-4ae3-95fd-d6b5b55ae70e'
[PackageProviderManager]::RegisterProvider($id, [NpmProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    [PackageProviderManager]::UnregisterProvider($id)
}
