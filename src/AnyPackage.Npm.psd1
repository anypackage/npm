@{
    RootModule = 'AnyPackage.Npm.psm1'
    ModuleVersion = '0.0.1'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = '39d4de27-226c-421d-8eae-7c0b76835fab'
    Author = 'Thomas Nieto'
    Copyright = '(c) 2025 Thomas Nieto. All rights reserved.'
    Description = 'Npm provider for AnyPackage.'
    PowerShellVersion = '5.1'
    RequiredModules = @('AnyPackage')
    FunctionsToExport = @()
    CmdletsToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        AnyPackage = @{
            Providers = 'Npm'
        }
        PSData = @{
            Tags = @('AnyPackage', 'Provider')
            LicenseUri = 'https://github.com/anypackage/npm/blob/main/LICENSE'
            ProjectUri = 'https://github.com/anypackage/npm'
        }
    }
}
