# ChocoLogParse PowerShell Module Development

ChocoLogParse is a cross-platform PowerShell module that parses Chocolatey logs into easy-to-use objects. The module works on both Windows PowerShell and PowerShell Core (Linux/macOS).

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Critical Environment Setup

### PowerShell Gallery Repository Setup
ALWAYS run these commands first in any fresh environment before attempting to build or test:

```powershell
# Register and configure PowerShell Gallery
Register-PSRepository -Default -ErrorAction SilentlyContinue
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -ErrorAction SilentlyContinue
```

If PSGallery setup fails, document the limitation but proceed with available commands.

## Bootstrap, Build, and Test

### Bootstrap Dependencies (NEVER CANCEL - Takes 2-5 minutes)
```powershell
.\build.ps1 -Bootstrap
```
- **NEVER CANCEL**: Bootstrap can take 2-5 minutes depending on network speed
- **TIMEOUT SETTING**: Set timeout to 10+ minutes (600+ seconds) to avoid premature cancellation
- Downloads and installs: PSDepend, Pester, psake, BuildHelpers, PowerShellBuild, PSScriptAnalyzer, Log4NetParse
- If bootstrap fails due to repository issues, install modules individually

### Alternative Manual Bootstrap (if automated bootstrap fails)
```powershell
# Install core dependencies manually
Install-Module -Name PSDepend -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name Pester -RequiredVersion 5.6.1 -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name psake -RequiredVersion 4.9.0 -Scope CurrentUser -Force
Install-Module -Name BuildHelpers -RequiredVersion 2.0.16 -Scope CurrentUser -Force
Install-Module -Name PowerShellBuild -RequiredVersion 0.6.1 -Scope CurrentUser -Force
Install-Module -Name PSScriptAnalyzer -RequiredVersion 1.19.1 -Scope CurrentUser -Force
Install-Module -Name Log4NetParse -RequiredVersion 1.1.2 -Scope CurrentUser -Force
```

### Build (NEVER CANCEL - Takes 1-3 minutes)
```powershell
.\build.ps1
```
- **NEVER CANCEL**: Build takes 1-3 minutes typically
- **TIMEOUT SETTING**: Set timeout to 10+ minutes (600+ seconds)
- Uses PowerShellBuild module via psake
- Creates compiled module in `Output/` directory

### Run Tests (NEVER CANCEL - Takes 1-2 minutes)
```powershell
.\build.ps1 -Task Test
```
- **NEVER CANCEL**: Tests take 1-2 minutes typically
- **TIMEOUT SETTING**: Set timeout to 10+ minutes (600+ seconds)
- Uses Pester 5.6.1 for testing
- Creates JUnit XML output in `out/testResults.xml`

### Combined Bootstrap and Test (NEVER CANCEL - Takes 3-8 minutes)
```powershell
.\build.ps1 -Bootstrap -Task Test
```
- **NEVER CANCEL**: Combined operation takes 3-8 minutes
- **TIMEOUT SETTING**: Set timeout to 20+ minutes (1200+ seconds)
- This is the recommended first-run command

## Development Workflow

### Available Build Tasks
Check available tasks:
```powershell
.\build.ps1 -Help
```

Common tasks:
- `default` - Runs the default task (Test)
- `Test` - Runs all tests
- `Build` - Builds the module
- `Clean` - Cleans build artifacts

### Module Structure
- `ChocoLogParse/` - Main module directory
  - `ChocoLogParse.psd1` - Module manifest
  - `ChocoLogParse.psm1` - Root module file
  - `Public/` - Public functions (Get-ChocoLogEntry.ps1, Read-ChocoLog.ps1)
  - `Classes/` - PowerShell classes
  - `Enum/` - PowerShell enumerations
- `tests/` - Test files (Pester tests)
- `docs/` - Documentation source (MkDocs)

### Import Module for Development
```powershell
# After building, import from Output directory
Import-Module .\Output\ChocoLogParse\<version>\ChocoLogParse.psd1 -Force
```

## Validation and Testing

### Syntax Validation (Always works)
ALWAYS run these commands first to validate PowerShell syntax:

