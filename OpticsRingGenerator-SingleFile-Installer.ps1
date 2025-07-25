# Optics Ring Generator - Windows Installer Template
# Replace [BINARY_DATA_HERE] with base64 encoded binary

param([switch]$Uninstall)

$AppName = "Optics Ring Generator"
$Version = "0.1.0"
$InstallDir = "$env:ProgramFiles\$AppName"
$StartMenuDir = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$AppName"
$DesktopShortcut = "$env:USERPROFILE\Desktop\$AppName.lnk"

function Write-Header {
    Clear-Host
    Write-Host "🔬 $AppName - Windows Installer" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host "Version: $Version" -ForegroundColor White
    Write-Host "Single-file installer with embedded binary" -ForegroundColor Gray
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
        Write-Host "   Or 'Run with PowerShell' and select 'Run anyway' when prompted" -ForegroundColor Yellow
        Write-Host
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "📥 Installing $AppName..." -ForegroundColor Green
    Write-Host "   This will install the application with all dependencies" -ForegroundColor Gray
    Write-Host
    
    # Create installation directory
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Write-Host "✅ Created installation directory" -ForegroundColor Green
    }
    
    # Check if binary data is embedded
    $BinaryData = "[BINARY_DATA_HERE]"
    
    if ($BinaryData -eq "[BINARY_DATA_HERE]") {
        Write-Host "⚠️  This is a template installer." -ForegroundColor Yellow
        Write-Host "   To create a working installer:" -ForegroundColor Yellow
        Write-Host "   1. Build Windows binary: cargo build --release --target x86_64-pc-windows-gnu" -ForegroundColor White
        Write-Host "   2. Encode binary: base64 -i target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe" -ForegroundColor White
        Write-Host "   3. Replace [BINARY_DATA_HERE] with the base64 output" -ForegroundColor White
        Write-Host
        
        # Create a demo launcher for now
        $demoScript = @"
@echo off
title $AppName
echo 🔬 $AppName
echo =======================
echo.
echo This is a demonstration installer.
echo To create a working version:
echo.
echo 1. Build the Windows binary
echo 2. Embed it in the PowerShell installer
echo 3. Distribute the single PowerShell file
echo.
echo Features when properly installed:
echo • Interactive terminal UI
echo • Directory browser (F3 key)
echo • Three ring types (CX, CC, 3P)
echo • STL file generation
echo • Real-time validation
echo.
pause
"@
        $demoScript | Out-File -FilePath "$InstallDir\$AppName.bat" -Encoding ASCII
        Write-Host "✅ Created demo launcher" -ForegroundColor Green
    } else {
        # Extract embedded binary
        Write-Host "📦 Extracting application binary..." -ForegroundColor Yellow
        try {
            $binaryBytes = [System.Convert]::FromBase64String($BinaryData)
            [System.IO.File]::WriteAllBytes("$InstallDir\optics-ring-generator.exe", $binaryBytes)
            Write-Host "✅ Extracted main application ($([math]::Round($binaryBytes.Length / 1MB, 2)) MB)" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to extract binary: $($_.Exception.Message)" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        
        # Create launcher batch file
        $launcherScript = @"
@echo off
title $AppName
cd /d "%~dp0"

echo 🔬 $AppName
echo =======================
echo Launching interactive UI mode...
echo Use F3 to browse directories, F1 for help
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
    echo An error occurred. Check that your system supports the application.
    echo Press any key to close...
    pause >nul
)
"@
        $launcherScript | Out-File -FilePath "$InstallDir\$AppName.bat" -Encoding ASCII
        Write-Host "✅ Created application launcher" -ForegroundColor Green
    }
    
    # Create comprehensive documentation
    $readme = @"
# $AppName v$Version

Generate 3D printable precision optics support rings with an interactive terminal interface.

## Quick Start
1. Launch from Desktop shortcut or Start Menu
2. Use Tab to navigate between input fields
3. Press F3 in Output Directory field to browse folders
4. Select ring type and enter dimensions
5. Press Enter to generate STL file

