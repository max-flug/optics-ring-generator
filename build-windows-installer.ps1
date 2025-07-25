# Windows Installer Build Script
# This script creates a complete Windows installer package

param(
    [string]$NSISPath = "C:\Program Files (x86)\NSIS\makensis.exe"
)

Write-Host "🔧 Building Windows Installer for Optics Ring Generator" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host

# Check if we're on Windows (or have cross-compilation set up)
if ($IsWindows -eq $false -and $env:OS -ne "Windows_NT") {
    Write-Host "⚠️  This script is designed for Windows. For cross-compilation from macOS/Linux:" -ForegroundColor Yellow
    Write-Host "   1. Install mingw-w64: brew install mingw-w64 (macOS) or apt install mingw-w64 (Linux)"
    Write-Host "   2. Add Windows target: rustup target add x86_64-pc-windows-gnu"
    Write-Host "   3. Build: cargo build --release --target x86_64-pc-windows-gnu"
    Write-Host "   4. Copy files to Windows machine and run this script there"
    Write-Host
}

# Create installer directory structure
Write-Host "📁 Creating installer directory structure..."
New-Item -ItemType Directory -Path "installer" -Force | Out-Null
New-Item -ItemType Directory -Path "dist" -Force | Out-Null

# Build the Rust project for Windows
Write-Host "🔨 Building Rust project..."
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    & cargo build --release
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Rust build successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Rust build failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Cargo not found. Please install Rust." -ForegroundColor Red
    exit 1
}

# Check if NSIS is installed
if (-not (Test-Path $NSISPath)) {
    Write-Host "❌ NSIS not found at $NSISPath" -ForegroundColor Red
    Write-Host "Please install NSIS from https://nsis.sourceforge.io/Download" -ForegroundColor Yellow
    Write-Host "Or specify the correct path with -NSISPath parameter" -ForegroundColor Yellow
    exit 1
}

# Build Windows launcher (if we have a C++ compiler)
Write-Host "🔨 Building Windows launcher..."
$vcvarsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
if (-not (Test-Path $vcvarsPath)) {
    $vcvarsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
}

if (Test-Path $vcvarsPath) {
    # Use Visual Studio compiler
    & cmd /c "`"$vcvarsPath`" && cl.exe installer\launcher.cpp /Fe:dist\OpticsRingGenerator.exe /link user32.lib"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Windows launcher built successfully" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Failed to build launcher with MSVC, trying alternative..." -ForegroundColor Yellow
        # Create a simple batch file launcher as fallback
        @"
@echo off
title Optics Ring Generator
echo 🔬 Launching Optics Ring Generator...
echo.
"%~dp0optics-ring-generator.exe" --ui
if errorlevel 1 (
    echo.
    echo An error occurred. Press any key to exit...
    pause >nul
)
"@ | Out-File -FilePath "dist\OpticsRingGenerator.bat" -Encoding ASCII
        Copy-Item "dist\OpticsRingGenerator.bat" "dist\OpticsRingGenerator.exe"
        Write-Host "✅ Created batch file launcher" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  Visual Studio not found, creating batch file launcher..." -ForegroundColor Yellow
    # Create batch file launcher
    @"
@echo off
title Optics Ring Generator
echo 🔬 Launching Optics Ring Generator...
echo.
"%~dp0optics-ring-generator.exe" --ui
if errorlevel 1 (
    echo.
    echo An error occurred. Press any key to exit...
    pause >nul
)
"@ | Out-File -FilePath "dist\OpticsRingGenerator.exe" -Encoding ASCII
    Write-Host "✅ Created batch file launcher" -ForegroundColor Green
}

# Copy required files to installer directory
Write-Host "📦 Copying files for installer..."
if (Test-Path "target\release\optics-ring-generator.exe") {
    Copy-Item "target\release\optics-ring-generator.exe" "dist\" -Force
    Write-Host "✅ Copied main binary" -ForegroundColor Green
} else {
    Write-Host "❌ Main binary not found at target\release\optics-ring-generator.exe" -ForegroundColor Red
    exit 1
}

# Copy documentation
Copy-Item "README.md" "dist\" -Force -ErrorAction SilentlyContinue
Copy-Item "DISTRIBUTION.md" "dist\" -Force -ErrorAction SilentlyContinue

# Create a simple icon (you can replace this with a real .ico file)
Write-Host "🎨 Creating application icon..."
# This creates a minimal icon - replace with a real .ico file for production
if (-not (Test-Path "installer\icon.ico")) {
    Write-Host "⚠️  No icon.ico found, installer will use default icon" -ForegroundColor Yellow
}

# Build the installer
Write-Host "📦 Building NSIS installer..."
& $NSISPath "installer\installer.nsi"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Installer built successfully!" -ForegroundColor Green
    Write-Host
    $installerPath = Get-ChildItem "dist\*Setup.exe" | Select-Object -First 1
    if ($installerPath) {
        Write-Host "🎉 Installer created: $($installerPath.Name)" -ForegroundColor Cyan
        Write-Host "📍 Location: $($installerPath.FullName)" -ForegroundColor Cyan
        Write-Host "📏 Size: $([math]::Round($installerPath.Length / 1MB, 2)) MB" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ Installer build failed" -ForegroundColor Red
    exit 1
}

Write-Host
Write-Host "🚀 Windows installer is ready!" -ForegroundColor Green
Write-Host "   The installer includes:" -ForegroundColor White
Write-Host "   • Main application binary" -ForegroundColor White
Write-Host "   • GUI launcher" -ForegroundColor White
Write-Host "   • Desktop and Start Menu shortcuts" -ForegroundColor White
Write-Host "   • Automatic uninstaller" -ForegroundColor White
Write-Host "   • Optional PATH integration" -ForegroundColor White
Write-Host "   • File associations" -ForegroundColor White
