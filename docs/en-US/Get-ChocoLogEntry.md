---
external help file: ChocoLogParse-help.xml
Module Name: ChocoLogParse
online version:
schema: 2.0.0
---

# Get-ChocoLogEntry

## SYNOPSIS
Grab a single session from the latest log file.
Defaults to last exection.

## SYNTAX

```
Get-ChocoLogEntry [[-Path] <String[]>] [[-Filter] <String>] [[-PatternLayout] <String>] [-Report]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads the latest log file and grabs the last session

## EXAMPLES

### EXAMPLE 1
```
Get-ChocoLogEntry
```

Grabs the laste entry from the latest log

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

### -Filter
The filter passed to Get Child Item.
Default to 'chocolatey*.log.'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
Default value: %date %thread [%-5level] - %message
Accept pipeline input: False
Accept wildcard characters: False
```

### -Report
This changes the output to be more friendly for reporting

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

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Works for Windows PowerShell and PowerShell Core (e.g.
7).

## RELATED LINKS
