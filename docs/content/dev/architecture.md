---
title: Architecture & Design
weight: 1
toc: true
---

## Overview

Winutil is a PowerShell-based Windows utility with a WPF (Windows Presentation Foundation) GUI. This document explains the architecture, code structure, and how different components work together.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────�?�?                   Winutil GUI                      �?�?             (WPF XAML Interface)                   �?└──────────────────┬──────────────────────────────────�?                   �?         ┌─────────┴─────────�?         �?                  �?┌────────▼──────�?  ┌───────▼────────�?�? Public APIs  �?  �? Private APIs  �?�? (User-facing)�?  �?  (Internal)   �?└───────┬───────�?  └───────┬────────�?        �?                  �?        └────────┬──────────�?                 �?    ┌────────────▼────────────�?    �?  Configuration Files   �?    �? (JSON definitions)     �?    └────────────┬────────────�?                 �?    ┌────────────▼────────────�?    �?  External Tools        �?    �? (WinGet, Chocolatey)   �?    └─────────────────────────�?```

## Project Structure

### Directory Layout

```
winutil/
├── Compile.ps1                 # Build script that combines all files
├── winutil.ps1                 # Compiled output (generated)
├── scripts/
�?  ├── main.ps1               # Entry point and GUI initialization
�?  └── start.ps1              # Startup logic
├── functions/
�?  ├── private/               # Internal helper functions
�?  �?  ├── Get-WinUtilVariables.ps1
�?  �?  ├── Install-WinUtilWinget.ps1
�?  �?  └── ...
�?  ├── public/                # User-facing functions
�?  �?  ├── Initialize-WPFUI.ps1
�?  �?  └── ...
├── config/                    # JSON configuration files
�?  ├── applications.json      # Application definitions
�?  ├── tweaks.json           # Tweak definitions
�?  ├── feature.json          # Windows feature definitions
�?  └── preset.json           # Preset configurations
├── xaml/
�?  └── inputXML.xaml         # GUI layout definition
└── docs/                     # Documentation
```

### Key Components

#### 1. Compile.ps1
**Purpose**: Combines all separate script files into a single `winutil.ps1` for distribution.

**Process**:
1. Reads all function files from `/functions/`
2. Includes configuration JSON files
3. Embeds XAML GUI definition
4. Combines into single script
5. Outputs `winutil.ps1`

**Why**: Makes distribution easier (single file) and improves load time.

#### 2. scripts/main.ps1
**Purpose**: Entry point that initializes the GUI and event system.

**Responsibilities**:
- Load XAML and create WPF window
- Initialize form elements
- Set up event handlers
- Load configurations
- Display the GUI

#### 3. functions/public/
**Purpose**: User-facing functions that implement main features.

**Key Functions**:
- `Initialize-WPFUI.ps1`: Sets up the GUI
- `Invoke-WPFTweak*`: Applies system tweaks
- `Invoke-WPFFeature*`: Enables Windows features
- `Install-WinUtilProgram*`: Installs applications

**Naming Convention**: Functions start with `WPF` or `Winutil` to be loaded into the runspace.

#### 4. functions/private/
**Purpose**: Internal helper functions not directly called by users.

**Key Functions**:
- `Get-WinUtilVariables.ps1`: Retrieves UI element references
- `Install-WinUtilWinget.ps1`: Ensures WinGet is installed
- `Get-WinUtilCheckBoxes.ps1`: Gets checkbox states
- `Invoke-WinUtilCurrentSystem.ps1`: Gets system information

#### 5. config/*.json
**Purpose**: Define available applications, tweaks, and features declaratively.

**Files**:
- `applications.json`: Application definitions with WinGet/Choco IDs
- `tweaks.json`: Registry tweaks and their undo actions
- `feature.json`: Windows features that can be enabled/disabled
- `preset.json`: Predefined tweak combinations
- `dns.json`: DNS provider configurations

#### 6. xaml/inputXML.xaml
**Purpose**: WPF GUI layout and design.

**Structure**:
- Buttons with event handlers
- TextBoxes for input
- CheckBoxes for options
- ListBoxes for selections

## Win11 Creator Architecture

The **Win11 Creator** is a specialized subsystem within Winutil that creates customized Windows 11 ISOs. It operates independently from the main package installation and tweak system.

### Win11 Creator Components

**Core Functions** (`functions/private/`):
- `Invoke-WinUtilISO.ps1`: Main orchestrator containing all Win11 Creator functions
  - `Invoke-WinUtilISOBrowse`: ISO file selection dialog
  - `Invoke-WinUtilISOMountAndVerify`: Validates and mounts ISO, verifies it's official Windows 11
  - `Invoke-WinUtilISOModify`: Launches modification in background runspace
  - `Invoke-WinUtilISOExport`: Handles ISO and USB export
  - `Invoke-WinUtilISOCheckExistingWork`: Recovers incomplete work sessions
  - `Invoke-WinUtilISOCleanAndReset`: Cleans up temp directories and resets UI

- `Invoke-WinUtilISOScript.ps1`: Applies modifications to mounted install.wim
  - Removes provisioned AppX packages (40+ bloatware apps)
  - Injects drivers (optional) from current system
  - Removes OneDrive setup files
  - Applies offline registry tweaks (hardware bypass, privacy, telemetry, OOBE)
  - Deletes telemetry scheduled task definitions
  - Pre-stages setup scripts from autounattend.xml
  - Removes unused Windows editions
  - Cleans component store via DISM

### Win11 Creator Data Flow

```
User selects official Windows 11 ISO
    �?Invoke-WinUtilISOBrowse �?OpenFileDialog, validates file size
    �?Invoke-WinUtilISOMountAndVerify
    ├─ Mount ISO via Mount-DiskImage
    ├─ Verify install.wim or install.esd exists
    ├─ Check for "Windows 11" in image metadata
    ├─ Extract available editions (Home, Pro, Enterprise, etc.)
    └─ Store ISO path, drive letter, WIM path, image info in $sync
    �?User optionally enables Driver Injection checkbox
    �?Invoke-WinUtilISOModify (runs in background runspace)
    ├─ Create work directory: ~WinUtil_Win11ISO_[timestamp]
    ├─ Copy ISO contents to disk (~5-6 GB)
    ├─ Mount install.wim at selected edition/index
    ├─ Invoke-WinUtilISOScript:
    �?  ├─ Remove 40+ bloat AppX packages
    �?  ├─ Export and inject drivers (if enabled)
    �?  ├─ Remove OneDrive setup
    �?  ├─ Load offline registry hives
    �?  ├─ Apply 50+ registry tweaks (hardware bypass, privacy, telemetry, OOBE, etc.)
    �?  ├─ Delete telemetry scheduled task files
    �?  ├─ Pre-stage setup scripts from autounattend.xml to C:\Windows\Setup\Scripts\
    �?  └─ Unload registry hives
    ├─ DISM /Cleanup-Image /StartComponentCleanup /ResetBase (saves 300-800 MB)
    ├─ Dismount and save modified install.wim (~10+ minutes, slowest step)
    ├─ Export selected edition only (removes all other editions, saves 1-2 GB each)
    ├─ Dismount source ISO
    └─ Report completion, enable export options
    �?Invoke-WinUtilISOExport (user chooses output)
    ├─ Option 1: Save as ISO
    �?  ├─ Build bootable ISO via oscdimg.exe (BIOS/UEFI dual-boot)
    �?  └─ Output: Win11_Modified_[date].iso (2.5-3.5 GB)
    �?    └─ Option 2: Write to USB
        ├─ Format USB as GPT
        ├─ Create 512 MB EFI partition
        ├─ Copy modified ISO contents
        └─ Output: Bootable USB (minimum 8 GB)
    �?Invoke-WinUtilISOCleanAndReset (optional)
    └─ Delete temp working directory (~10-15 GB)
    └─ Reset UI to initial state
