---
external help file: ChocoLogParse-help.xml
Module Name: ChocoLogParse
online version:
schema: 2.0.0
---

# Read-ChocoLog

## SYNOPSIS
Parses a chocolatey into an object that is easier to search and filter.

## SYNTAX

```
Read-ChocoLog [[-Path] <String[]>] [[-FileLimit] <Int32>] [[-Filter] <String>] [[-PatternLayout] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Reads chocolatey log(s) and creates a new set of custom objects.
It highlights
details that make it easier to search and filter logs.

## EXAMPLES

### EXAMPLE 1
```
Read-ChocoLog
```

This will read the latest Chocolatey.log on the machine.

## PARAMETERS

### -Path
The log you want to parse.
This will default to the latest local log.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: C:\ProgramData\chocolatey\logs\
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileLimit
How many files should we parse a given folder path?

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
{{ Fill PatternLayout Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.ArrayList
## NOTES
Works for Windows PowerShell and PowerShell Core.
This works on Linux.

## RELATED LINKS

[Specify a URI to a help page, this will show when Get-Help -Online is used.]()

