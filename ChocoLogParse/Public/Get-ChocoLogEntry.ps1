<#
.SYNOPSIS
  Grab a single session from the latest log file. Defaults to last exection.
.DESCRIPTION
  Reads the latest log file and grabs the last session
.NOTES
  Works for Windows PowerShell and PowerShell Core (e.g. 7).
.LINK
  https://heyitsgilbert.github.io/ChocoLogParse/en-US/Get-ChocoLogEntry/
.EXAMPLE
  Get-ChocoLogEntry

  Grabs the laste entry from the latest log
.PARAMETER Report
  This changes the output to be more friendly for reporting
#>
function Get-ChocoLogEntry {
  [CmdletBinding()]
  param (
    [ValidateScript({
        if (-Not ($_ | Test-Path) ) {
          throw "File or folder does not exist"
        }
        return $true
      })]
    [string[]]
    $Path = "$($env:ChocolateyInstall)\logs\",
    [String]
    $Filter = 'chocolatey*.log',
    [string]
    $PatternLayout = '%date %thread [%-5level] - %message',
    [switch]$Report
  )
  # ToDo:
  # - Support searching for a cli entry
  # - sub command type (e.g. search, list, upgrade)
  # - Exit code
  # - Filter to recent time to make sure we get the right one

  $entry = Read-ChocoLog -FileLimit 1 -Path $Path -Filter $Filter -PatternLayout $PatternLayout | Select-Object -Last 1
  if ($report) {
    # Print out in a format that's useful for Chef logging
    Write-Host ('Command: {0}' -F $entry.cli)
    Write-Host ('Exit Code: {0}' -F $entry.exitCode )
    # This will print out the configuration in a more readble way
    Write-Host "Configuration: `n - "
    $entry.Configuration

    Write-Host 'Logs:'
    $entry.logs | ForEach-Object {
      @(
        $_.Time.ToString('hh:mm:ss.fff'),
        ('[' + $_.level + ']'),
        $_.message
      ) -Join ' '
    }
  } else {
    return $entry
  }
}
