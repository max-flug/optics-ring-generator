# OpticRingGenerator Windows Installer Builder
# Run this script on Windows to create a complete single-file installer

param(
    [switch]$SkipBuild,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
OpticRingGenerator Windows Installer Builder

Usage:
  .\build-complete-windows-installer.ps1           # Build binary and create installer
  .\build-complete-windows-installer.ps1 -SkipBuild # Create installer from existing binary
  .\build-complete-windows-installer.ps1 -Help     # Show this help

This script:
1. Builds the Windows binary (cargo build --release)
2. Embeds the binary in a PowerShell installer script
3. Creates a complete single-file installer

Output: OpticsRingGenerator-Windows-Installer.ps1
"@
    exit 0
}

$ErrorActionPreference = "Stop"

function Write-ColorText {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

Write-ColorText "🔧 OpticRingGenerator Windows Installer Builder" "Cyan"
Write-ColorText ""

# Check if we're in the right directory
if (-not (Test-Path "Cargo.toml")) {
    Write-ColorText "❌ Error: Cargo.toml not found!" "Red"
    Write-ColorText "   Please run this script from the project root directory." "Yellow"
    exit 1
}

# Build the binary unless skipped
$binaryPath = "target\release\optics-ring-generator.exe"

if (-not $SkipBuild) {
    Write-ColorText "📦 Building Windows binary..." "Yellow"
    cargo build --release
    if ($LASTEXITCODE -ne 0) {
        Write-ColorText "❌ Build failed!" "Red"
        exit 1
    }
    Write-ColorText "✅ Build completed successfully" "Green"
} else {
    Write-ColorText "⏭️  Skipping build (using existing binary)" "Yellow"
}

# Check if binary exists
if (-not (Test-Path $binaryPath)) {
    Write-ColorText "❌ Error: Binary not found at $binaryPath" "Red"
    Write-ColorText "   Try running without -SkipBuild flag" "Yellow"
    exit 1
}

# Get binary info
$binarySize = (Get-Item $binaryPath).Length
$binarySizeKB = [math]::Round($binarySize / 1KB, 2)
$binarySizeMB = [math]::Round($binarySize / 1MB, 2)

Write-ColorText "📊 Binary information:" "Cyan"
Write-ColorText "   Path: $binaryPath" "Gray"
Write-ColorText "   Size: $binarySizeKB KB ($binarySizeMB MB)" "Gray"

# Convert binary to base64
Write-ColorText "🔄 Converting binary to base64..." "Yellow"
$binaryBytes = [System.IO.File]::ReadAllBytes($binaryPath)
$binaryBase64 = [System.Convert]::ToBase64String($binaryBytes)
Write-ColorText "✅ Binary converted ($(($binaryBase64.Length / 1KB).ToString('F2')) KB base64)" "Green"

# Create the complete installer script
Write-ColorText "📝 Creating complete installer script..." "Yellow"

$installerContent = @"
# OpticRingGenerator Complete Windows Installer
# Generated on $(Get-Date)
# Binary size: $binarySizeKB KB ($binarySizeMB MB)

#Requires -RunAsAdministrator

param(
    [switch]`$Uninstall,
    [switch]`$ShowInfo
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

if (`$ShowInfo) {
    Write-ColorText "📋 OpticRingGenerator Windows Installer Information" "Cyan"
    Write-ColorText ""
    Write-ColorText "Binary Size: $binarySize bytes ($binarySizeKB KB)" "White"
    Write-ColorText "Installer Type: Single-file with embedded binary" "White"
    Write-ColorText "Target Platform: Windows x64" "White"
    Write-ColorText "Installation Location: `$InstallDir" "White"
    Write-ColorText "Generated: $(Get-Date)" "White"
    Write-ColorText ""
    Write-ColorText "Features:" "Yellow"
    Write-ColorText "  • Complete standalone installation" "White"
    Write-ColorText "  • Desktop and Start Menu shortcuts" "White"
    Write-ColorText "  • Registry integration" "White"
    Write-ColorText "  • Professional uninstallation" "White"
    Write-ColorText "  • PATH environment setup" "White"
    exit 0
}

function Test-Administrator {
    `$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    `$principal = New-Object Security.Principal.WindowsPrincipal(`$currentUser)
    return `$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-ColorText "❌ This installer must be run as Administrator!" "Red"
    Write-ColorText "   Right-click on PowerShell and select 'Run as Administrator'" "Yellow"
    Write-ColorText ""
    Write-ColorText "💡 To see installer info without installing, run:" "Cyan"
    Write-ColorText "   PowerShell -ExecutionPolicy Bypass -File \"`$(`$MyInvocation.MyCommand.Path)\" -ShowInfo" "White"
    Read-Host "Press Enter to exit"
    exit 1
}

if (`$Uninstall) {
    Write-ColorText "🗑️  Uninstalling `$AppName..." "Yellow"
    
    # Remove files
    if (Test-Path `$InstallDir) {
        Remove-Item -Path `$InstallDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-ColorText "✅ Removed installation directory" "Green"
    }
    
    # Remove shortcuts
    if (Test-Path `$DesktopShortcut) {
        Remove-Item -Path `$DesktopShortcut -Force -ErrorAction SilentlyContinue
        Write-ColorText "✅ Removed desktop shortcut" "Green"
    }
    
    if (Test-Path `$StartMenuFolder) {
        Remove-Item -Path `$StartMenuFolder -Recurse -Force -ErrorAction SilentlyContinue
        Write-ColorText "✅ Removed start menu entries" "Green"
    }
    
    # Remove from registry
    `$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\`$AppName"
    if (Test-Path `$regPath) {
        Remove-Item -Path `$regPath -Force -ErrorAction SilentlyContinue
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
Write-ColorText "   Binary Size: $binarySizeKB KB ($binarySizeMB MB)" "Gray"
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

# Start Menu shortcut (UI mode)
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
Set-ItemProperty -Path `$regPath -Name "EstimatedSize" -Value $([math]::Round($binarySize / 1024))

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
"@

# Write the installer file
$installerPath = "OpticsRingGenerator-Windows-Installer.ps1"
$installerContent | Out-File -FilePath $installerPath -Encoding UTF8

# Get final installer size
$installerSize = (Get-Item $installerPath).Length
$installerSizeKB = [math]::Round($installerSize / 1KB, 2)
$installerSizeMB = [math]::Round($installerSize / 1MB, 2)

Write-ColorText "✅ Complete installer created successfully!" "Green"
Write-ColorText ""
Write-ColorText "📊 Installer Information:" "Cyan"
Write-ColorText "   File: $installerPath" "White"
Write-ColorText "   Size: $installerSizeKB KB ($installerSizeMB MB)" "White"
Write-ColorText "   Type: Single-file with embedded binary" "White"
Write-ColorText "   Ready for distribution: Yes" "White"
Write-ColorText ""
Write-ColorText "🚀 To test the installer:" "Yellow"
Write-ColorText "   PowerShell -ExecutionPolicy Bypass -File $installerPath" "White"
Write-ColorText ""
Write-ColorText "💡 To see installer info:" "Yellow"  
Write-ColorText "   PowerShell -ExecutionPolicy Bypass -File $installerPath -ShowInfo" "White"
Write-ColorText ""
Write-ColorText "🎉 Your single-file Windows installer is ready!" "Green"
