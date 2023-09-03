# ChocoLogParse

Parses Chocolatey logs into easy to use objects.

## Overview

Parsing the Chocolatey logs can be daunting because at first glance it's
difficult to see when things changes from one thread to the next. Other tools
like `cmtrace` don't support the Log4Net format. This module gives you a simple
way of converting the logs into a simple to parse/filter objects.

## Installation

```powershell
Install-Module ChocoLogParse
```

## Examples

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
