<#
.SYNOPSIS
  Parses a chocolatey into an object that is easier to search and filter.
.DESCRIPTION
  Reads chocolatey log(s) and creates a new set of custom objects. It highlights
  details that make it easier to search and filter logs.
.NOTES
  Works for Windows PowerShell and PowerShell Core. This works on Linux.
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Read-ChocoLog

  This will read the latest Chocolatey.log on the machine.
.PARAMETER Path
  The log you want to parse. This will default to the latest local log.
.PARAMETER FileLimit
  How many files should we parse a given folder path?
.PARAMETER Filter
  The filter passed to Get Child Item. Default to 'chocolatey*.log.'
.PARAMETER PatternLayout
  The log4net pattern layour used to parse the log.
  Should contain capture groups for time, session, level, and message.
#>
function Read-ChocoLog {
  [OutputType([System.Collections.ArrayList])]
  param (
    [ValidateScript({
        if (-Not ($_ | Test-Path) ) {
          throw "File or folder does not exist"
        }
        return $true
      })]
    [string[]]
    $Path = 'C:\ProgramData\chocolatey\logs\',
    [int]
    $FileLimit = 1,
    [String]
    $Filter = 'chocolatey*.log',
    [string]
    $PatternLayout = '%date %thread [%-5level] - %message'
  )

  $files = Get-Item -Path $Path
  if ($files.PSIsContainer) {
    $files = Get-ChildItem -Path $Path -Filter $Filter | Sort-Object -Property LastWriteTime | Select-Object -Last $FileLimit
  }

  [System.Collections.ArrayList]$parsed = @()
  $RegularExpression = Convert-PatternLayout $PatternLayout

  $files | ForEach-Object -Process {
    $file = $_
    $raw = [System.IO.File]::ReadAllLines($file.FullName)

    # Iterate over each line
    foreach ($line in $raw) {
      # Write-Debug $line
      $m = $RegularExpression.match($line)
      if ($m.Success) {
        # If it matches the regex, tag it
        if ($m.Groups['thread'].Value -ne $currentSession.thread) {
          if ($currentSession) {
            $currentSession.endTime = $currentSession.logs[-1].time
            # This updates fields like: cli, environment, and configuration
            $currentSession.ParseSpecialLogs()
            $parsed.Add($currentSession) > $null
          }

          # This is a different session
          $currentSession = [ChocoLog]::new(
            $m.Groups['thread'].Value,
            ($m.Groups['date'].Value -replace ',', '.'),
            $file
          )
        }

        $currentSession.logs.Add(
          [Log4NetLogLine]::new(
            [Datetime]($m.Groups['date'].Value -replace ',', '.'),
            $m.Groups['thread'].Value,
            $m.Groups['level'].Value,
            $m.Groups['message'].Value
          )) > $null
      } else {
        # if it doesn't match regex, append to the previous
        if ($currentSession) {
          $currentSession.logs[-1].AppendMessage($line)
        } else {
          # This might happen if the log starts on what should have been a
          # multiline entry... Not very likely
          Write-Warning "No currentSession. File: $File; Line: $Line"
        }
      }
    }
  }
  # Write out the last log line!
  if (-Not $parsed.Contains($currentSession)) {
    $parsed.Add($currentSession) > $null
  }

  # Return the whole parsed object
  $parsed
}
