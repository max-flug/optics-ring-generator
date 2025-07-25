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
