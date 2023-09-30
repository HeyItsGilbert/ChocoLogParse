# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.5.0] Add Get-ChocoLogEntry

Add a new cmdlet that grabs the latest log. Has a report flag that may make it
convenient for reporting back to tools.

## [0.4.0] Fix external dependency

The dependency on Log4Net was added incorrectly as an external dependency.

## [0.3.0] Improved Configuration Property

The configuration property now supports sub keys to improve filtering.

This also includes a fix to handle multiple threads being mixed.

## [0.2.0] Formatting

This adds a ChocoLog specific format. The goal is to show relevant info such as
CLI items when just printing the object to the screen.

## [0.1.0] Unreleased

First stab at using Log4NetParse module to parse Chocolatey. First version will
just read the Chocolatey log(s).