```

### Win11 Creator Validation & Safety

**ISO Validation**:
- Only accepts official Microsoft Windows 11 ISOs
- Validates presence of install.wim or install.esd
- Checks image metadata for "Windows 11" string
- Rejects custom, modified, or non-Windows 11 ISOs

**Work Session Recovery**:
- Auto-detects incomplete work from previous sessions
- Allows resuming Step 4 (export) without re-running Steps 1-3
- Prevents redundant modifications

**Modification Safety**:
- All registry changes are documented in script (reversible)
- Original ISO never modified; only working copy
- Logged to `WinUtil_Win11ISO.log` for debugging
- DISM handles image dismount with automatic cleanup on error

### Win11 Creator Registry Tweaks

The `Invoke-WinUtilISOScript` function applies **50+ offline registry tweaks**:

**Hardware Bypass**:
- TPM 2.0 check bypass
- Secure Boot requirement bypass
- CPU compatibility bypass
- RAM requirement bypass
- Storage check bypass

**Privacy & Telemetry**:
- Disable advertising ID
- Disable tailored experiences
- Disable input personalization
- Disable speech online privacy
- Disable cloud content suggestions
- Disable app suggestion subscriptions
- Remove CEIP, Appraiser, WaaSMedic, etc.

**OOBE & Setup**:
- Enable local account setup
- Skip Microsoft account requirement
- Dark mode by default
- Empty taskbar and Start Menu

**Post-Setup Installations**:
- Prevent DevHome auto-installation
- Prevent new Outlook Mail app installation
- Prevent Teams auto-installation

**System Features**:
- Disable BitLocker and device encryption
- Disable Chat icon from taskbar
- Disable OneDrive folder backup
- Disable Copilot
- Disable Windows Update during OOBE (re-enabled at first login)

### Driver Injection Feature

**Optional Enhancement**: When enabled, exports all drivers from the running system and injects them into both:
- `install.wim` (main OS image)
- `boot.wim` index 2 (Windows Setup PE environment)

**Use Case**: Enables offline installation on systems with missing drivers.

### Disk Space Requirements

- **Temporary working directory**: ~10-15 GB
- **Original ISO**: 4-6 GB
- **Modified ISO**: 2.5-3.5 GB
- **Total needed**: ~25 GB for safe operation

## Data Flow

### Application Installation Flow

```
User clicks "Install"
    �?Get-WinUtilCheckBoxes �?Retrieves selected apps
    �?For each selected app:
    �?Check if WinGet/Choco installed
    �?Install-WinUtilWinget/Choco (if needed)
    �?Install-WinUtilProgramWinget/Choco �?Install app
    �?Update UI with progress
    �?Display completion message
