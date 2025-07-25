#!/bin/bash

echo "🚀 Creating Single-File Windows Installer"
echo "========================================="
echo

# First try to build for the current platform to test
echo "🔨 Building for current platform first..."
cargo build --release

if [ $? -ne 0 ]; then
    echo "❌ Build failed! Please fix compilation errors first."
    exit 1
fi

echo "✅ Current platform build successful"

# Check if we have Windows binary
WINDOWS_BINARY=""
if [ -f "target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe" ]; then
    WINDOWS_BINARY="target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe"
    echo "✅ Found existing Windows binary"
elif [ -f "dist/optics-ring-generator.exe" ]; then
    WINDOWS_BINARY="dist/optics-ring-generator.exe"
    echo "✅ Found Windows binary in dist/"
else
    echo "⚠️  No Windows binary found. Creating template installer..."
    echo "   To create a working installer:"
    echo "   1. Build for Windows: cargo build --release --target x86_64-pc-windows-gnu"
    echo "   2. Or copy optics-ring-generator.exe to dist/"
    echo "   3. Run this script again"
    echo
    
    # Copy the template
    cp OpticsRingGenerator-SingleFile-Installer.ps1 "OpticsRingGenerator-Windows-Installer.ps1"
    
    cat > "WINDOWS-INSTALLER-README.txt" << 'EOF'
Windows Installer Creation Guide
===============================

CURRENT STATUS: Template installer created
FILE: OpticsRingGenerator-Windows-Installer.ps1

TO CREATE WORKING INSTALLER:

1. Build Windows Binary:
   - Install mingw-w64: brew install mingw-w64 (macOS) or apt install mingw-w64 (Linux)
   - Add target: rustup target add x86_64-pc-windows-gnu
   - Build: cargo build --release --target x86_64-pc-windows-gnu
   
2. Generate Base64:
   - Run: base64 -w 0 target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe > binary.txt
   
3. Edit Installer:
   - Open OpticsRingGenerator-Windows-Installer.ps1
   - Replace [BINARY_DATA_HERE] with contents of binary.txt
   
4. Test Installer:
   - Copy .ps1 file to Windows machine
   - Right-click -> "Run with PowerShell"
   - Select "Run anyway" if Windows Defender appears

INSTALLER FEATURES:
• Single PowerShell file with embedded binary
• Administrator privilege handling
• Desktop and Start Menu shortcuts
• Programs and Features registration
• Built-in uninstaller
• Comprehensive documentation

The template installer will show instructions when run.
EOF
    
    echo "📄 Created template installer and instructions"
    echo "📍 Files created:"
    echo "   • OpticsRingGenerator-Windows-Installer.ps1 (template)"
    echo "   • WINDOWS-INSTALLER-README.txt (instructions)"
    exit 0
fi

# Create installer with embedded binary
echo "📦 Creating single-file installer with embedded binary..."

# Encode binary as base64
echo "🔄 Encoding binary as base64..."
BINARY_BASE64=$(base64 -w 0 "$WINDOWS_BINARY" 2>/dev/null || base64 -i "$WINDOWS_BINARY")

if [ -z "$BINARY_BASE64" ]; then
    echo "❌ Failed to encode binary as base64"
    exit 1
fi

BINARY_SIZE=$(stat -f%z "$WINDOWS_BINARY" 2>/dev/null || stat -c%s "$WINDOWS_BINARY")
BINARY_SIZE_MB=$(echo "scale=2; $BINARY_SIZE / 1024 / 1024" | bc)

echo "✅ Binary encoded successfully (${BINARY_SIZE_MB}MB)"

# Create the complete installer
echo "📝 Creating complete installer script..."

# Read the template and replace the placeholder
sed "s/\[BINARY_DATA_HERE\]/$BINARY_BASE64/g" OpticsRingGenerator-SingleFile-Installer.ps1 > "OpticsRingGenerator-Windows-Setup.ps1"

INSTALLER_SIZE=$(stat -f%z "OpticsRingGenerator-Windows-Setup.ps1" 2>/dev/null || stat -c%s "OpticsRingGenerator-Windows-Setup.ps1")
INSTALLER_SIZE_MB=$(echo "scale=2; $INSTALLER_SIZE / 1024 / 1024" | bc)

echo "✅ Complete installer created!"
echo
echo "📊 File sizes:"
echo "   • Original binary: ${BINARY_SIZE_MB}MB"
echo "   • Complete installer: ${INSTALLER_SIZE_MB}MB"
echo
echo "📦 Created file:"
echo "   • OpticsRingGenerator-Windows-Setup.ps1"
echo
echo "🚀 Distribution instructions:"
echo "   1. Send OpticsRingGenerator-Windows-Setup.ps1 to Windows users"
echo "   2. Users right-click the file and select 'Run with PowerShell'"
echo "   3. When Windows Defender warning appears, click 'More info' then 'Run anyway'"
echo "   4. Follow installation prompts (requires administrator privileges)"
echo
echo "🎯 Installer features:"
echo "   • Single file contains everything (no dependencies)"
echo "   • Automatic binary extraction and installation"
echo "   • Creates Desktop and Start Menu shortcuts"
echo "   • Registers in Programs and Features"
echo "   • Includes built-in uninstaller"
echo "   • Comprehensive documentation"
echo "   • Professional installation experience"
echo
echo "💡 The installer will:"
echo "   • Install to C:\\Program Files\\Optics Ring Generator\\"
echo "   • Create launcher that opens UI mode automatically"
echo "   • Provide complete documentation and help"
echo "   • Support clean uninstallation"
echo
echo "✅ Windows installer ready for distribution!"
