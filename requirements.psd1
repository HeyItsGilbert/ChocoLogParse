@{
    PSDependOptions = @{
        Target = 'CurrentUser'
    }
    'Pester' = @{
        Version = '5.5.0'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    'psake' = @{
        Version = '4.9.0'
    }
    'BuildHelpers' = @{
        Version = '2.0.16'
    }
    'PowerShellBuild' = @{
        Version = '0.6.1'
    }
    'PSScriptAnalyzer' = @{
        Version = '1.19.1'
    }
    'Log4NetParse' = @{
        Version = '0.3.0'
    }
}
