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
}
