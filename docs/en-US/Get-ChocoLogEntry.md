---
external help file: ChocoLogParse-help.xml
Module Name: ChocoLogParse
online version: https://heyitsgilbert.github.io/ChocoLogParse/en-US/Get-ChocoLogEntry/
schema: 2.0.0
---

# Get-ChocoLogEntry

## SYNOPSIS
Grab a single session from the latest log file.
Defaults to last exection.

## SYNTAX

```
Get-ChocoLogEntry [[-Path] <String[]>] [[-Filter] <String>] [[-PatternLayout] <String>] [-Report]
 [<CommonParameters>]
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
{{ Fill Path Description }}

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
{{ Fill Filter Description }}

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
{{ Fill PatternLayout Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Works for Windows PowerShell and PowerShell Core (e.g.
7).

## RELATED LINKS

[https://heyitsgilbert.github.io/ChocoLogParse/en-US/Get-ChocoLogEntry/](https://heyitsgilbert.github.io/ChocoLogParse/en-US/Get-ChocoLogEntry/)

