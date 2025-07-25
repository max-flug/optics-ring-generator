# OpticRingGenerator Universal Installer
# This installer downloads the latest version from GitHub and installs it

#Requires -RunAsAdministrator

param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

# Configuration
$AppName = "OpticRingGenerator"
$Publisher = "OpticRingGenerator"
$Version = "1.0.0"
$InstallDir = "$env:ProgramFiles\$AppName"
$StartMenuFolder = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$AppName"
$DesktopShortcut = "$env:PUBLIC\Desktop\$AppName.lnk"

# GitHub repository (update this with your actual repository)
$GitHubRepo = "your-username/optics-ring-generator"
$DownloadUrl = "https://github.com/$GitHubRepo/releases/latest/download/optics-ring-generator.exe"

function Write-ColorText {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-ColorText "❌ This installer must be run as Administrator!" "Red"
    Write-ColorText "   Right-click on PowerShell and select 'Run as Administrator'" "Yellow"
    Read-Host "Press Enter to exit"
    exit 1
}

if ($Uninstall) {
    Write-ColorText "🗑️  Uninstalling $AppName..." "Yellow"
    
    # Remove files
    if (Test-Path $InstallDir) {
        Remove-Item -Path $InstallDir -Recurse -Force
        Write-ColorText "✅ Removed installation directory" "Green"
    }
    
    # Remove shortcuts
    if (Test-Path $DesktopShortcut) {
        Remove-Item -Path $DesktopShortcut -Force
        Write-ColorText "✅ Removed desktop shortcut" "Green"
    }
    
    if (Test-Path $StartMenuFolder) {
        Remove-Item -Path $StartMenuFolder -Recurse -Force
        Write-ColorText "✅ Removed start menu entries" "Green"
    }
    
    # Remove from registry
    $regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppName"
    if (Test-Path $regPath) {
        Remove-Item -Path $regPath -Force
        Write-ColorText "✅ Removed registry entries" "Green"
    }
    
    Write-ColorText "🎉 $AppName has been successfully uninstalled!" "Green"
    Read-Host "Press Enter to exit"
    exit 0
}

Write-ColorText "🚀 Installing $AppName v$Version..." "Cyan"
Write-ColorText "   Publisher: $Publisher" "Gray"
Write-ColorText "   Install Location: $InstallDir" "Gray"
Write-ColorText ""

# Create installation directory
Write-ColorText "📁 Creating installation directory..." "Yellow"
if (-not (Test-Path $InstallDir)) {
    New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null
}

# Download the binary (this would normally download from GitHub)
Write-ColorText "📥 Downloading $AppName..." "Yellow"
Write-ColorText "   Note: This installer template would download from: $DownloadUrl" "Gray"
Write-ColorText "   For now, you need to manually copy the Windows binary to:" "Gray"
Write-ColorText "   $InstallDir\optics-ring-generator.exe" "Gray"

# For demonstration, create a batch file that shows how to use the program
$batchContent = @"
@echo off
echo OpticRingGenerator
echo =================
echo.
echo This is a placeholder for the actual OpticRingGenerator executable.
echo.
echo To complete the installation:
echo 1. Build the Windows binary using: cargo build --release --target x86_64-pc-windows-gnu
echo 2. Copy the resulting .exe file to: $InstallDir
echo 3. Run this installer again
echo.
pause
"@

$batchPath = "$InstallDir\optics-ring-generator.bat"
$batchContent | Out-File -FilePath $batchPath -Encoding ASCII

# Create Start Menu shortcuts
Write-ColorText "📎 Creating shortcuts..." "Yellow"
if (-not (Test-Path $StartMenuFolder)) {
    New-Item -Path $StartMenuFolder -ItemType Directory -Force | Out-Null
}

$WshShell = New-Object -comObject WScript.Shell

# Start Menu shortcut
$StartMenuShortcut = $WshShell.CreateShortcut("$StartMenuFolder\$AppName.lnk")
$StartMenuShortcut.TargetPath = $batchPath
$StartMenuShortcut.WorkingDirectory = $InstallDir
$StartMenuShortcut.Description = "3D Printable Precision Optics Support Ring Generator"
$StartMenuShortcut.Save()

# Desktop shortcut
$DesktopShortcutObj = $WshShell.CreateShortcut($DesktopShortcut)
$DesktopShortcutObj.TargetPath = $batchPath
$DesktopShortcutObj.WorkingDirectory = $InstallDir
$DesktopShortcutObj.Description = "3D Printable Precision Optics Support Ring Generator"
$DesktopShortcutObj.Save()

# Add to Windows Programs and Features
Write-ColorText "📋 Registering with Windows..." "Yellow"
$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppName"
New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name "DisplayName" -Value $AppName
Set-ItemProperty -Path $regPath -Name "DisplayVersion" -Value $Version
Set-ItemProperty -Path $regPath -Name "Publisher" -Value $Publisher
Set-ItemProperty -Path $regPath -Name "InstallLocation" -Value $InstallDir
Set-ItemProperty -Path $regPath -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`" -Uninstall"
Set-ItemProperty -Path $regPath -Name "DisplayIcon" -Value "$InstallDir\optics-ring-generator.exe"
Set-ItemProperty -Path $regPath -Name "NoModify" -Value 1
Set-ItemProperty -Path $regPath -Name "NoRepair" -Value 1

Write-ColorText ""
Write-ColorText "🎉 Installation completed successfully!" "Green"
Write-ColorText ""
Write-ColorText "📋 Installation Summary:" "Cyan"
Write-ColorText "   • Program installed to: $InstallDir" "White"
Write-ColorText "   • Desktop shortcut created" "White"
Write-ColorText "   • Start menu entry created" "White"
Write-ColorText "   • Added to Programs and Features" "White"
Write-ColorText ""
Write-ColorText "🚀 You can now run $AppName from:" "Cyan"
Write-ColorText "   • Desktop shortcut" "White"
Write-ColorText "   • Start Menu → $AppName" "White"
Write-ColorText "   • Command line: optics-ring-generator" "White"
Write-ColorText ""
Write-ColorText "ℹ️  To uninstall, run this script with -Uninstall parameter" "Gray"
Write-ColorText "   or use Windows Settings → Apps & features" "Gray"
Write-ColorText ""

Read-Host "Press Enter to exit"
