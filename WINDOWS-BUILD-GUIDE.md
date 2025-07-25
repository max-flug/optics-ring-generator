# Building Complete Windows Installer on Windows Machine

## 🎯 Quick Overview
This guide shows you how to build a complete single-file Windows installer (`OpticsRingGenerator-Windows-Installer.ps1`) that contains everything needed for installation.

## 📋 Prerequisites

### 1. Install Rust
```powershell
# Download and run the Rust installer
Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile "rustup-init.exe"
.\rustup-init.exe
```
Or visit: https://rustup.rs/

### 2. Install Git (if not already installed)
Download from: https://git-scm.com/download/win

## 🚀 Step-by-Step Instructions

### Step 1: Clone the Repository
```powershell
# Clone your repository
git clone https://github.com/max-flug/optics-ring-generator.git
cd optics-ring-generator
```

### Step 2: Build the Windows Binary
```powershell
# Build the release binary
cargo build --release

# Verify the binary was created
dir target\release\optics-ring-generator.exe
```

### Step 3: Create the Complete Installer

#### Option A: Use the Automated Script (Recommended)
```powershell
# Create complete installer with embedded binary
powershell -ExecutionPolicy Bypass -File .\build-windows-installer.ps1
```

#### Option B: Manual Creation
If the automated script doesn't work, here's the manual process:

```powershell
# 1. Create the installer script template
$binaryPath = "target\release\optics-ring-generator.exe"

# 2. Convert binary to base64
$binaryBytes = [System.IO.File]::ReadAllBytes($binaryPath)
$binaryBase64 = [System.Convert]::ToBase64String($binaryBytes)

# 3. Create the complete installer
@"
# OpticRingGenerator Complete Windows Installer
# This installer contains the embedded binary

#Requires -RunAsAdministrator

param(
    [switch]`$Uninstall
)

`$ErrorActionPreference = "Stop"

# Configuration
`$AppName = "OpticRingGenerator"
`$Publisher = "OpticRingGenerator"
`$Version = "1.0.0"
`$InstallDir = "`$env:ProgramFiles\`$AppName"
`$StartMenuFolder = "`$env:ProgramData\Microsoft\Windows\Start Menu\Programs\`$AppName"
`$DesktopShortcut = "`$env:PUBLIC\Desktop\`$AppName.lnk"
`$BinaryName = "optics-ring-generator.exe"

function Write-ColorText {
    param([string]`$Text, [string]`$Color = "White")
    Write-Host `$Text -ForegroundColor `$Color
}

