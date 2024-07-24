using module Log4NetParse

class ChocoLog : Log4NetLog {
  [string]$CLI
  [string]$ExitCode
  [LogType]$LogType
  [hashtable]$Configuration

  ChocoLog(
    [int]$Thread,
    [string]$filePath
  ) : base (
    $Thread,
    $filePath
  ) {
    $this.Thread = $Thread
    $this.FilePath = $filePath
    $this.Configuration = @{}
    if ($filePath -like "*summary*") {
      $this.logType = [LogType]::Summary
    } else {
      $this.logType = [LogType]::Debug
    }
  }

  # This parses all the logs for entries that are part of the class
  [void] ParseSpecialLogs() {
    # Set the end time here since we are done parsing
    $this._logs.Sort()
    $this.StartTime = $this._logs[0].time
    $this.EndTime = $this._logs[-1].time

    # Detect known patterns
    $this._logs | ForEach-Object {
      switch ($_.message) {
        { $_.StartsWith('Command line: ') } { $this.SetCli($_) }
        { $_.StartsWith('Exiting with ') } { $this.SetExitCode($_) }
        { $_.StartsWith('Configuration:') } {
          $this.ParseConfiguration($_)
        }
        Default {}
      }
    }
  }

  [void] SetCli($message) {
    $this.cli = $message -replace 'Command line: '
  }

  [void] SetExitCode($message) {
    $this.exitCode = $message -replace 'Exiting with '
  }

  [void] ParseConfiguration($message) {
    $clean = $message -replace 'Configuration: ' -replace "`n"
    $entries = $clean -split "\|" | Where-Object {
      -Not [string]::IsNullOrWhiteSpace($_)
    }

    $configHash = @{}

    foreach ($entry in $entries) {
      # Split on the `=`
      # example: Features.UseEnhancedExitCodes='False'
      $k, $v = $entry -split '='
      $key = $k.Trim()
      $value = ($v -join '').Trim(" ", "'")

      # Let's treat foo.bar and a subkey because I'm a masochist
      if ($key.Contains(".")) {
        # AFAICT there is only ever one subkey
        # WARNING: Split is doing regex so you have to escape the period.
        $parent, $subkey = $key.Split('.')

        if (-Not $configHash.ContainsKey($parent)) {
          $configHash[$parent] = @{}
        }

        $configHash[$parent][$subkey] = $value
      } else {
        # Top level key, keep it simple
        $configHash[$key] = $value
      }
    }
    $this.Configuration = $configHash
  }
}