```

### Tweak Application Flow

```
User selects tweaks and clicks "Run Tweaks"
    �?Get-WinUtilCheckBoxes �?Get selected tweaks
    �?For each selected tweak:
    �?Load tweak definition from tweaks.json
    �?Invoke-WPFTweak �?Apply registry/service changes
    �?Log changes
    �?Store original values (for undo)
    �?Update UI
    �?Display completion
```

### Undo Tweak Flow

```
User selects tweaks and clicks "Undo"
    �?Get-WinUtilCheckBoxes �?Get selected tweaks
    �?For each tweak:
    �?Retrieve "OriginalState" from tweak definition
    �?Invoke-WPFUndoTweak �?Restore original values
    �?Remove from applied tweaks log
    �?Update UI
```

## Configuration File Format

### applications.json Structure

```json {filename="config/applications.json"}
{
  "WPFInstall<AppName>": {
    "category": "Browsers",
    "choco": "googlechrome",
    "content": "Google Chrome",
    "description": "Google Chrome browser",
    "link": "https://chrome.google.com",
    "winget": "Google.Chrome"
  }
}
```

**Fields**:
- `category`: Which section in the Install tab
- `content`: Display name in GUI
- `description`: Tooltip/description text
- `winget`: WinGet package ID
- `choco`: Chocolatey package name
- `link`: Official website

### tweaks.json Structure

```json {filename="config/tweaks.json"}
{
  "WPFTweaksTelemetry": {
    "Content": "Disable Telemetry",
    "Description": "Disables Microsoft Telemetry",
    "category": "Essential Tweaks",
    "panel": "1",
    "registry": [
      {
        "Path": "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection",
        "Name": "AllowTelemetry",
        "Type": "DWord",
        "Value": "0",
        "OriginalValue": "1"
      }
    ],
    "ScheduledTask": [
      {
        "Name": "Microsoft\\Windows\\Autochk\\Proxy",
        "State": "Disabled",
        "OriginalState": "Enabled"
      }
    ]
  }
}
```

**Fields**:
- `Content`: Display name
- `Description`: What it does
- `category`: Essential/Advanced/Customize
- `registry`: Registry changes to make
- `ScheduledTask`: Scheduled tasks to modify
- `service`: Services to change
- `OriginalValue/State`: For undo functionality

## PowerShell Runspace

Winutil uses PowerShell runspaces for the GUI to remain responsive:

```powershell
# Create runspace
$sync.runspace = [runspacefactory]::CreateRunspace()
$sync.runspace.Open()
$sync.runspace.SessionStateProxy.SetVariable("sync", $sync)

# Run code in background
$powershell = [powershell]::Create().AddScript($scriptblock)
$powershell.Runspace = $sync.runspace
$handle = $powershell.BeginInvoke()
```

**Why**: Prevents UI freezing during long-running operations.

## WPF Event Handling

Events are wired up via XAML element names:

```powershell
# Get all named elements
$sync.keys | ForEach-Object {
    if($sync.$_.GetType().Name -eq "Button") {
        $sync.$_.Add_Click({
            $button = $sync.$($args[0].Name)
            & "Invoke-$($args[0].Name)"
        })
    }
}
```

**Convention**: Button named `WPFInstallButton` calls function `Invoke-WPFInstallButton`.

## Package Manager Integration

### WinGet Integration

```powershell
# Check if installed
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Install-WinUtilWinget
}

# Install package
winget install --id $app.winget --silent --accept-source-agreements
```

### Chocolatey Integration

```powershell
# Check if installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Install-WinUtilChoco
}

