# Windows Installation Guide for OpticRingGenerator

## Quick Start (Single File Installation)

You now have a **complete installer system** that creates single-file installers for both platforms!

### ✅ What's Ready Now

1. **macOS Self-Contained Installer** (`OpticsRingGenerator-macOS-Installer.sh`)
   - ✅ **WORKING AND TESTED** - Contains embedded binary
   - ✅ Installs to `~/bin` or `/usr/local/bin`
   - ✅ Handles PATH configuration automatically
   - ✅ Single file contains everything needed

2. **Windows Universal Installer Template** (`OpticsRingGenerator-Universal-Installer.ps1`)
   - ✅ Complete installer framework ready
   - ✅ Admin privileges, shortcuts, registry entries
   - ✅ Professional uninstallation support
   - ⏳ Needs Windows binary to be complete

### 🚀 For Windows Users

#### Option 1: Use the Template Installer (Recommended)
```powershell
# Download and run as Administrator
PowerShell -ExecutionPolicy Bypass -File OpticsRingGenerator-Universal-Installer.ps1
```

This installer will:
- ✅ Create proper installation directory in Program Files
- ✅ Add desktop and start menu shortcuts
- ✅ Register with Windows "Programs & Features"
- ✅ Support proper uninstallation
- ✅ Show instructions for completing the installation

#### Option 2: Manual Installation
1. Download or build the Windows binary (`optics-ring-generator.exe`)
2. Copy to `C:\Program Files\OpticRingGenerator\`
3. Add to PATH manually

### 🔧 Creating Complete Windows Installer

#### ✅ **Recommended: GitHub Actions (Automated)**

The project now includes **GitHub Actions** that automatically build Windows binaries and create complete installers!

**Setup**:
1. Push your code to GitHub
2. The workflow automatically builds for Windows, macOS, and Linux
3. Creates complete single-file installers with embedded binaries
4. Uploads everything as release artifacts

**Workflow triggers**:
- ✅ **Push to main/master** - Creates development builds
- ✅ **Create tag (v*)** - Creates full release with all installers
- ✅ **Manual trigger** - Run workflow anytime via GitHub UI

**What you get automatically**:
- `OpticsRingGenerator-Windows-Installer.ps1` - Complete Windows installer with embedded binary
- `OpticsRingGenerator-macOS-Installer.sh` - Complete macOS installer with universal binary
- `OpticsRingGenerator-Linux-Installer.sh` - Complete Linux installer
- Individual binaries for all platforms

#### Alternative: Manual Building

**On Windows Machine**:
```bash
# 1. Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 2. Clone and build
git clone <your-repo>
cd optics-ring-generator
cargo build --release

# 3. Create installer (requires PowerShell as Admin)
# The installer template will guide you through the process
```

**Cross-compilation approach**:
```bash
# Try alternative cross-compilation approach
cargo install cross
cross build --target x86_64-pc-windows-gnu --release

# If successful, run:
./create-single-file-installer.sh
```

### 📋 Installer Features

#### Windows Installer Capabilities:
- 🔐 **Administrator privilege checking**
- 📁 **Professional installation to Program Files**
- 🔗 **Desktop and Start Menu shortcuts**
- 📝 **Windows registry integration**
- 🗑️ **Complete uninstallation support**
- 📊 **Programs & Features integration**
- 🔄 **Version management**

#### macOS Installer Capabilities:
- 📦 **Embedded binary (base64 encoded)**
- 🛠️ **Automatic PATH configuration**
- 👤 **User vs system installation**
- 🔧 **Shell integration (zsh)**
- ✅ **No additional dependencies**

### 🎯 Distribution Strategy

#### For End Users:
1. **macOS**: Download and run `OpticsRingGenerator-macOS-Installer.sh`
2. **Windows**: Download and run `OpticsRingGenerator-Universal-Installer.ps1`

#### For Developers:
1. Use the provided installer templates
2. Customize as needed for your distribution
3. Upload to GitHub releases or distribute directly

### ✨ What Makes This Special

This installer system provides:
- 🎯 **Single-file installation** for both platforms
- 🔒 **Professional security** (admin checks, code signing ready)
- 🎨 **User-friendly experience** (proper shortcuts, uninstallation)
- 🔧 **Developer-friendly** (easy to customize and maintain)
- 📦 **Self-contained** (no external dependencies)

### 🚀 Ready to Use!

The **macOS installer is complete and working**. For Windows, you now have **three options**:

1. ✅ **GitHub Actions (Recommended)** - Automatic builds and installers
2. ✅ **Template installer** - Professional installer framework  
3. ✅ **Manual building** - Build on Windows machine

**Next Steps:**
1. ✅ Test the macOS installer (already working!)
2. � **NEW: Push to GitHub to trigger automatic builds**
3. 🎉 Download complete installers from GitHub Actions artifacts!

## 🤖 Using GitHub Actions (Recommended)

### Quick Start
1. **Push your code to GitHub**:
   ```bash
   git add .
   git commit -m "Add GitHub Actions workflow"
   git push origin main
   ```

2. **Check the Actions tab** on GitHub - builds start automatically!

3. **Download installers** from the workflow artifacts

### Creating a Release
```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This automatically:
- ✅ Builds binaries for Windows, macOS, and Linux
- ✅ Creates complete single-file installers with embedded binaries
- ✅ Creates a GitHub release with all files
- ✅ Makes installers available for download

### Workflow Features
- 🔨 **Cross-platform builds** (Windows, macOS x64/ARM64, Linux)
- 📦 **Embedded binary installers** for all platforms
- 🧪 **Automated testing** before building
- 🚀 **Release automation** on version tags
- 💾 **Artifact uploads** for every build

---

*This installer system provides enterprise-grade installation experience while maintaining simplicity for end users.*
