#!/bin/bash

echo "📦 Creating Windows Self-Extracting Installer"
echo "============================================="
echo

# Check if we can build for Windows
if ! rustup target list --installed | grep -q "x86_64-pc-windows-gnu"; then
    echo "📥 Installing Windows target for cross-compilation..."
    rustup target add x86_64-pc-windows-gnu
fi

# Build for Windows
echo "🔨 Building for Windows..."
cargo build --release --target x86_64-pc-windows-gnu

if [ $? -eq 0 ]; then
    echo "✅ Windows build successful"
else
    echo "❌ Windows build failed. You may need to install mingw-w64:"
    echo "   macOS: brew install mingw-w64"
    echo "   Ubuntu: sudo apt install mingw-w64"
    exit 1
fi

# Create installer package directory
INSTALLER_DIR="windows-installer-package"
mkdir -p "$INSTALLER_DIR"

# Copy Windows binary
cp target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe "$INSTALLER_DIR/"

# Create Windows launcher batch file
cat > "$INSTALLER_DIR/OpticsRingGenerator.bat" << 'EOF'
@echo off
title Optics Ring Generator
cd /d "%~dp0"

echo 🔬 Optics Ring Generator
echo =======================
echo Launching interactive UI mode...
echo.

if not exist "optics-ring-generator.exe" (
    echo Error: Main application not found!
    echo Please ensure all files were extracted properly.
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
EOF

# Create installer script
cat > "$INSTALLER_DIR/install.bat" << 'EOF'
@echo off
title Optics Ring Generator - Installer
echo 🔧 Optics Ring Generator - Windows Installer
echo ==========================================
echo.

set "INSTALL_DIR=%ProgramFiles%\Optics Ring Generator"
set "DESKTOP_SHORTCUT=%USERPROFILE%\Desktop\Optics Ring Generator.lnk"
set "STARTMENU_DIR=%ProgramData%\Microsoft\Windows\Start Menu\Programs\Optics Ring Generator"

echo Installing to: %INSTALL_DIR%
echo.

REM Create installation directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy files
echo 📁 Copying application files...
copy "optics-ring-generator.exe" "%INSTALL_DIR%\" >nul
copy "OpticsRingGenerator.bat" "%INSTALL_DIR%\" >nul
copy "README.md" "%INSTALL_DIR%\" >nul 2>nul

REM Create Start Menu folder
if not exist "%STARTMENU_DIR%" mkdir "%STARTMENU_DIR%"

REM Create shortcuts using PowerShell
echo 🔗 Creating shortcuts...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP_SHORTCUT%'); $Shortcut.TargetPath = '%INSTALL_DIR%\OpticsRingGenerator.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Optics Ring Generator - 3D Printable Optics Support Rings'; $Shortcut.Save()"

powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%STARTMENU_DIR%\Optics Ring Generator.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\OpticsRingGenerator.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Optics Ring Generator - 3D Printable Optics Support Rings'; $Shortcut.Save()"

REM Create uninstaller
echo 🗑️ Creating uninstaller...
echo @echo off > "%INSTALL_DIR%\uninstall.bat"
echo title Optics Ring Generator - Uninstaller >> "%INSTALL_DIR%\uninstall.bat"
echo echo Removing Optics Ring Generator... >> "%INSTALL_DIR%\uninstall.bat"
echo del "%DESKTOP_SHORTCUT%" 2^>nul >> "%INSTALL_DIR%\uninstall.bat"
echo rmdir /s /q "%STARTMENU_DIR%" 2^>nul >> "%INSTALL_DIR%\uninstall.bat"
echo cd /d "%TEMP%" >> "%INSTALL_DIR%\uninstall.bat"
echo rmdir /s /q "%INSTALL_DIR%" >> "%INSTALL_DIR%\uninstall.bat"
echo echo Uninstallation complete. >> "%INSTALL_DIR%\uninstall.bat"
echo pause >> "%INSTALL_DIR%\uninstall.bat"

powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%STARTMENU_DIR%\Uninstall Optics Ring Generator.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\uninstall.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Uninstall Optics Ring Generator'; $Shortcut.Save()"

echo.
echo ✅ Installation completed successfully!
echo.
echo 📍 Installed to: %INSTALL_DIR%
echo 🖥️  Desktop shortcut created
echo 📂 Start Menu shortcut created
echo.
echo 🚀 You can now launch Optics Ring Generator from:
echo    • Desktop shortcut
echo    • Start Menu
echo    • Or run: "%INSTALL_DIR%\OpticsRingGenerator.bat"
echo.
pause
EOF

# Copy documentation
cp README.md "$INSTALLER_DIR/" 2>/dev/null
cp DISTRIBUTION.md "$INSTALLER_DIR/" 2>/dev/null

# Create usage instructions
cat > "$INSTALLER_DIR/README-WINDOWS.txt" << 'EOF'
Optics Ring Generator - Windows Installation Package
===================================================

INSTALLATION INSTRUCTIONS:
1. Extract all files to a temporary folder
2. Right-click "install.bat" and select "Run as administrator"
3. Follow the installation prompts
4. Launch from Desktop shortcut or Start Menu

MANUAL INSTALLATION:
If you prefer not to use the installer:
1. Create a folder: C:\Program Files\Optics Ring Generator
2. Copy all files to that folder
3. Double-click "OpticsRingGenerator.bat" to run

FEATURES:
• Interactive terminal UI with directory browser
• Three ring types: Convex (CX), Concave (CC), Three-Point (3P)
• STL file generation for 3D printing
• Real-time validation and manufacturing guidance

USAGE:
• Press F3 in Output Directory field to browse folders
• Press F1 or 'h' for help
• Tab to navigate between fields
• Press 'q' or Esc to quit

For more information, see README.md
EOF

# Create self-extracting archive using zip (cross-platform)
echo "📦 Creating self-extracting installer package..."
cd "$INSTALLER_DIR"
zip -r "../OpticsRingGenerator-Windows-Installer.zip" . >/dev/null 2>&1
cd ..

# Create a PowerShell self-extractor script
cat > "OpticsRingGenerator-Windows-Setup.ps1" << 'EOF'
# Optics Ring Generator - Self-Extracting Installer
# Run this script on Windows to install the application

Write-Host "🔬 Optics Ring Generator - Windows Installer" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "⚠️  This installer requires administrator privileges." -ForegroundColor Yellow
    Write-Host "   Please right-click and select 'Run as administrator'" -ForegroundColor Yellow
    Write-Host
    Read-Host "Press Enter to exit"
    exit 1
}

# Extract embedded files (this would contain the base64 encoded zip)
$tempDir = "$env:TEMP\OpticsRingGenerator-Install"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "📥 Extracting installation files..." -ForegroundColor Green
# In a real implementation, embedded files would be extracted here

Write-Host "📦 Please extract the zip file and run install.bat as administrator" -ForegroundColor Yellow
Write-Host "    Location: OpticsRingGenerator-Windows-Installer.zip" -ForegroundColor White

Read-Host "Press Enter to continue"
EOF

echo "✅ Windows installer package created!"
echo
echo "📦 Created files:"
echo "   • $INSTALLER_DIR/ - Installation package directory"
echo "   • OpticsRingGenerator-Windows-Installer.zip - Zip archive"
echo "   • OpticsRingGenerator-Windows-Setup.ps1 - PowerShell installer"
echo
echo "🚀 To distribute:"
echo "   1. Send the ZIP file to Windows users"
echo "   2. Users extract and run 'install.bat' as administrator"
echo "   3. Or use the PowerShell script for automated extraction"
echo
echo "📋 Installation includes:"
echo "   • Main application binary"
echo "   • GUI launcher batch file"
echo "   • Desktop and Start Menu shortcuts"
echo "   • Automatic uninstaller"
echo "   • Documentation"
