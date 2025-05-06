#Requires -Modules AnyPackage.Npm

Describe Uninstall-Package {
    BeforeEach {
        npm install posh-gulp -g
    }

    Context 'with -Name parameter' {
        It 'should uninstall' {
            Uninstall-Package -Name posh-gulp -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }
}
