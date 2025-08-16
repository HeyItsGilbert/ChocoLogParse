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
.EXAMPLE
  Read-ChocoLog -NoColor

  This will read the latest Chocolatey.log on the machine without colored output.
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
.PARAMETER NoColor
  Disables colored output in the formatter. When specified, the output will be
  displayed without ANSI color codes.
#>
function Read-ChocoLog {
  # This makes PlatyPS sad.
  [OutputType([System.Collections.Generic.List[ChocoLog]])]
  param (
    [ValidateScript({
        if (-not ($_ | Test-Path) ) {
          throw "File or folder does not exist"
        }
        return $true
      })]
    [string[]]
    $Path = "$($env:ChocolateyInstall)\logs\",
    [int]
    $FileLimit = 1,
    [String]
    $Filter = 'chocolatey*.log',
    [string]
    $PatternLayout = '%date %thread [%-5level] - %message',
    [switch]
    $NoColor
  )

  # Set module-level variable to control coloring in formatter
  $script:ChocoLogNoColor = $NoColor.IsPresent

  $files = Get-Item -Path $Path
  if ($files.PSIsContainer) {
    $files = Get-ChildItem -Path $Path -Filter $Filter |
      Sort-Object -Property LastWriteTime | Select-Object -Last $FileLimit
  }
  Write-Verbose "Found files: $($files -join ',')"

  $parsed = @{}

  # Get the regex for the Log4Net PatternLayout
  $RegularExpression = Convert-PatternLayout -PatternLayout $PatternLayout
  $files | ForEach-Object -Process {
    $file = $_
    Write-Verbose "Reading over file: $file"
    $raw = [System.IO.File]::ReadAllLines($file.FullName)
    Write-Verbose "Lines read: $($raw.Count)"
    # Iterate over each line
    foreach ($line in $raw) {
      Write-Debug $line
      $m = $RegularExpression.match($line)
      if ($m.Success) {
        [int]$threadMatch = $m.Groups['thread'].Value
        # Replace comma with period to make it a valid datetime
        [datetime]$currentDateTime = $m.Groups['date'].Value -replace ',', '.'
        # Check if thread exists, if not make it.
        if (-not ($parsed.ContainsKey($threadMatch))) {
          Write-Verbose "New thread detected: $threadMatch"
          $null = $parsed.Add(
            $threadMatch,
            [ChocoLog]::new(
              $threadMatch,
              $file
            )
          )
        }
        Write-Verbose "Adding new log line to thread $threadMatch"
        $parsed.Item($threadMatch).AddLogLine(
          [Log4NetLogLine]::new(
            $currentDateTime,
            $threadMatch,
            $m.Groups['level'].Value,
            $m.Groups['message'].Value
          ))
      } else {
        Write-Verbose "Line did not match regex"
        Write-Debug $line
        # if it doesn't match regex, append to the previous
        if ($threadMatch) {
          Write-Verbose "Appending to existing thread: $threadMatch"
          $parsed.Item($threadMatch).AppendLastLogLine($line)
        } else {
          # This might happen if the log starts on what should have been a
          # multiline entry... Not very likely
          Write-Warning "No currentSession. File: $File; Line: $Line"
        }
      }
    }
  }

  # Doing this at the end since threads can get mixed
  $parsed.Keys | ForEach-Object {
    Write-Verbose "Parsing special logs for: $_"
    # This updates fields like: cli, environment, and configuration
    $parsed.Item($_).ParseSpecialLogs()
  }

  # Return the whole parsed object
  Write-Verbose "Returning results in descending order. Count: $($parsed.Count)"
  $return = $parsed.Values | Sort-Object -Descending Time
  return $return
}
