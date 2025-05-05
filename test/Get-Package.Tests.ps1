#Requires -Modules AnyPackage.Npm

Describe Get-Package {
    BeforeAll {
        npm install cspell-dict-powershell -g
        npm install posh-gulp -g
    }

    AfterAll {
        npm uninstall cspell-dict-powershell -g
        npm uninstall posh-gulp -g
    }

    Context 'with no parameters' {
        It 'should return results' {
            npm config list prefix -g -l | Write-Verbose -Verbose
            npm list -g | Write-Verbose -Verbose

            Get-Package |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Name parameter' {
        It 'should return cspell-dict-powershell' {
            Get-Package -Name cspell-dict-powershell |
            Should -Not -BeNullOrEmpty
        }
    }
}
