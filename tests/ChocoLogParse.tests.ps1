# cSpell:ignore BHPS Ffoo Subkeys
BeforeDiscovery {
  if ($null -eq $env:BHPSModuleManifest) {
    .\build.ps1 -Task Init
  }
  $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
  $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
  $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
  $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
  $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"

  # Get module commands
  # Remove all versions of the module from the session. Pester can't handle multiple versions.
  Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
  Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop
}

BeforeAll {
  # Setup dummy data including things across multiple lines
  $folder = Join-Path -Path $PSScriptRoot -ChildPath 'fixtures\folder'
  $singleFile = "TestDrive:\test.log"
  # Due to "files.trimTrailingWhitespace" vscode setting, I added some '.'s
  # to the multiline examples
  Set-Content $singleFile -Value @'
2023-06-14 14:22:09,411 57332 [DEBUG] - .
NOTE: Hiding sensitive configuration data! Please double and triple
  check to be sure no sensitive data is shown, especially if copying
  output to a gist for review.
2023-06-14 14:22:09,417 57332 [DEBUG] - Configuration: CommandName='upgrade'|CacheLocation='C:\Windows\TEMP\chocolatey'|
ContainsLegacyPackageInstalls='False'|
CommandExecutionTimeoutSeconds='2700'|WebRequestTimeoutSeconds='30'|
Sources=''|SourceType='normal'|
Debug='False'|Verbose='False'|Trace='False'|Force='False'|Noop='False'|
HelpRequested='False'|UnsuccessfulParsing='False'|RegularOutput='True'|
QuietOutput='False'|PromptForConfirmation='False'|
DisableCompatibilityChecks='False'|AcceptLicense='True'|
AllowUnofficialBuild='False'|Input='zoom'|AllVersions='False'|
Features.AllowEmptyChecksums='False'|Features.UsePackageExitCodes='True'|
SkipPackageInstallProvider='False'|SkipHookScripts='False'|
2023-06-14 14:22:09,418 57332 [DEBUG] - _ Chocolatey:ChocolateyUpgradeCommand - Normal Run Mode _
2023-06-14 14:22:09,422 57332 [INFO ] - Upgrading the following packages:
2023-06-14 14:22:09,423 57332 [INFO ] - zoom
2023-06-14 14:22:09,423 57332 [INFO ] - By upgrading, you accept licenses for the packages.
2023-06-14 14:22:10,107 57332 [INFO ] - zoom v5.14.11.17466 is newer than the most recent.
  You must be smarter than the average bear...
2023-06-14 14:22:10,113 57332 [WARN ] - .
Chocolatey upgraded 0/1 packages.
  See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
2023-06-14 14:22:10,115 57332 [DEBUG] - Sending message 'PostRunMessage' out if there are subscribers...
2023-06-14 14:22:10,116 57332 [DEBUG] - Exiting with 100
2023-06-14 14:22:09,410 12345 [DEBUG] - The source '' evaluated to a 'normal' source type
2023-06-14 14:22:09,411 54321 [DEBUG] - .
NOTE: Hiding sensitive configuration data! Please double and triple
  check to be sure no sensitive data is shown, especially if copying
  output to a gist for review.
2023-06-14 14:22:09,417 54321 [DEBUG] - Configuration: CommandName='upgrade'|CacheLocation='C:\Windows\TEMP\chocolatey'|
ContainsLegacyPackageInstalls='False'|
CommandExecutionTimeoutSeconds='2700'|WebRequestTimeoutSeconds='30'|
Sources=''|SourceType='normal'|
Debug='False'|Verbose='False'|Trace='False'|Force='False'|Noop='False'|
HelpRequested='False'|UnsuccessfulParsing='False'|RegularOutput='True'|
QuietOutput='False'|PromptForConfirmation='False'|
DisableCompatibilityChecks='False'|AcceptLicense='True'|
AllowUnofficialBuild='False'|Input='zoom'|AllVersions='False'|
Features.AllowEmptyChecksums='False'|Features.UsePackageExitCodes='True'|
SkipPackageInstallProvider='False'|SkipHookScripts='False'|
2023-06-14 14:22:09,418 54321 [DEBUG] - _ Chocolatey:ChocolateyUpgradeCommand - Normal Run Mode _
2023-06-14 14:22:09,422 54321 [INFO ] - Upgrading the following packages:
2023-06-14 14:22:09,423 54321 [INFO ] - zoom
2023-06-14 14:22:09,423 54321 [INFO ] - By upgrading, you accept licenses for the packages.
2023-06-14 14:22:10,107 54321 [INFO ] - zoom v5.14.11.17466 is newer than the most recent.
  You must be smarter than the average bear...
2023-06-14 14:22:10,113 54321 [WARN ] - .
Chocolatey upgraded 0/1 packages.
  See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
2023-06-14 14:22:10,115 54321 [DEBUG] - Sending message 'PostRunMessage' out if there are subscribers...
2023-06-14 14:22:10,117 54321 [DEBUG] - Exiting with 900
'@
}

