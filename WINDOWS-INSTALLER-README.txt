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
