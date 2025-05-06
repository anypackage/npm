#Requires -Modules AnyPackage.Npm

Describe Find-Package {
    Context 'with -Name parameter' {
        It 'single name' {
            Find-Package -Name cspell-dict-powershell |
            Should -Not -BeNullOrEmpty
        }

        It 'multiple names' {
            Find-Package -Name cspell-dict-powershell, posh-gulp |
            Should -HaveCount 2
        }
    }

    Context 'with -Version parameter' {
        It 'Explicit version' {
            $package = Find-Package -Name cspell-dict-powershell -Version 1.0.1
            $package.Name | Should -Be cspell-dict-powershell
            $package.Version | Should -Be 1.0.1
        }

        It 'Version range' {
            $range = [AnyPackage.Provider.PackageVersionRange]::new('[1.0, 1.0.5)')
            Find-Package -Name cspell-dict-powershell -Version '[1.0, 1.0.5)' |
            ForEach-Object { $range.Satisfies($_.Version) | Should -BeTrue }
        }
    }
}
