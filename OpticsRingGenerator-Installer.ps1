# Optics Ring Generator - Single-File Windows Installer
# This PowerShell script can be distributed as a single file that installs everything

param(
    [switch]$Uninstall
)

$AppName = "Optics Ring Generator"
$Version = "0.1.0"
$InstallDir = "$env:ProgramFiles\$AppName"
$StartMenuDir = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$AppName"
$DesktopShortcut = "$env:USERPROFILE\Desktop\$AppName.lnk"

# Base64 encoded binary data would go here in a real implementation
# For now, we'll create a minimal implementation

function Write-Header {
    Clear-Host
    Write-Host "🔬 $AppName - Windows Installer" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host "Version: $Version" -ForegroundColor White
    Write-Host
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Application {
    Write-Header
    
    if (-not (Test-Administrator)) {
        Write-Host "❌ Administrator privileges required!" -ForegroundColor Red
        Write-Host "   Please right-click this script and select 'Run as administrator'" -ForegroundColor Yellow
        Write-Host
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "📥 Installing $AppName..." -ForegroundColor Green
    Write-Host
    
    # Create installation directory
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Write-Host "✅ Created installation directory: $InstallDir" -ForegroundColor Green
    }
    
    # In a real implementation, extract embedded binary here
    Write-Host "📦 Extracting application files..." -ForegroundColor Yellow
    
    # Create a placeholder binary message (in real version, this would be the actual binary)
    $launcherScript = @"
@echo off
title $AppName
echo 🔬 $AppName
echo ======================
echo.
echo ERROR: This is a demo installer.
echo Please build the actual Windows binary first with:
echo    cargo build --release --target x86_64-pc-windows-gnu
echo.
echo Then replace this script with the real installer.
echo.
pause
"@
    
    $launcherScript | Out-File -FilePath "$InstallDir\$AppName.bat" -Encoding ASCII
    
    # Create documentation
    $readme = @"
# $AppName

This application generates 3D printable precision optics support rings.

## Usage
- Launch from Desktop shortcut or Start Menu
- Use interactive UI to configure ring parameters
- Press F3 to browse for output directory
- Generate STL files for 3D printing

## Ring Types
- Convex (CX): Curves inward toward lens
- Concave (CC): Curves outward from lens  
- Three-Point (3P): Minimal contact points

For more information, visit the project repository.
"@
    
    $readme | Out-File -FilePath "$InstallDir\README.txt" -Encoding UTF8
    
    # Create Start Menu shortcuts
    if (-not (Test-Path $StartMenuDir)) {
        New-Item -ItemType Directory -Path $StartMenuDir -Force | Out-Null
    }
    
    $WshShell = New-Object -comObject WScript.Shell
    
    # Desktop shortcut
    $Shortcut = $WshShell.CreateShortcut($DesktopShortcut)
    $Shortcut.TargetPath = "$InstallDir\$AppName.bat"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "$AppName - Generate 3D printable optics support rings"
    $Shortcut.Save()
    Write-Host "✅ Created desktop shortcut" -ForegroundColor Green
    
    # Start Menu shortcut
    $Shortcut = $WshShell.CreateShortcut("$StartMenuDir\$AppName.lnk")
    $Shortcut.TargetPath = "$InstallDir\$AppName.bat"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "$AppName - Generate 3D printable optics support rings"
    $Shortcut.Save()
    
    # Uninstall shortcut
    $Shortcut = $WshShell.CreateShortcut("$StartMenuDir\Uninstall $AppName.lnk")
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -Uninstall"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "Uninstall $AppName"
    $Shortcut.Save()
    Write-Host "✅ Created Start Menu shortcuts" -ForegroundColor Green
    
    # Register in Programs and Features
    $uninstallPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$AppName"
    New-Item -Path $uninstallPath -Force | Out-Null
    Set-ItemProperty -Path $uninstallPath -Name "DisplayName" -Value $AppName
    Set-ItemProperty -Path $uninstallPath -Name "DisplayVersion" -Value $Version
    Set-ItemProperty -Path $uninstallPath -Name "Publisher" -Value "$AppName Team"
    Set-ItemProperty -Path $uninstallPath -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Uninstall"
    Set-ItemProperty -Path $uninstallPath -Name "InstallLocation" -Value $InstallDir
    Set-ItemProperty -Path $uninstallPath -Name "NoModify" -Value 1 -Type DWord
    Set-ItemProperty -Path $uninstallPath -Name "NoRepair" -Value 1 -Type DWord
    Write-Host "✅ Registered in Programs and Features" -ForegroundColor Green
    
    Write-Host
    Write-Host "🎉 Installation completed successfully!" -ForegroundColor Green
    Write-Host
    Write-Host "📍 Installed to: $InstallDir" -ForegroundColor White
    Write-Host "🖥️  Desktop shortcut created" -ForegroundColor White
    Write-Host "📂 Start Menu shortcuts created" -ForegroundColor White
    Write-Host
    Write-Host "🚀 You can now launch $AppName from:" -ForegroundColor Cyan
    Write-Host "   • Desktop shortcut" -ForegroundColor White
    Write-Host "   • Start Menu > $AppName" -ForegroundColor White
    Write-Host "   • Programs and Features (for uninstall)" -ForegroundColor White
    Write-Host
    
    $response = Read-Host "Launch $AppName now? (y/N)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Start-Process "$InstallDir\$AppName.bat"
    }
}

function Uninstall-Application {
    Write-Header
    
    if (-not (Test-Administrator)) {
        Write-Host "❌ Administrator privileges required for uninstall!" -ForegroundColor Red
        Write-Host "   Please run as administrator" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "🗑️ Uninstalling $AppName..." -ForegroundColor Yellow
    Write-Host
    
    $confirm = Read-Host "Are you sure you want to uninstall $AppName? (y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Uninstall cancelled." -ForegroundColor Yellow
        return
    }
    
    # Remove shortcuts
    if (Test-Path $DesktopShortcut) {
        Remove-Item $DesktopShortcut -Force
        Write-Host "✅ Removed desktop shortcut" -ForegroundColor Green
    }
    
    if (Test-Path $StartMenuDir) {
        Remove-Item $StartMenuDir -Recurse -Force
        Write-Host "✅ Removed Start Menu shortcuts" -ForegroundColor Green
    }
    
    # Remove from registry
    $uninstallPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$AppName"
    if (Test-Path $uninstallPath) {
        Remove-Item $uninstallPath -Recurse -Force
        Write-Host "✅ Removed from Programs and Features" -ForegroundColor Green
    }
    
    # Remove installation directory
    if (Test-Path $InstallDir) {
        Remove-Item $InstallDir -Recurse -Force
        Write-Host "✅ Removed installation directory" -ForegroundColor Green
    }
    
    Write-Host
    Write-Host "🎉 Uninstallation completed successfully!" -ForegroundColor Green
    Write-Host
    Read-Host "Press Enter to exit"
}

# Main execution
if ($Uninstall) {
    Uninstall-Application
} else {
    Install-Application
}
