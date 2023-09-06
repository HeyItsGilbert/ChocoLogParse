<#
.SYNOPSIS
  Parses a Chocolatey log into an object that is easier to search and filter.
.DESCRIPTION
  Reads Chocolatey log(s) and creates a new set of custom objects. It highlights
  details that make it easier to search and filter.
.NOTES
  Works for Windows PowerShell and PowerShell Core. This works on Linux.
.LINK
  https://heyitsgilbert.github.io/ChocoLogParse/en-US/Read-ChocoLog/
.EXAMPLE
  Read-ChocoLog

  This will read the latest Chocolatey.log on the machine.
.PARAMETER Path
  The log path you want to parse. This will default to the latest local log.
  This can be a directory of logs.
.PARAMETER FileLimit
  The number of files the command should parse given a folder path.
.PARAMETER Filter
  The filter passed to Get Child Item. Default to 'chocolatey*.log.'
.PARAMETER PatternLayout
  The log4net pattern layout used to parse the log. It is very unlikely that you
  need to supply this. The code expects pattern names: time, session, level, and
  message.
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
  $detected = [System.Collections.Generic.List[int]]::new()

  $RegularExpression = Convert-PatternLayout $PatternLayout

  $files | ForEach-Object -Process {
    $file = $_
    $raw = [System.IO.File]::ReadAllLines($file.FullName)

    # Iterate over each line
    foreach ($line in $raw) {
      # Write-Debug $line
      $m = $RegularExpression.match($line)
      if ($m.Success) {
        $threadMatch = $m.Groups['thread'].Value
        # If it matches the regex, tag it
        if ($threadMatch -ne $currentSession.thread) {
          # This is a different thread

          # Save the current session to the parsed list
          if ($currentSession) {
            $parsed.Add($currentSession) > $null
          }

          # Look up if current thread exists in Parsed and append to that if so
          if ($detected.Contains($threadMatch)) {
            $currentSession = $parsed | Where-Object { $_.Thread -eq $threadMatch }
          } else {
            # We haven't seen this thread before, let's make a new object
            $detected.Add($threadMatch) > $null
            $currentSession = [ChocoLog]::new(
              $threadMatch,
              ($m.Groups['date'].Value -replace ',', '.'),
              $file
            )
          }
        }

        $currentSession.logs.Add(
          [Log4NetLogLine]::new(
            [Datetime]($m.Groups['date'].Value -replace ',', '.'),
            $threadMatch,
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

  # Doing this at the end since threads can get mixed
  $parsed | ForEach-Object {
    # This updates fields like: cli, environment, and configuration
    $_.ParseSpecialLogs()
  }

  # Return the whole parsed object
  $parsed
}
