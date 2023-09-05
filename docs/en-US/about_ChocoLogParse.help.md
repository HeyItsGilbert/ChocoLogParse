# ChocoLogParse

## about_ChocoLogParse

# SHORT DESCRIPTION

This module will parse Chocolatey logs and create easy to filter PS objects.

# LONG DESCRIPTION
This module uses the Log4NetParse module to create a RegEx and parse the
Chocolatey logs. The goal is to turn a flat file into a structured object that
makes it easier to traverse from the PowerShell command line.

## Optional Subtopics

# EXAMPLES

Read the latest Chocolatey and parse it.

```powershell
$logs = Read-ChocoLog
```

Find recent packages that didn't exit successfully (0)

```powershell
$logs | Where-Object { $_.exitcode -ne 0 }
```

Read logs for a specific (results cut short for brevity)

```powershell
> $logs[0].logs
Time         Level Message
----         ----- -------
12:00:01.800 DEBUG XmlConfiguration is now operational
12:00:01.833 DEBUG Adding new type 'WebPiService' for type 'ISourceRunner' from assembly 'choco'
12:00:01.834 DEBUG Adding new type 'WindowsFeatureService' for type 'ISourceRunner' from assembly 'choco'
12:00:01.834 DEBUG Adding new type 'CygwinService' for type 'ISourceRunner' from assembly 'choco'
12:00:01.835 DEBUG Adding new type 'PythonService' for type 'ISourceRunner' from assembly 'choco'
...
```

# NOTE

We attempt to capture additional info for each thread such as the CLI executed.

# TROUBLESHOOTING NOTE

If you've customized your log4net config (not likely but possible) then you need
to supply a custom pattern to your `Read-ChocoLog` command.

See [choco Issue 1378](https://github.com/chocolatey/choco/issues/1378)

# SEE ALSO

[Chocolatey](https://chocolatey.org/)
[log4net](https://logging.apache.org/log4net/)

# KEYWORDS

- Chocolatey
- Log4Net
- ChocoLog
- Log4NetLog
- Log4NetLine
