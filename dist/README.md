# Optics Ring Generator - Distribution Files

This directory contains ready-to-use executables for different platforms.

## 🖥️ **macOS Users**

### Option 1: Script Launcher (Recommended)
Double-click `optics-ring-generator-ui.sh` or run it from Terminal:
```bash
./optics-ring-generator-ui.sh
```

### Option 2: Native App Bundle
Double-click `OpticsRingGenerator.app` to launch the UI in a new Terminal window.

## 🪟 **Windows Users**

Double-click `optics-ring-generator-ui.bat` to launch the interactive UI.

## 🐧 **Linux Users**

Run the shell script:
```bash
./optics-ring-generator-ui.sh
```

## 📁 **Files Included**

- `optics-ring-generator` / `optics-ring-generator.exe` - The main binary
- `optics-ring-generator-ui.sh` - Cross-platform launcher script (macOS/Linux)
- `optics-ring-generator-ui.bat` - Windows launcher batch file
- `OpticsRingGenerator.app` - macOS app bundle (double-click to launch)

## 🔧 **Command Line Usage**

You can also use the binary directly from command line:

```bash
# Interactive UI mode
./optics-ring-generator --ui

# Command line mode
./optics-ring-generator --ring-type cx --outer-diameter 50.0 --inner-diameter 25.0

# Show help
./optics-ring-generator --help
```

## 🎯 **Quick Start**

1. **macOS**: Double-click `OpticsRingGenerator.app` or `optics-ring-generator-ui.sh`
2. **Windows**: Double-click `optics-ring-generator-ui.bat`
3. **Linux**: Run `./optics-ring-generator-ui.sh` from terminal

The interactive UI will guide you through:
- Selecting ring type (Convex, Concave, Three-point)
- Setting dimensions
- **Choosing output directory with F3 file browser**
- Generating STL files for 3D printing

## 💡 **Tips**

- Press **F1** or **h** for help in the UI
- Press **F3** when in Output Directory field to browse folders
- Use **Tab** to move between fields
- Press **q** or **Esc** to quit

Enjoy creating precision optics support rings! 🔬