# Install package
choco install $app.choco -y
```

## Error Handling

Winutil uses PowerShell error handling:

```powershell
try {
    # Attempt operation
    Invoke-SomeOperation
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    # Log error
    Add-Content -Path $logfile -Value "ERROR: $_"
}
```

**Logging**: Errors and operations are logged for debugging.

## Configuration Loading

At startup, Winutil loads all configurations:

```powershell
# Load JSON configs
$sync.configs = @{}
$sync.configs.applications = Get-Content "config/applications.json" | ConvertFrom-Json
$sync.configs.tweaks = Get-Content "config/tweaks.json" | ConvertFrom-Json
$sync.configs.features = Get-Content "config/feature.json" | ConvertFrom-Json
```

**Sync Hash**: `$sync` hashtable shares state across runspaces.

## UI Update Pattern

UI updates must happen on the UI thread:

```powershell
$sync.form.Dispatcher.Invoke([action]{
    $sync.WPFStatusLabel.Content = "Installing..."
}, "Normal")
```

**Why**: WPF requires UI updates on the main thread.

## Adding New Features

### Adding a New Application

1. Edit `config/applications.json`:
```json {filename="config/applications.json"}
{
  "WPFInstallNewApp": {
    "category": "Utilities",
    "content": "New App",
    "description": "Description of new app",
    "winget": "Publisher.AppName",
    "choco": "appname"
  }
}
```

2. Recompile: `.\Compile.ps1`
3. The app appears automatically in Install tab

### Adding a New Tweak

1. Edit `config/tweaks.json`:
```json {filename="config/tweaks.json"}
{
  "WPFTweaksNewTweak": {
    "Content": "New Tweak",
    "Description": "What it does",
    "category": "Essential Tweaks",
    "registry": [
      {
        "Path": "HKLM:\\Path\\To\\Key",
        "Name": "ValueName",
        "Type": "DWord",
        "Value": "1",
        "OriginalValue": "0"
      }
    ]
  }
}
```

2. Recompile: `.\Compile.ps1`
3. Tweak appears in Tweaks tab

### Adding a New Function

1. Create file in `functions/public/` or `functions/private/`:
```powershell
# functions/public/Invoke-WPFNewFeature.ps1
function Invoke-WPFNewFeature {
    <#
    .SYNOPSIS
    Does something new
    #>
    # Implementation
}
```

2. File naming must include "WPF" or "Winutil" to load
3. Recompile: `.\Compile.ps1`

## Testing

### Manual Testing

```powershell
# Compile and run with -run flag
.\Compile.ps1 -run
```

### Automated Tests

Tests are in `/pester/`:
- `configs.Tests.ps1`: Validates JSON configurations
- `functions.Tests.ps1`: Tests PowerShell functions

Run tests:
```powershell
Invoke-Pester
```

## Build Process

### Development Build

```powershell
.\Compile.ps1
```

Outputs `winutil.ps1` in the root directory.

### Production Release

1. Tag release in Git
2. GitHub Actions builds and uploads `winutil.ps1`
3. Release appears on GitHub Releases
4. Users download via `irm christitus.com/win`

## Dependencies

**Required**:
- PowerShell 5.1+
- .NET Framework 4.5+
- Windows 11

**Optional (auto-installed)**:
- WinGet (Windows Package Manager)
- Chocolatey

## Performance Considerations

**Optimization Strategies**:
- Lazy-load configurations (only when needed)
- Use runspaces for long operations
- Cache expensive lookups
- Minimize registry reads/writes
- Batch operations when possible

## Security Considerations

**Safety Measures**:
- All operations logged
- Registry backups for undo
- No credential storage
- Open source (auditable)
- Digitally signed (future)

## Contributing Guidelines

**Code Standards**:
- Use proper PowerShell cmdlet naming (Verb-Noun)
- Include comment-based help
- Follow existing code style
- Test thoroughly before PR
- Document significant changes

**File Naming**:
- Public functions: `Invoke-WPF*.ps1` or `Invoke-Winutil*.ps1`
- Private functions: `Get-WinUtil*.ps1` or verb-WinUtil*.ps1`
- Must include "WPF" or "Winutil" to load

## Future Architecture Plans

**Roadmap Considerations**:
- Plugin system for community extensions
- Config import/export
- Cloud sync for configurations
- Enhanced logging dashboard
- Modular compilation (choose features)

## Related Documentation

- [Contributing Guide](../../contributing/) - How to contribute code
- [User Guide](../../userguide/) - End-user documentation
- [Win11 Creator Guide](../../userguide/win11Creator/) - Building customized Windows 11 ISOs
- [FAQ](../../faq/) - Common questions

## Additional Resources

- **GitHub Repository**: [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil)
- **PowerShell Docs**: [Microsoft Docs](https://docs.microsoft.com/powershell/)
- **WPF Guide**: [WPF Documentation](https://docs.microsoft.com/dotnet/desktop/wpf/)

---

**Last Updated**: January 2026
**Maintainers**: Chris Titus Tech and contributors
