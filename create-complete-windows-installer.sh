#!/bin/bash

echo "🚀 Creating Complete Windows Installer"
echo "======================================"
echo

# Install mingw-w64 if on macOS/Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
        echo "📥 Installing mingw-w64 cross-compiler..."
        if command -v brew &> /dev/null; then
            brew install mingw-w64
        else
            echo "❌ Please install Homebrew first, then run: brew install mingw-w64"
            exit 1
        fi
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
        echo "❌ Please install mingw-w64:"
        echo "   Ubuntu/Debian: sudo apt install mingw-w64"
        echo "   Fedora: sudo dnf install mingw64-gcc"
        echo "   Arch: sudo pacman -S mingw-w64-gcc"
        exit 1
    fi
fi

# Add Windows target
echo "🎯 Adding Windows compilation target..."
rustup target add x86_64-pc-windows-gnu

# Configure cross-compilation
export CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc
export CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++
export AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar
export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc

# Build for Windows
echo "🔨 Building for Windows..."
cargo build --release --target x86_64-pc-windows-gnu

if [ $? -ne 0 ]; then
    echo "❌ Windows build failed!"
    echo "Make sure mingw-w64 is properly installed and configured."
    exit 1
fi

echo "✅ Windows build successful!"

# Create installer directory
INSTALLER_DIR="windows-installer"
rm -rf "$INSTALLER_DIR"
mkdir -p "$INSTALLER_DIR"

# Copy Windows binary
cp target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe "$INSTALLER_DIR/"

# Encode binary as base64 for embedding in PowerShell
echo "📦 Encoding binary for self-contained installer..."
BINARY_BASE64=$(base64 -i target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe)

# Create self-contained PowerShell installer
cat > "$INSTALLER_DIR/OpticsRingGenerator-Setup.ps1" << EOF
# Optics Ring Generator - Self-Contained Windows Installer
# This script contains the application binary embedded as base64

param([switch]\$Uninstall)

\$AppName = "Optics Ring Generator"
\$Version = "0.1.0"
\$InstallDir = "\$env:ProgramFiles\\\$AppName"
\$StartMenuDir = "\$env:ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\\$AppName"
\$DesktopShortcut = "\$env:USERPROFILE\\Desktop\\\$AppName.lnk"

# Embedded binary data (base64 encoded)
\$BinaryData = @"
$BINARY_BASE64
"@

function Write-Header {
    Clear-Host
    Write-Host "🔬 \$AppName - Windows Installer" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host "Version: \$Version" -ForegroundColor White
    Write-Host
}

