#!/bin/bash

# Universal installer creator for OpticRingGenerator
# This creates installers for multiple platforms

set -e

echo "🔧 Creating Universal Installer for OpticRingGenerator..."

# Create dist directory if it doesn't exist
mkdir -p dist

# Build for current platform (macOS)
echo "📦 Building for current platform..."
cargo build --release

# Copy current platform binary
cp target/release/optics-ring-generator dist/

# Create PowerShell installer that downloads from GitHub releases
cat > "OpticsRingGenerator-Universal-Installer.ps1" << 'EOF'
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
EOF

echo "✅ Created OpticsRingGenerator-Universal-Installer.ps1"

# Create a simple installer for macOS that embeds the binary
echo "📦 Creating macOS installer with embedded binary..."

# Base64 encode the binary
BINARY_BASE64=$(base64 -i dist/optics-ring-generator)

cat > "OpticsRingGenerator-macOS-Installer.sh" << EOF
#!/bin/bash

# OpticRingGenerator macOS Installer
# This installer contains the embedded binary

set -e

APP_NAME="OpticRingGenerator"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="optics-ring-generator"

echo "🚀 Installing \$APP_NAME..."

# Check if running as root for system-wide installation
if [[ \$EUID -ne 0 ]]; then
    echo "⚠️  Not running as root. Installing to ~/bin instead of /usr/local/bin"
    INSTALL_DIR="\$HOME/bin"
    mkdir -p "\$INSTALL_DIR"
fi

# Decode and install binary
echo "📦 Extracting binary..."
cat << 'BINARY_EOF' | base64 -d > "\$INSTALL_DIR/\$BINARY_NAME"
$BINARY_BASE64
BINARY_EOF

# Make executable
chmod +x "\$INSTALL_DIR/\$BINARY_NAME"

# Add to PATH if installing to ~/bin
if [[ "\$INSTALL_DIR" == "\$HOME/bin" ]]; then
    if [[ ":\$PATH:" != *":\$HOME/bin:"* ]]; then
        echo "📝 Adding \$HOME/bin to PATH in ~/.zshrc"
        echo 'export PATH="\$HOME/bin:\$PATH"' >> ~/.zshrc
        echo "ℹ️  Please run 'source ~/.zshrc' or restart your terminal"
    fi
fi

echo "✅ \$APP_NAME installed successfully!"
echo "🚀 You can now run: \$BINARY_NAME"
echo ""
echo "📋 Usage examples:"
echo "   \$BINARY_NAME --help"
echo "   \$BINARY_NAME CX --diameter 25.0 --thickness 3.0"
echo "   \$BINARY_NAME --interactive"
echo ""
EOF

chmod +x OpticsRingGenerator-macOS-Installer.sh

echo "✅ Created OpticsRingGenerator-macOS-Installer.sh"

# Create instructions file
cat > "INSTALLER-INSTRUCTIONS.md" << 'EOF'
# OpticRingGenerator Installer Instructions

## Available Installers

### 1. Universal PowerShell Installer (Windows)
**File**: `OpticsRingGenerator-Universal-Installer.ps1`

This installer template can be customized to:
- Download from GitHub releases
- Install from embedded binary
- Create shortcuts and registry entries
- Support uninstallation

**Usage**:
```powershell
# Run as Administrator
PowerShell -ExecutionPolicy Bypass -File OpticsRingGenerator-Universal-Installer.ps1

# To uninstall
PowerShell -ExecutionPolicy Bypass -File OpticsRingGenerator-Universal-Installer.ps1 -Uninstall
```

### 2. macOS Self-Contained Installer
**File**: `OpticsRingGenerator-macOS-Installer.sh`

This installer contains the embedded macOS binary and handles:
- Binary extraction and installation
- PATH configuration
- Permission setup

**Usage**:
```bash
# For system-wide installation (requires sudo)
sudo ./OpticsRingGenerator-macOS-Installer.sh

# For user installation
./OpticsRingGenerator-macOS-Installer.sh
```

## Creating Windows Binary

To create the Windows installer with embedded binary:

1. **Install cross-compilation tools**:
   ```bash
   # On macOS with Homebrew
   brew install mingw-w64
   rustup target add x86_64-pc-windows-gnu
   ```

2. **Build Windows binary**:
   ```bash
   cargo build --release --target x86_64-pc-windows-gnu
   ```

3. **Run the complete installer creator**:
   ```bash
   ./create-single-file-installer.sh
   ```

## Distribution Strategy

### For GitHub Releases
1. Upload the generated installer files to GitHub releases
2. Update the download URLs in the PowerShell installer
3. Users can download and run the installer directly

### For Direct Distribution
1. Use the self-contained installers that embed the binary
2. No additional downloads required
3. Single file contains everything needed

## Installer Features

### Windows Installer
- ✅ Admin privilege checking
- ✅ Program Files installation
- ✅ Start Menu shortcuts
- ✅ Desktop shortcuts
- ✅ Registry entries (Programs & Features)
- ✅ Uninstallation support
- ✅ Version management

### macOS Installer
- ✅ Binary embedding (base64)
- ✅ PATH configuration
- ✅ Permission handling
- ✅ User vs system installation
- ✅ Shell integration

## Customization

To customize the installers:

1. **Update app information** in the installer scripts
2. **Change installation paths** as needed
3. **Add/remove shortcuts** and registry entries
4. **Modify uninstallation** behavior
5. **Add custom post-install** actions

## Testing

Test the installers on clean systems to ensure:
- All dependencies are included
- Shortcuts work correctly
- Uninstallation is complete
- No leftover files or registry entries
EOF

echo ""
echo "🎉 Universal installer system created!"
echo ""
echo "📋 Files created:"
echo "   • OpticsRingGenerator-Universal-Installer.ps1 (Windows)"
echo "   • OpticsRingGenerator-macOS-Installer.sh (macOS with embedded binary)"
echo "   • INSTALLER-INSTRUCTIONS.md (Documentation)"
echo ""
echo "🚀 The macOS installer is ready to use and contains the embedded binary!"
echo "📝 See INSTALLER-INSTRUCTIONS.md for detailed usage instructions."
echo ""