Describe 'Read-ChocoLog' {
  BeforeAll {
    $script:parsed = Read-ChocoLog -Path $singleFile
    $script:multiple = Read-ChocoLog -Path $folder
    $script:moreLimit = Read-ChocoLog -Path $folder -FileLimit 10
  }

  Context 'For Single File' {
    It 'Parses the correct number of sessions' {
      ($script:parsed).Count | Should -Be 3
    }

    It 'Parses the correct number of lines per session' {
      $script:parsed[1].logs.Count | Should -Be 10
    }

    It 'Detects the exit code' {
      $script:parsed[1].exitCode | Should -Be 100
    }

    It 'Detects the right session number' {
      $script:parsed[1].thread | Should -Be 57332
    }

    It 'Has Configuration with Subkeys' {
      $script:parsed[1].Configuration['Features']['UsePackageExitCodes'] | Should -Be 'True'
    }
  }

  Context 'For Folder Path' {
    It 'Parses the correct default number of sessions' {
      # There is two sessions in each file and we grab one file by default
      # 1 for $randID and 1 for $randID2
      ($script:multiple).Count | Should -Be 2
    }

    It 'Parses the correct number of sessions for increased limit' {
      # There is one session in each file so there should be a total of 10
      # 5 for $randID and 5 for $randID2
      ($script:moreLimit).Count | Should -Be 20
    }

    It 'Parses the correct number of lines per session' {
      $script:multiple.Count | Should -Be 2
      $script:multiple[0].logs.Count | Should -Be 9
      $script:multiple[1].logs.Count | Should -Be 2
    }
  }
}

Describe 'Get-ChocoLogEntry' {
  BeforeAll {
    $script:parsedEntry = Get-ChocoLogEntry -Path $singleFile
    $script:multipleEntry = Get-ChocoLogEntry -Path $folder
  }

  Context 'For Single File' {
    It 'Parses the correct number of sessions' {
      ($script:parsedEntry).Count | Should -Be 1
    }

    It 'Parses the correct number of lines per session' {
      $script:parsedEntry.logs.Count | Should -Be 10
    }

    It 'Detects the exit code' {
      $script:parsedEntry.exitCode | Should -Be 900
    }

    It 'Detects the right session number' {
      $script:parsedEntry.thread | Should -Be 54321
    }

    It 'Has Configuration with Subkeys' {
      $script:parsedEntry.Configuration['Features']['UsePackageExitCodes'] | Should -Be 'True'
    }
  }

  Context 'For Folder Path' {
    It 'Parses the correct default number of sessions' {
      # Should still only return 1 regardless of folder
      ($script:multipleEntry).Count | Should -Be 1
    }

    It 'Parses the correct number of lines per session' {
      $script:multipleEntry.logs.Count | Should -Be 2
    }
  }
}