```powershell
# Test PowerShell syntax of main files
$files = @('build.ps1', 'psakeFile.ps1', 'ChocoLogParse/ChocoLogParse.psm1')
foreach ($file in $files) {
    try {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$null, [ref]$null)
        if ($ast) { Write-Host "$file - Syntax OK" }
    } catch {
        Write-Host "$file - Syntax Error: $($_.Exception.Message)"
    }
}

# Test test file syntax
Get-ChildItem -Path tests -Filter '*.tests.ps1' | ForEach-Object {
    try {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$null)
        if ($ast) { Write-Host "$($_.Name) - Syntax OK" }
    } catch {
        Write-Host "$($_.Name) - Syntax Error: $($_.Exception.Message)"
    }
}
```

### Manual Function Testing (After successful build)
Always test the core functionality after making changes:

```powershell
# Import the module (after build completes)
Import-Module .\Output\ChocoLogParse\*\ChocoLogParse.psd1 -Force

# Test with the fixture file
$result = Read-ChocoLog -Path "tests\fixtures\ch.log"
$result | Should -Not -BeNullOrEmpty
$result[0].thread | Should -Be 14068
$result[0].logs.Count | Should -BeGreaterThan 0

# Test Get-ChocoLogEntry function
$entry = Get-ChocoLogEntry -Path "tests\fixtures\ch.log"
$entry | Should -Not -BeNullOrEmpty
```

### Alternative Testing (If dependencies fail)
If external dependencies are not available, test basic functionality:

```powershell
# Create test data manually
$testLog = @"
2024-07-03 06:44:28,288 14068 [DEBUG] - Cache Folder Lockdown Checks:
2024-07-03 06:44:28,289 14068 [DEBUG] -  - Elevated State = Failed
2024-07-03 06:44:28,304 14068 [DEBUG] - Configuration: CommandName='install'|Input='test'|
2024-07-03 06:44:28,305 14068 [INFO ] - Installing package: test
2024-07-03 06:44:28,306 14068 [DEBUG] - Exiting with 0
"@

# Save to test file
$testLog | Out-File -FilePath "test-chocolatey.log" -Encoding UTF8

# Manual validation of log format
$lines = Get-Content "test-chocolatey.log"
$lines.Count | Should -BeGreaterThan 0
$lines[0] | Should -Match "^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} \d+ \[(DEBUG|INFO|WARN|ERROR|FATAL)\]"

Write-Host "Manual validation complete - log format correct"
```

### Key Test Scenarios
Always run these validation scenarios after making changes:

1. **Parse single log file**: Test with a simple Chocolatey log
2. **Parse multiple log files**: Test with a directory of logs
3. **Get latest log entry**: Test Get-ChocoLogEntry function
4. **Configuration parsing**: Verify configuration data extraction
5. **Multi-thread handling**: Test logs with multiple thread IDs

### Pre-Commit Validation
ALWAYS run these commands before committing changes:
```powershell
# Run all tests
.\build.ps1 -Task Test

# Run script analyzer (if available)
Invoke-ScriptAnalyzer -Path .\ChocoLogParse\ -Recurse

# Test module import
Import-Module .\Output\ChocoLogParse\<version>\ChocoLogParse.psd1 -Force
Get-Command -Module ChocoLogParse
```

## CI/CD and Documentation

### GitHub Actions Workflows
- `.github/workflows/CI.yaml` - Continuous Integration (uses external HeyItsGilbert/.github workflow)
- `.github/workflows/publish.yaml` - Module publishing to PowerShell Gallery
- `.github/workflows/pages.yaml` - Documentation deployment to GitHub Pages

### Documentation
- Uses MkDocs for documentation generation
- Documentation site: https://heyitsgilbert.github.io/ChocoLogParse/
- Source files in `docs/` directory
- `mkdocs.yml` - MkDocs configuration

### Build Documentation Locally
```bash
# Install Python dependencies
pip install -r docs/requirements.txt

# Build and serve docs locally
mkdocs serve
```

## Common Issues and Solutions

### PowerShell Gallery Issues
If you encounter "No repository with the name 'PSGallery' was found":
```powershell
# First try to register the default repository
Register-PSRepository -Default -ErrorAction SilentlyContinue

# If that fails, try manual registration
Register-PSRepository -Name PSGallery -SourceLocation https://www.powershellgallery.com/api/v2 -InstallationPolicy Trusted
```

### PowerShell Environment Diagnosis
Run this to diagnose environment issues:
```powershell
# Check PowerShell version and edition
$PSVersionTable

# Check available repositories
Get-PSRepository -ErrorAction SilentlyContinue

# Check module paths
$env:PSModulePath -split [IO.Path]::PathSeparator

# Test basic module operations
Get-Command -Name Install-Module -ErrorAction SilentlyContinue
```

