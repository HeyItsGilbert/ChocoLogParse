# ChocoLogParse

Parses Chocolatey logs into easy to use objects.

[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/ChocoLogParse)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/ChocoLogParse)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/HeyItsGilbert/ChocoLogParse/.github/workflows/CI.yaml?branch=main)
![PowerShell Gallery](https://img.shields.io/powershellgallery/p/ChocoLogParse)](https://www.powershellgallery.com/packages/ChocoLogParse/)

Docs automatically updated at [heyitsgilbert.github.io/ChocoLogParse](https://heyitsgilbert.github.io/ChocoLogParse/)

Available via the [PowerShell Gallery](https://www.powershellgallery.com/packages/ChocoLogParse/)

## Overview

Parsing the Chocolatey logs can be daunting because at first glance it's
difficult to see when things change from one thread to the next. Other tools
like `cmtrace` don't support the Log4Net format. This module gives you a simple
way of converting the logs into a simple to parse/filter objects.

To also help improve discoverability we included an object formatter so that you
can quickly see error log entries, etc.

## Installation

```powershell
Install-Module ChocoLogParse
```

## Examples

To parse the latest Chocolatey log file run the following.

```powershell
Import-Module ChocoLogParse
$logs = Read-ChocoLog
```

Find install attempts of specific app (zoom in this example)

```powershell
Read-ChocoLog | ?{ $_.cli -like "*zoom*"}
```

Once you found your thread you might want to filter in/out debug.

```powershell
$logs[0].logs | ?{ $_.level -ne 'DEBUG' }
```

To grab the latest log you can use `Get-ChocoLogEntry`. Which is also includes
a `-Report` flag to print an easier to read set of logs and highlight some
key information at the top.

```powershell
Get-ChocoLogEntry
```
Get more details at [heyitsgilbert.github.io/ChocoLogParse](https://heyitsgilbert.github.io/ChocoLogParse/)

## Building and Testing

If you want to contribute or would like to make a local build you just need to
run the `build.ps1` script with the relevant task.

For your first run you'll want to run the Bootstrap which will fetch all the
appropriate modules and tools (as seen in the `requirements.ps1`).

```powershell
.\build.ps1 -Bootstrap -Task Test
```

Building and testing works on Windows PowerShell and PowerShell Core.