## Features
• **Interactive Terminal UI**: Modern text-based interface with directory browser
• **Three Ring Types**: Convex (CX), Concave (CC), Three-Point (3P)
• **Directory Browser**: Press F3 to visually select output folders
• **Real-time Validation**: Automatic checks for 3D printing compatibility
• **STL Generation**: Ready-to-print files with proper naming
• **Manufacturing Guidance**: Material recommendations and print settings

## Ring Types

### Convex (CX)
- Curves inward toward the lens
- Provides gentle, distributed contact
- Ideal for delicate optical surfaces
- No support structures required for printing

### Concave (CC)  
- Curves outward from the lens
- Creates a secure cradle for the lens
- Good for lenses that need stable positioning
- May require light support structures

### Three-Point (3P)
- Three contact points at 120-degree intervals
- Minimal contact with the lens surface
- Maximum stability with minimal stress
- Ideal for precision applications

## User Interface

### Navigation
- **Tab/Shift+Tab**: Move between fields
- **Arrow Keys**: Navigate lists and directory browser
- **Enter**: Select options or generate STL file
- **F1 or h**: Toggle help panel
- **F3**: Open directory browser (when in Output Directory field)
- **q or Esc**: Quit application

### Directory Browser
- Navigate your file system visually
- Folders marked with 📁, files with 📄
- Access parent directories with ".." entries
- Toggle hidden files with 'h' key
- Press Space to select current directory
- Press Esc to cancel

## Command Line Usage
You can also use the application from Command Prompt:

    # Interactive UI mode
    optics-ring-generator.exe --ui
    
    # Direct generation
    optics-ring-generator.exe --ring-type cx --outer-diameter 50.0 --inner-diameter 25.0
    
    # With output directory
    optics-ring-generator.exe --ring-type cc --outer-diameter 40.0 --inner-diameter 20.0 --output-dir "C:\My Rings"
    
    # Show help
    optics-ring-generator.exe --help

## File Naming
Generated STL files follow the pattern: {TYPE}-{INNER_DIAMETER}.stl

Examples:
- CX-25.0.stl (Convex ring, 25mm inner diameter)
- CC-20.0.stl (Concave ring, 20mm inner diameter)  
- 3P-15.0.stl (Three-point ring, 15mm inner diameter)

## 3D Printing Recommendations

### General Settings
- **Layer Height**: 0.15-0.2mm for smooth curves
- **Material**: PLA or PETG for optical applications
- **Infill**: 100% for maximum stability
- **Orientation**: Place flat on build plate

### Quality Requirements
- Minimum wall thickness: 1.0mm (automatically validated)
- Surface finish: Consider post-processing for optical contact
- Dimensional accuracy: ±0.1mm recommended

## Troubleshooting

### Application Won't Start
- Ensure Windows 10/11 with latest updates
- Try running as administrator
- Check antivirus hasn't quarantined the file

### Generation Errors
- Verify outer diameter > inner diameter
- Check output directory is writable
- Ensure sufficient disk space for STL file

### UI Issues
- Maximize terminal window for best experience
- Use Windows Terminal or PowerShell for best compatibility
- Press F1 for help within the application

## Support
For issues, feature requests, or source code, visit the project repository.

