#Requires -Modules AnyPackage.Scoop

Describe Install-Package {
    AfterEach {
        npm uninstall posh-gulp -g
    }

    Context 'with -Name parameter' {
        It 'should install' {
            Install-Package -Name posh-gulp -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }
}