### Missing Dependencies
If Log4NetParse or other dependencies are missing:
```powershell
Install-Module -Name Log4NetParse -RequiredVersion 1.1.2 -Scope CurrentUser -Force -SkipPublisherCheck
```

### Build Failures
If build fails, try:
1. Clean the Output directory: `Remove-Item .\Output -Recurse -Force -ErrorAction SilentlyContinue`
2. Re-bootstrap: `.\build.ps1 -Bootstrap`
3. Check PowerShell version: Must be PowerShell 5.1+ or PowerShell Core 6.0+
4. Use syntax validation first to catch basic issues

### Test Failures
If tests fail:
1. Run syntax validation first
2. Ensure all dependencies are installed
3. Check that module builds successfully first
4. Use alternative testing with fixture files
5. Import the built module manually to test core functionality

### Environment Limitations Workaround
If PowerShell Gallery is completely unavailable:
1. Use syntax validation to check code quality
2. Test against fixture files in `tests\fixtures\`
3. Document the limitation but proceed with available validation
4. Use manual log format validation as shown in Alternative Testing section

## Common Repository Exploration Commands

To save time, use these frequently-used commands for quick codebase exploration:

### Repository Structure Overview
```powershell
# Repository root contents
Get-ChildItem -Force | Select-Object Name, Length, LastWriteTime

# Module structure
Get-ChildItem -Path ChocoLogParse -Recurse | Select-Object Name, Directory

# Test files overview
Get-ChildItem -Path tests -Filter "*.ps1" | Select-Object Name, Length
```

### Quick File Content Reference
Instead of viewing files individually, reference these common file contents:

#### Root Directory Files
```
README.md - Main documentation and usage examples
CHANGELOG.md - Version history and changes
build.ps1 - Build script with bootstrap functionality
psakeFile.ps1 - Build task definitions (uses PowerShellBuild)
requirements.psd1 - Dependencies: Pester, psake, BuildHelpers, etc.
mkdocs.yml - Documentation configuration
```

#### Module Files
```
ChocoLogParse/ChocoLogParse.psd1 - Module manifest (v1.0.1, requires Log4NetParse 1.1.2)
ChocoLogParse/ChocoLogParse.psm1 - Root module, loads Public functions and classes
ChocoLogParse/Public/Read-ChocoLog.ps1 - Main parsing function
ChocoLogParse/Public/Get-ChocoLogEntry.ps1 - Single entry retrieval
ChocoLogParse/Classes/ChocoLog.ps1 - Core ChocoLog class
ChocoLogParse/Enum/LogType.ps1 - Log level enumerations
```

#### Test Files
```
tests/ChocoLogParse.tests.ps1 - Main functionality tests
tests/Help.tests.ps1 - Documentation and help tests
tests/Manifest.tests.ps1 - Module manifest validation
tests/fixtures/ch.log - Sample Chocolatey log for testing
```

### Quick Configuration Check
```powershell
# View module manifest key details
$manifest = Import-PowerShellDataFile -Path ChocoLogParse\ChocoLogParse.psd1
Write-Host "Module Version: $($manifest.ModuleVersion)"
Write-Host "Required Modules: $($manifest.RequiredModules.ModuleName -join ', ')"
Write-Host "Functions to Export: $($manifest.FunctionsToExport)"

# View build configuration
$psakeConfig = Get-Content psakeFile.ps1
$psakeConfig | Where-Object { $_ -match 'PSBPreference' }
```

### Build System
- `build.ps1` - Main build script
- `psakeFile.ps1` - Build task definitions
- `requirements.psd1` - Dependency specifications

### Module Files
- `ChocoLogParse/ChocoLogParse.psd1` - Module manifest (version 1.0.1)
- `ChocoLogParse/ChocoLogParse.psm1` - Main module file
- `ChocoLogParse/Public/Read-ChocoLog.ps1` - Main parsing function
- `ChocoLogParse/Public/Get-ChocoLogEntry.ps1` - Single entry retrieval function

### Documentation
- `README.md` - Main documentation
- `CHANGELOG.md` - Version history
- `docs/` - MkDocs source files

ALWAYS wait for builds and tests to complete. NEVER cancel long-running operations. Set appropriate timeouts and be patient with the PowerShell module ecosystem.