function Test-Administrator {
    `$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    `$principal = New-Object Security.Principal.WindowsPrincipal(`$currentUser)
    return `$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-ColorText "❌ This installer must be run as Administrator!" "Red"
    Write-ColorText "   Right-click on PowerShell and select 'Run as Administrator'" "Yellow"
    Read-Host "Press Enter to exit"
    exit 1
}

if (`$Uninstall) {
    Write-ColorText "🗑️  Uninstalling `$AppName..." "Yellow"
    
    # Remove files
    if (Test-Path `$InstallDir) {
        Remove-Item -Path `$InstallDir -Recurse -Force
        Write-ColorText "✅ Removed installation directory" "Green"
    }
    
    # Remove shortcuts
    if (Test-Path `$DesktopShortcut) {
        Remove-Item -Path `$DesktopShortcut -Force
        Write-ColorText "✅ Removed desktop shortcut" "Green"
    }
    
    if (Test-Path `$StartMenuFolder) {
        Remove-Item -Path `$StartMenuFolder -Recurse -Force
        Write-ColorText "✅ Removed start menu entries" "Green"
    }
    
    # Remove from registry
    `$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\`$AppName"
    if (Test-Path `$regPath) {
        Remove-Item -Path `$regPath -Force
        Write-ColorText "✅ Removed registry entries" "Green"
    }
    
    # Remove from PATH
    `$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (`$currentPath -like "*`$InstallDir*") {
        `$newPath = `$currentPath -replace [regex]::Escape(";`$InstallDir"), ""
        `$newPath = `$newPath -replace [regex]::Escape("`$InstallDir;"), ""
        `$newPath = `$newPath -replace [regex]::Escape("`$InstallDir"), ""
        [Environment]::SetEnvironmentVariable("Path", `$newPath, "Machine")
        Write-ColorText "✅ Removed from system PATH" "Green"
    }
    
    Write-ColorText "🎉 `$AppName has been successfully uninstalled!" "Green"
    Read-Host "Press Enter to exit"
    exit 0
}

Write-ColorText "🚀 Installing `$AppName v`$Version..." "Cyan"
Write-ColorText "   Publisher: `$Publisher" "Gray"
Write-ColorText "   Install Location: `$InstallDir" "Gray"
Write-ColorText ""

# Create installation directory
Write-ColorText "📁 Creating installation directory..." "Yellow"
if (-not (Test-Path `$InstallDir)) {
    New-Item -Path `$InstallDir -ItemType Directory -Force | Out-Null
}

# Extract embedded binary
Write-ColorText "📦 Extracting application binary..." "Yellow"
`$binaryPath = "`$InstallDir\`$BinaryName"

# Embedded binary data (base64 encoded)
`$binaryData = @"
$binaryBase64
"@

try {
    `$binaryBytes = [System.Convert]::FromBase64String(`$binaryData)
    [System.IO.File]::WriteAllBytes(`$binaryPath, `$binaryBytes)
    Write-ColorText "✅ Binary extracted successfully" "Green"
} catch {
    Write-ColorText "❌ Failed to extract binary: `$(`$_.Exception.Message)" "Red"
    exit 1
}

# Add to system PATH
Write-ColorText "🔗 Adding to system PATH..." "Yellow"
`$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if (`$currentPath -notlike "*`$InstallDir*") {
    `$newPath = "`$currentPath;`$InstallDir"
    [Environment]::SetEnvironmentVariable("Path", `$newPath, "Machine")
    Write-ColorText "✅ Added to system PATH" "Green"
}

# Create Start Menu shortcuts
Write-ColorText "📎 Creating shortcuts..." "Yellow"
if (-not (Test-Path `$StartMenuFolder)) {
    New-Item -Path `$StartMenuFolder -ItemType Directory -Force | Out-Null
}

`$WshShell = New-Object -comObject WScript.Shell

# Start Menu shortcut
`$StartMenuShortcut = `$WshShell.CreateShortcut("`$StartMenuFolder\`$AppName.lnk")
`$StartMenuShortcut.TargetPath = `$binaryPath
`$StartMenuShortcut.WorkingDirectory = `$InstallDir
`$StartMenuShortcut.Description = "3D Printable Precision Optics Support Ring Generator"
`$StartMenuShortcut.Arguments = "--ui"
`$StartMenuShortcut.Save()

# Start Menu CLI shortcut
`$StartMenuCLIShortcut = `$WshShell.CreateShortcut("`$StartMenuFolder\`$AppName (CLI).lnk")
`$StartMenuCLIShortcut.TargetPath = "cmd.exe"
`$StartMenuCLIShortcut.WorkingDirectory = `$env:USERPROFILE
`$StartMenuCLIShortcut.Description = "OpticRingGenerator Command Line Interface"
`$StartMenuCLIShortcut.Arguments = "/k echo OpticRingGenerator CLI - Type 'optics-ring-generator --help' for usage"
`$StartMenuCLIShortcut.Save()

# Desktop shortcut
`$DesktopShortcutObj = `$WshShell.CreateShortcut(`$DesktopShortcut)
`$DesktopShortcutObj.TargetPath = `$binaryPath
`$DesktopShortcutObj.WorkingDirectory = `$InstallDir
`$DesktopShortcutObj.Description = "3D Printable Precision Optics Support Ring Generator"
`$DesktopShortcutObj.Arguments = "--ui"
`$DesktopShortcutObj.Save()

# Add to Windows Programs and Features
Write-ColorText "📋 Registering with Windows..." "Yellow"
`$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\`$AppName"
New-Item -Path `$regPath -Force | Out-Null
Set-ItemProperty -Path `$regPath -Name "DisplayName" -Value `$AppName
Set-ItemProperty -Path `$regPath -Name "DisplayVersion" -Value `$Version
Set-ItemProperty -Path `$regPath -Name "Publisher" -Value `$Publisher
Set-ItemProperty -Path `$regPath -Name "InstallLocation" -Value `$InstallDir
Set-ItemProperty -Path `$regPath -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File \"`$(`$MyInvocation.MyCommand.Path)\" -Uninstall"
Set-ItemProperty -Path `$regPath -Name "DisplayIcon" -Value `$binaryPath
Set-ItemProperty -Path `$regPath -Name "NoModify" -Value 1
Set-ItemProperty -Path `$regPath -Name "NoRepair" -Value 1
Set-ItemProperty -Path `$regPath -Name "EstimatedSize" -Value 5000

Write-ColorText ""
Write-ColorText "🎉 Installation completed successfully!" "Green"
Write-ColorText ""
Write-ColorText "📋 Installation Summary:" "Cyan"
Write-ColorText "   • Program installed to: `$InstallDir" "White"
Write-ColorText "   • Added to system PATH" "White"
Write-ColorText "   • Desktop shortcut created" "White"
Write-ColorText "   • Start menu entries created" "White"
Write-ColorText "   • Registered in Programs and Features" "White"
Write-ColorText ""
Write-ColorText "🚀 You can now run `$AppName:" "Cyan"
Write-ColorText "   • Double-click desktop shortcut (UI mode)" "White"
Write-ColorText "   • Start Menu → `$AppName (UI mode)" "White"
Write-ColorText "   • Start Menu → `$AppName (CLI)" "White"
Write-ColorText "   • Command line: optics-ring-generator" "White"
Write-ColorText "   • Command line UI: optics-ring-generator --ui" "White"
Write-ColorText ""
Write-ColorText "📖 Usage Examples:" "Cyan"
Write-ColorText "   optics-ring-generator --help" "White"
Write-ColorText "   optics-ring-generator CX --outer-diameter 30 --inner-diameter 25" "White"
Write-ColorText "   optics-ring-generator --ui" "White"
Write-ColorText ""
Write-ColorText "ℹ️  To uninstall:" "Gray"
Write-ColorText "   • Use Windows Settings → Apps & features, or" "Gray"
Write-ColorText "   • Run this installer with -Uninstall parameter" "Gray"
Write-ColorText ""

Read-Host "Press Enter to exit"
"@ | Out-File -FilePath "OpticsRingGenerator-Windows-Installer.ps1" -Encoding UTF8

Write-Host "✅ Created OpticsRingGenerator-Windows-Installer.ps1" -ForegroundColor Green
Write-Host "📦 File size: $([math]::Round((Get-Item "OpticsRingGenerator-Windows-Installer.ps1").Length / 1KB, 2)) KB" -ForegroundColor Gray
```

## 📦 Result

After running these steps, you'll have:
- **File**: `OpticsRingGenerator-Windows-Installer.ps1`
- **Type**: Single-file installer with embedded binary
- **Size**: Complete application embedded in PowerShell script
- **Features**: Full installation, shortcuts, registry integration, uninstall support

## 🚀 Testing the Installer

```powershell
# Test the installer (as Administrator)
PowerShell -ExecutionPolicy Bypass -File OpticsRingGenerator-Windows-Installer.ps1

# To uninstall later
PowerShell -ExecutionPolicy Bypass -File OpticsRingGenerator-Windows-Installer.ps1 -Uninstall
```

## 📋 What the Installer Does

1. **Checks admin privileges** (requires Administrator)
2. **Extracts binary** to `C:\Program Files\OpticRingGenerator\`
3. **Creates shortcuts** on desktop and start menu
4. **Adds to system PATH** for command-line access
5. **Registers with Windows** (appears in Programs & Features)
6. **Supports clean uninstallation**

## 🎉 Distribution

The resulting `OpticsRingGenerator-Windows-Installer.ps1` file is:
- ✅ **Self-contained** (no external dependencies)
- ✅ **Single file** (exactly what you requested)
- ✅ **Professional** (full Windows integration)
- ✅ **Ready to distribute** (can be shared via email, download, etc.)

This is your complete single-file Windows installer! 🎊