Installation Date: $(Get-Date -Format "yyyy-MM-dd HH:mm")
"@
    
    $readme | Out-File -FilePath "$InstallDir\README.txt" -Encoding UTF8
    Write-Host "✅ Created documentation" -ForegroundColor Green
    
    # Create Start Menu folder and shortcuts
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
    
    # Start Menu shortcuts
    $Shortcut = $WshShell.CreateShortcut("$StartMenuDir\$AppName.lnk")
    $Shortcut.TargetPath = "$InstallDir\$AppName.bat"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "$AppName - Generate 3D printable optics support rings"
    $Shortcut.Save()
    
    $Shortcut = $WshShell.CreateShortcut("$StartMenuDir\$AppName Documentation.lnk")
    $Shortcut.TargetPath = "$InstallDir\README.txt"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "$AppName Documentation"
    $Shortcut.Save()
    
    $Shortcut = $WshShell.CreateShortcut("$StartMenuDir\Uninstall $AppName.lnk")
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -Uninstall"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "Uninstall $AppName"
    $Shortcut.Save()
    Write-Host "✅ Created Start Menu shortcuts" -ForegroundColor Green
    
    # Register in Programs and Features (Add/Remove Programs)
    $uninstallPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$AppName"
    try {
        New-Item -Path $uninstallPath -Force | Out-Null
        Set-ItemProperty -Path $uninstallPath -Name "DisplayName" -Value $AppName
        Set-ItemProperty -Path $uninstallPath -Name "DisplayVersion" -Value $Version
        Set-ItemProperty -Path $uninstallPath -Name "Publisher" -Value "$AppName Team"
        Set-ItemProperty -Path $uninstallPath -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Uninstall"
        Set-ItemProperty -Path $uninstallPath -Name "InstallLocation" -Value $InstallDir
        Set-ItemProperty -Path $uninstallPath -Name "DisplayIcon" -Value "$InstallDir\$AppName.bat"
        Set-ItemProperty -Path $uninstallPath -Name "NoModify" -Value 1 -Type DWord
        Set-ItemProperty -Path $uninstallPath -Name "NoRepair" -Value 1 -Type DWord
        Set-ItemProperty -Path $uninstallPath -Name "InstallDate" -Value (Get-Date -Format "yyyyMMdd")
        Write-Host "✅ Registered in Programs and Features" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Could not register in Programs and Features (non-critical)" -ForegroundColor Yellow
    }
    
    Write-Host
    Write-Host "🎉 Installation completed successfully!" -ForegroundColor Green
    Write-Host
    Write-Host "📍 Installed to: $InstallDir" -ForegroundColor White
    Write-Host "🖥️  Desktop shortcut: $AppName" -ForegroundColor White
    Write-Host "📂 Start Menu: $AppName" -ForegroundColor White
    Write-Host "📖 Documentation: README.txt in install folder" -ForegroundColor White
    Write-Host "🗑️  Uninstall: Programs and Features or Start Menu" -ForegroundColor White
    Write-Host
    Write-Host "🚀 Launch $AppName from:" -ForegroundColor Cyan
    Write-Host "   • Desktop shortcut (double-click)" -ForegroundColor White
    Write-Host "   • Start Menu > $AppName" -ForegroundColor White
    Write-Host "   • Command line: `"$InstallDir\$AppName.bat`"" -ForegroundColor White
    Write-Host
    Write-Host "💡 Tips:" -ForegroundColor Yellow
    Write-Host "   • Press F3 in Output Directory field to browse folders" -ForegroundColor White
    Write-Host "   • Press F1 or 'h' for help within the application" -ForegroundColor White
    Write-Host "   • Use Tab to navigate between input fields" -ForegroundColor White
    Write-Host
    
    $response = Read-Host "Launch $AppName now? (y/N)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host "🚀 Launching $AppName..." -ForegroundColor Green
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
    Write-Host "   This will remove all application files and shortcuts" -ForegroundColor Gray
    Write-Host
    
    $confirm = Read-Host "Are you sure you want to uninstall $AppName? (y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Uninstall cancelled." -ForegroundColor Yellow
        return
    }
    
    Write-Host
    Write-Host "Removing components..." -ForegroundColor Yellow
    
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
    Write-Host "   All $AppName files and shortcuts have been removed." -ForegroundColor Gray
    Write-Host
    Read-Host "Press Enter to exit"
}

# Main execution
try {
    if ($Uninstall) {
        Uninstall-Application
    } else {
        Install-Application
    }
}
catch {
    Write-Host
    Write-Host "❌ An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Please try running as administrator or contact support." -ForegroundColor Yellow
    Write-Host
    Read-Host "Press Enter to exit"
    exit 1
}