function Test-Administrator {
    \$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    \$principal = New-Object Security.Principal.WindowsPrincipal(\$currentUser)
    return \$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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
    
    Write-Host "📥 Installing \$AppName..." -ForegroundColor Green
    Write-Host
    
    # Create installation directory
    if (-not (Test-Path \$InstallDir)) {
        New-Item -ItemType Directory -Path \$InstallDir -Force | Out-Null
        Write-Host "✅ Created installation directory: \$InstallDir" -ForegroundColor Green
    }
    
    # Extract embedded binary
    Write-Host "📦 Extracting application binary..." -ForegroundColor Yellow
    try {
        \$binaryBytes = [System.Convert]::FromBase64String(\$BinaryData)
        [System.IO.File]::WriteAllBytes("\$InstallDir\\optics-ring-generator.exe", \$binaryBytes)
        Write-Host "✅ Extracted main application" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to extract binary: \$(\$_.Exception.Message)" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Create launcher batch file
    \$launcherScript = @"
@echo off
title \$AppName
cd /d "%~dp0"

echo 🔬 \$AppName
echo =======================
echo Launching interactive UI mode...
echo.

if not exist "optics-ring-generator.exe" (
    echo Error: Main application not found!
    echo Please reinstall the application.
    echo.
    pause
    exit /b 1
)

"optics-ring-generator.exe" --ui

if errorlevel 1 (
    echo.
    echo An error occurred during execution.
    echo Press any key to close this window...
    pause >nul
)
"@
    
    \$launcherScript | Out-File -FilePath "\$InstallDir\\\$AppName.bat" -Encoding ASCII
    Write-Host "✅ Created launcher script" -ForegroundColor Green
    
    # Create documentation
    \$readme = @"
# \$AppName

This application generates 3D printable precision optics support rings.

## Features
- Interactive terminal UI with directory browser
- Three ring types: Convex (CX), Concave (CC), Three-Point (3P)
- STL file generation for 3D printing
- Real-time validation and manufacturing guidance

## Usage
1. Launch from Desktop shortcut or Start Menu
2. Use Tab to navigate between fields
3. Press F3 in Output Directory field to browse folders
4. Select ring type and enter dimensions
5. Press Enter to generate STL file

## Ring Types
- **Convex (CX)**: Curves inward toward lens for gentle contact
- **Concave (CC)**: Curves outward from lens for secure cradling  
- **Three-Point (3P)**: Three contact points for minimal stress

## Keyboard Shortcuts
- Tab/Shift+Tab: Navigate fields
- F1 or h: Show help
- F3: Open directory browser (in Output Directory field)
- Enter: Select/Generate
- q or Esc: Quit

## Command Line Usage
You can also use the application from command line:
  optics-ring-generator.exe --ui
  optics-ring-generator.exe --ring-type cx --outer-diameter 50.0 --inner-diameter 25.0

For more information and source code, visit the project repository.
"@
    
    \$readme | Out-File -FilePath "\$InstallDir\\README.txt" -Encoding UTF8
    Write-Host "✅ Created documentation" -ForegroundColor Green
    
    # Create Start Menu shortcuts
    if (-not (Test-Path \$StartMenuDir)) {
        New-Item -ItemType Directory -Path \$StartMenuDir -Force | Out-Null
    }
    
    \$WshShell = New-Object -comObject WScript.Shell
    
    # Desktop shortcut
    \$Shortcut = \$WshShell.CreateShortcut(\$DesktopShortcut)
    \$Shortcut.TargetPath = "\$InstallDir\\\$AppName.bat"
    \$Shortcut.WorkingDirectory = \$InstallDir
    \$Shortcut.Description = "\$AppName - Generate 3D printable optics support rings"
    \$Shortcut.Save()
    Write-Host "✅ Created desktop shortcut" -ForegroundColor Green
    
    # Start Menu shortcut
    \$Shortcut = \$WshShell.CreateShortcut("\$StartMenuDir\\\$AppName.lnk")
    \$Shortcut.TargetPath = "\$InstallDir\\\$AppName.bat"
    \$Shortcut.WorkingDirectory = \$InstallDir
    \$Shortcut.Description = "\$AppName - Generate 3D printable optics support rings"
    \$Shortcut.Save()
    
    # Uninstall shortcut
    \$Shortcut = \$WshShell.CreateShortcut("\$StartMenuDir\\Uninstall \$AppName.lnk")
    \$Shortcut.TargetPath = "powershell.exe"
    \$Shortcut.Arguments = "-ExecutionPolicy Bypass -File \`"\$PSCommandPath\`" -Uninstall"
    \$Shortcut.WorkingDirectory = \$InstallDir
    \$Shortcut.Description = "Uninstall \$AppName"
    \$Shortcut.Save()
    Write-Host "✅ Created Start Menu shortcuts" -ForegroundColor Green
    
    # Register in Programs and Features
    \$uninstallPath = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\$AppName"
    New-Item -Path \$uninstallPath -Force | Out-Null
    Set-ItemProperty -Path \$uninstallPath -Name "DisplayName" -Value \$AppName
    Set-ItemProperty -Path \$uninstallPath -Name "DisplayVersion" -Value \$Version
    Set-ItemProperty -Path \$uninstallPath -Name "Publisher" -Value "\$AppName Team"
    Set-ItemProperty -Path \$uninstallPath -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File \`"\$PSCommandPath\`" -Uninstall"
    Set-ItemProperty -Path \$uninstallPath -Name "InstallLocation" -Value \$InstallDir
    Set-ItemProperty -Path \$uninstallPath -Name "NoModify" -Value 1 -Type DWord
    Set-ItemProperty -Path \$uninstallPath -Name "NoRepair" -Value 1 -Type DWord
    Write-Host "✅ Registered in Programs and Features" -ForegroundColor Green
    
    Write-Host
    Write-Host "🎉 Installation completed successfully!" -ForegroundColor Green
    Write-Host
    Write-Host "📍 Installed to: \$InstallDir" -ForegroundColor White
    Write-Host "🖥️  Desktop shortcut created" -ForegroundColor White
    Write-Host "📂 Start Menu shortcuts created" -ForegroundColor White
    Write-Host
    Write-Host "🚀 You can now launch \$AppName from:" -ForegroundColor Cyan
    Write-Host "   • Desktop shortcut" -ForegroundColor White
    Write-Host "   • Start Menu > \$AppName" -ForegroundColor White
    Write-Host "   • Programs and Features (for uninstall)" -ForegroundColor White
    Write-Host
    
    \$response = Read-Host "Launch \$AppName now? (y/N)"
    if (\$response -eq 'y' -or \$response -eq 'Y') {
        Start-Process "\$InstallDir\\\$AppName.bat"
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
    
    Write-Host "🗑️ Uninstalling \$AppName..." -ForegroundColor Yellow
    Write-Host
    
    \$confirm = Read-Host "Are you sure you want to uninstall \$AppName? (y/N)"
    if (\$confirm -ne 'y' -and \$confirm -ne 'Y') {
        Write-Host "Uninstall cancelled." -ForegroundColor Yellow
        return
    }
    
    # Remove shortcuts
    if (Test-Path \$DesktopShortcut) {
        Remove-Item \$DesktopShortcut -Force
        Write-Host "✅ Removed desktop shortcut" -ForegroundColor Green
    }
    
    if (Test-Path \$StartMenuDir) {
        Remove-Item \$StartMenuDir -Recurse -Force
        Write-Host "✅ Removed Start Menu shortcuts" -ForegroundColor Green
    }
    
    # Remove from registry
    \$uninstallPath = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\$AppName"
    if (Test-Path \$uninstallPath) {
        Remove-Item \$uninstallPath -Recurse -Force
        Write-Host "✅ Removed from Programs and Features" -ForegroundColor Green
    }
    
    # Remove installation directory
    if (Test-Path \$InstallDir) {
        Remove-Item \$InstallDir -Recurse -Force
        Write-Host "✅ Removed installation directory" -ForegroundColor Green
    }
    
    Write-Host
    Write-Host "🎉 Uninstallation completed successfully!" -ForegroundColor Green
    Write-Host
    Read-Host "Press Enter to exit"
}

# Main execution
if (\$Uninstall) {
    Uninstall-Application
} else {
    Install-Application
}
EOF

# Copy the binary separately as well
cp target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe "$INSTALLER_DIR/"

# Create simple batch installer as backup
cat > "$INSTALLER_DIR/install.bat" << 'EOF'
@echo off
title Optics Ring Generator - Installer
echo 🔬 Optics Ring Generator - Windows Installer
echo ==========================================
echo.

set "INSTALL_DIR=%ProgramFiles%\Optics Ring Generator"

echo Installing to: %INSTALL_DIR%
echo.

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo 📁 Copying files...
copy "optics-ring-generator.exe" "%INSTALL_DIR%\" >nul
if errorlevel 1 (
    echo ❌ Failed to copy main binary
    pause
    exit /b 1
)

echo @echo off > "%INSTALL_DIR%\Optics Ring Generator.bat"
echo title Optics Ring Generator >> "%INSTALL_DIR%\Optics Ring Generator.bat"
echo cd /d "%%~dp0" >> "%INSTALL_DIR%\Optics Ring Generator.bat"
echo "optics-ring-generator.exe" --ui >> "%INSTALL_DIR%\Optics Ring Generator.bat"

echo 🔗 Creating shortcuts...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Optics Ring Generator.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\Optics Ring Generator.bat'; $Shortcut.Save()"

echo.
echo ✅ Installation complete!
echo 🖥️  Desktop shortcut created
echo 📍 Installed to: %INSTALL_DIR%
echo.
pause
EOF

# Create README for Windows users
cat > "$INSTALLER_DIR/README-WINDOWS.txt" << EOF
Optics Ring Generator - Windows Installation
===========================================

INSTALLATION OPTIONS:

1. RECOMMENDED: Self-Contained PowerShell Installer
   - Right-click "OpticsRingGenerator-Setup.ps1"
   - Select "Run with PowerShell" 
   - Choose "Run anyway" if Windows Defender appears
   - Follow installation prompts

2. ALTERNATIVE: Simple Batch Installer
   - Right-click "install.bat"
   - Select "Run as administrator"
   - Follow prompts

FEATURES:
• Interactive terminal UI with directory browser
• Three ring types: Convex (CX), Concave (CC), Three-Point (3P)  
• STL file generation for 3D printing
• Real-time validation and manufacturing guidance

USAGE:
• Launch from Desktop shortcut or Start Menu
• Press F3 in Output Directory field to browse folders
• Press F1 or 'h' for help
• Tab to navigate between fields
• Press 'q' or Esc to quit

The PowerShell installer includes:
• Automatic file extraction
• Desktop and Start Menu shortcuts
• Programs and Features registration
• Built-in uninstaller

File Size: $(du -h target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe | cut -f1)
Build Date: $(date)
EOF

echo
echo "✅ Windows installer package created successfully!"
echo
echo "📦 Created files in $INSTALLER_DIR/:"
echo "   • OpticsRingGenerator-Setup.ps1 (Self-contained installer with embedded binary)"
echo "   • optics-ring-generator.exe (Windows binary)"
echo "   • install.bat (Simple batch installer)"
echo "   • README-WINDOWS.txt (Installation instructions)"
echo
echo "📊 Binary size: $(du -h target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe | cut -f1)"
echo "📊 Installer size: $(du -h "$INSTALLER_DIR/OpticsRingGenerator-Setup.ps1" | cut -f1)"
echo
echo "🚀 Distribution instructions:"
echo "   1. Send the OpticsRingGenerator-Setup.ps1 file to Windows users"
echo "   2. Users right-click and 'Run with PowerShell'"
echo "   3. Follow installation prompts"
echo "   4. Application installs with all dependencies and shortcuts"
echo
echo "🎯 The installer provides:"
echo "   • Single-file distribution (no dependencies)"
echo "   • Automatic binary extraction"
echo "   • Desktop and Start Menu shortcuts"
echo "   • Programs and Features integration"
echo "   • Built-in uninstaller"
echo "   • Administrator privilege handling"
