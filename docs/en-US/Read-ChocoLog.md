---
external help file: ChocoLogParse-help.xml
Module Name: ChocoLogParse
online version: https://heyitsgilbert.github.io/ChocoLogParse/en-US/Read-ChocoLog/
schema: 2.0.0
---

# Read-ChocoLog

## SYNOPSIS
Parses a Chocolatey log into an object that is easier to search and filter.

## SYNTAX

```
Read-ChocoLog [[-Path] <String[]>] [[-FileLimit] <Int32>] [[-Filter] <String>] [[-PatternLayout] <String>]
 [-NoColor] [<CommonParameters>]
```

## DESCRIPTION
Reads Chocolatey log(s) and creates a new set of custom objects.
It highlights
details that make it easier to search and filter.

## EXAMPLES

### EXAMPLE 1
```
Read-ChocoLog
```

This will read the latest Chocolatey.log on the machine.

## PARAMETERS

### -Path
The log path you want to parse.
This will default to the latest local log.
This can be a directory of logs.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$($env:ChocolateyInstall)\logs\"
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileLimit
The number of files the command should parse given a folder path.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
The filter passed to Get Child Item.
Default to 'chocolatey*.log.'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Chocolatey*.log
Accept pipeline input: False
Accept wildcard characters: False
```

### -PatternLayout
The log4net pattern layout used to parse the log.
It is very unlikely that you
need to supply this.
The code expects pattern names: time, session, level, and
message.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: %date %thread [%-5level] - %message
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoColor
Disables colored output in the formatter. When specified, the output will be
displayed without ANSI color codes.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.Generic.List`1[[ChocoLog, PowerShell Class Assembly, Version=1.0.0.3, Culture=neutral, PublicKeyToken=null]]
## NOTES
Works for Windows PowerShell and PowerShell Core.
This works on Linux.

## RELATED LINKS

[https://heyitsgilbert.github.io/ChocoLogParse/en-US/Read-ChocoLog/](https://heyitsgilbert.github.io/ChocoLogParse/en-US/Read-ChocoLog/)

