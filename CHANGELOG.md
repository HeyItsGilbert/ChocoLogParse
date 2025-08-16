# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0] Add -NoColor Switch Parameter

### Added

- `-NoColor` switch parameter to both `Read-ChocoLog` and `Get-ChocoLogEntry` functions
- Module-level variable `$script:ChocoLogNoColor` to control formatter behavior
- Colored output control in `ChocoLog.format.ps1xml` formatter
- Documentation and examples for the new parameter

### Fixed

- Undefined `$bg` variable reference in the original formatter

## [1.0.1] Add Missing Fatal

### Fixes

- Adds missing FATAL from log type by bumping Log4NetParse to 1.1.2.

## [1.0.0] Handle Logs with Out of Order Threads

### Added

- Bump Log4NetParse dependency to 1.1.1 which handles threads better.
- Add TypeAccelerator for ChocoLog

## Removed

- Logs no longer returned for Log4NetLog format. It was suggested that
  this was noisy.

### Fixes

- Handle when logs that have thread lines that overlap.
- Fix tests to handle logs dates and ordering.

## [0.5.0] Add Get-ChocoLogEntry

- Add a new cmdlet that grabs the latest log.
  [#7](https://github.com/HeyItsGilbert/ChocoLogParse/issues/7)
  - Has a report flag that may make it convenient for reporting back to tools.
- Use environment variable `ChocolateyInstall` for default log location.
  [#8](https://github.com/HeyItsGilbert/ChocoLogParse/issues/8)
- Replace ArrayList types with GenericList
  [#9](https://github.com/HeyItsGilbert/ChocoLogParse/issues/9)

## [0.4.0] Fix external dependency

The dependency on Log4Net was added incorrectly as an external dependency.

## [0.3.0] Improved Configuration Property

The configuration property now supports sub keys to improve filtering.

This also includes a fix to handle multiple threads being mixed.
[#3](https://github.com/HeyItsGilbert/ChocoLogParse/issues/3)

## [0.2.0] Formatting

This adds a ChocoLog specific format. The goal is to show relevant info such as
CLI items when just printing the object to the screen.

## [0.1.0] Unreleased

First stab at using Log4NetParse module to parse Chocolatey. First version will
just read the Chocolatey log(s).
