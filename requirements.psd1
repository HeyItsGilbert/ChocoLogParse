@{
    PSDependOptions = @{
        Target = 'CurrentUser'
    }
    'Pester' = @{
        Version = '5.6.1'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    'psake' = @{
        Version = '4.9.1'
    }
    'BuildHelpers' = @{
        Version = '2.0.16'
    }
    'PowerShellBuild' = @{
        Version = '0.7.3'
    }
    'PSScriptAnalyzer' = @{
        Version = '1.19.1'
    }
    'Log4NetParse' = @{
        Version = '1.1.2'
    }
}
