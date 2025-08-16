<#
.SYNOPSIS
  Grab a single session from the latest log file. Defaults to last exection.
.DESCRIPTION
  Reads the latest log file and grabs the last session
.NOTES
  Works for Windows PowerShell and PowerShell Core (e.g. 7).
.EXAMPLE
  Get-ChocoLogEntry

  Grabs the laste entry from the latest log
.EXAMPLE
  Get-ChocoLogEntry -NoColor

  Grabs the latest entry from the latest log without colored output
.PARAMETER Report
  This changes the output to be more friendly for reporting
.PARAMETER Path
  The log path you want to parse. This will default to the latest local log.
  This can be a directory of logs.
.PARAMETER Filter
  The filter passed to Get Child Item. Default to 'chocolatey*.log.'
.PARAMETER PatternLayout
  The log4net pattern layout used to parse the log. It is very unlikely that you
  need to supply this. The code expects pattern names: time, session, level, and
  message.
.PARAMETER NoColor
  Disables colored output in the formatter. When specified, the output will be
  displayed without ANSI color codes.
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
    [switch]$Report,
    [switch]$NoColor
  )
  # ToDo:
  # - Support searching for a cli entry
  # - sub command type (e.g. search, list, upgrade)
  # - Exit code
  # - Filter to recent time to make sure we get the right one

  $entry = Read-ChocoLog -FileLimit 1 -Path $Path -Filter $Filter -PatternLayout $PatternLayout -NoColor:$NoColor | Select-Object -Last 1
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
