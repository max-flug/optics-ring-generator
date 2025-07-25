# GitHub Actions Setup Guide

## 🚀 Automatic Build and Release System

Your OpticRingGenerator project now includes a comprehensive GitHub Actions workflow that automatically builds Windows binaries and creates complete single-file installers!

## ✅ What the Workflow Does

### On Every Push to Main/Master:
- 🧪 **Runs tests** to ensure code quality
- 🔨 **Builds binaries** for:
  - Windows (x86_64)
  - macOS (x86_64 + ARM64 universal binary)
  - Linux (x86_64)
- 📦 **Creates complete installers** with embedded binaries:
  - `OpticsRingGenerator-Windows-Installer.ps1` (PowerShell)
  - `OpticsRingGenerator-macOS-Installer.sh` (Shell script)
  - `OpticsRingGenerator-Linux-Installer.sh` (Shell script)
- 💾 **Uploads artifacts** for download

### On Version Tags (v*):
- 🎯 **Everything above** PLUS
- 🚀 **Creates GitHub Release** with all installers and binaries
- 📋 **Release notes** with usage instructions

## 🛠️ Setup Instructions

### 1. Initial Setup
```bash
# Make sure you're in your project directory
cd /Users/maximilianflug/Documents/rust/x-ring2

# Add and commit the workflow
git add .github/workflows/build-and-release.yml
git commit -m "Add GitHub Actions workflow for automatic builds"

# Push to trigger first build
git push origin main
```

### 2. Check Build Status
1. Go to your GitHub repository
2. Click the **"Actions"** tab
3. Watch the workflow run in real-time!

### 3. Download Built Installers
After the workflow completes:
1. Click on the completed workflow run
2. Scroll down to **"Artifacts"** section
3. Download the installers:
   - `installers` - Contains all single-file installers
   - Individual platform binaries are also available

## 🎯 Creating Releases

### Automatic Release
```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This triggers:
- ✅ Full build for all platforms
- ✅ Complete installer creation
- ✅ GitHub Release with download links
- ✅ Release notes with usage examples

### Manual Workflow Trigger
You can also trigger builds manually:
1. Go to **Actions** tab on GitHub
2. Select **"Build and Release"** workflow
3. Click **"Run workflow"**
4. Choose branch and click **"Run workflow"**

## 📋 Workflow File Location

The workflow is defined in:
```
.github/workflows/build-and-release.yml
```

## 🔧 Customization

### Modify Build Targets
Edit the `matrix.include` section in the workflow to add/remove platforms:

```yaml
matrix:
  include:
    - os: ubuntu-latest
      target: x86_64-unknown-linux-gnu
    - os: windows-latest
      target: x86_64-pc-windows-msvc
    # Add more targets as needed
```

### Change Trigger Conditions
Modify the `on:` section to change when builds trigger:

```yaml
on:
  push:
    branches: [ main, develop ]  # Add more branches
    tags: [ 'v*', 'release-*' ]  # Add more tag patterns
```

## 🎉 Benefits

### For You (Developer):
- 🤖 **No manual cross-compilation** needed
- 🔄 **Automatic testing** on every change
- 📦 **Ready-to-distribute installers** without extra work
- 🚀 **Professional release process**

### For Users:
- 📥 **Single-file installers** for all platforms
- 🛡️ **Consistent, tested builds**
- 🔗 **Easy download from GitHub Releases**
- 💻 **No compilation required**

## 🐛 Troubleshooting

### Build Fails?
1. Check the **Actions** tab for error details
2. Common issues:
   - Test failures (fix tests first)
   - Dependency issues (check Cargo.toml)
   - Platform-specific build errors

### No Artifacts?
- Make sure the workflow completed successfully
- Artifacts are only available for ~90 days
- Create a release for permanent storage

### Wrong Binary Architecture?
- Check the `matrix.target` values in the workflow
- Ensure you're downloading the right artifact for your platform

## 📈 Next Steps

1. **Test the workflow** by pushing a small change
2. **Create your first release** with a version tag
3. **Share the installers** with users
4. **Customize** the workflow as needed for your project

Your OpticRingGenerator project now has enterprise-grade automated building and distribution! 🎉
