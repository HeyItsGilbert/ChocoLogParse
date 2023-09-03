using module Log4NetParse

class ChocoLog : Log4NetLog {
  [string]$cli
  [string]$exitCode
  [LogType]$logType
  [hashtable]$Configuration

  ChocoLog(
    [int]$Thread,
    [datetime]$startTime,
    [string]$filePath
  ) {
    $this.thread = $Thread
    $this.startTime = $startTime
    $this.logs = [System.Collections.ArrayList]::new()
    $this.filePath = $filePath
    $this.Configuration = @{}
    if ($filePath -like "*summary*") {
      $this.logType = [LogType]::Summary
    } else {
      $this.logType = [LogType]::Debug
    }
  }

  # This parses all the logs for entries that are part of the class
  [void] ParseSpecialLogs() {
    $this.logs | ForEach-Object {
      $message = $_.message
      # Command Line Pattern
      $cliPattern = 'Command line: '
      if ($message.StartsWith($cliPattern)) {
        $this.cli = $message -replace $cliPattern
      }

      # Exit code Pattern
      $exitPattern = 'Exiting with '
      if ($message.StartsWith($exitPattern)) {
        $this.exitCode = $message -replace $exitPattern
      }

      # Configuration pattern
      $configPattern = "Configuration:"
      if ($message.StartsWith($configPattern)) {
        $arr = $conf.message -replace 'Configuration:' -replace "`n" -split "\|" | Where-Object {
          -Not [string]::IsNullOrWhiteSpace($message)
        }

        foreach ($entry in $arr) {
          # ToDo: Split is too niave. Need regex.
          $k, $v = $entry -split '='
          $this.configuration[$k.Trim()] = ($v -join '').Trim()
        }
      }
    }
  }
}
