# Optics Ring Generator

A Rust CLI application for generating 3D printable precision optics support rings. This tool creates STL files for three different types of support rings commonly used in precision optics applications.

## Features

- **Three Ring Types**:
  - **Convex (CX)**: Curves inward toward the lens for gentle contact
  - **Concave (CC)**: Curves outward from the lens for secure cradling
  - **Three-Point (3P)**: Minimal contact points for maximum stability

- **Dual Interface**:
  - **Command Line Interface**: Perfect for automation and scripting
  - **Interactive Terminal UI**: User-friendly interface with directory browser

- **Directory Browser**: Interactive file system navigation to select output directories
- **3D Printing Validation**: Automatic checks for wall thickness and practical size limits
- **Manufacturing Information**: Detailed printing recommendations and material estimates
- **STL File Generation**: Ready-to-print STL files with proper naming convention

## Installation

### Prerequisites

- Rust 1.70.0 or later
- Cargo package manager

### Quick Start (Executable Files)

**Ready-to-use executables are available in the `dist/` directory:**

- **macOS**: Double-click `OpticsRingGenerator.app` or run `optics-ring-generator-ui.sh`
- **Windows**: Double-click `optics-ring-generator-ui.bat`
- **Linux**: Run `./optics-ring-generator-ui.sh`

### Building from Source

```bash
git clone <repository-url>
cd optics-ring-generator
cargo build --release
```

The compiled binary will be available at `target/release/optics-ring-generator`

### Cross-Platform Distribution

To create executables for all platforms:

```bash
./build-dist.sh          # Build for current platform
./build-cross-platform.sh # Build for multiple platforms (requires targets)
```

## Usage

### Interactive UI Mode (Recommended)

```bash
cargo run -- --ui
```

The interactive mode provides:
- Visual form-based input with field validation
- **Directory browser** (press F3 when in Output Directory field)
- Real-time preview and help system
- Progress indicators during STL generation

#### Directory Browser Controls
- **↑/↓ Arrow keys**: Navigate file/folder list
- **Enter**: Enter selected directory
- **Space**: Select current directory as output location
- **h**: Toggle visibility of hidden files
- **Esc**: Cancel and return to main interface

### Command Line Mode

```bash
cargo run -- --ring-type <TYPE> --outer-diameter <MM> --inner-diameter <MM>
```

### Examples

```bash
# Generate a convex ring with 50mm outer diameter and 25mm inner diameter
cargo run -- --ring-type cx --outer-diameter 50.0 --inner-diameter 25.0

# Generate a concave ring with manufacturing information
cargo run -- --ring-type cc --outer-diameter 40.0 --inner-diameter 20.0 --manufacturing-info

# Generate a three-point ring in a specific output directory
cargo run -- --ring-type 3p --outer-diameter 30.0 --inner-diameter 15.0 --output-dir ./rings/
```

### Command Line Options

- `-r, --ring-type <TYPE>`: Ring type (cx, cc, 3p)
- `-o, --outer-diameter <MM>`: Outer diameter in millimeters
- `-i, --inner-diameter <MM>`: Inner diameter in millimeters
- `--output-dir <DIR>`: Output directory (default: current directory)
- `--skip-validation`: Skip 3D printing validation checks
- `--manufacturing-info`: Show detailed manufacturing information
- `--ui`: Launch interactive UI mode (recommended for new users)
- `-h, --help`: Show help information
- `-V, --version`: Show version information

## Interactive Terminal Interface

The application includes a modern terminal user interface built with ratatui that provides:

### Key Features
- **Form-based input**: Navigate between fields with Tab/Shift+Tab
- **Visual feedback**: Real-time validation and error messages
- **Directory browser**: Press F3 in the Output Directory field to browse and select folders
- **Help system**: Press F1 or 'h' for comprehensive help
- **Preview mode**: Press 'p' to see ring specifications before generation

### Navigation
- **Tab**: Move to next field
- **Shift+Tab**: Move to previous field
- **Arrow keys**: Navigate lists and directory browser
- **Enter**: Select options or generate STL file
- **F1/h**: Toggle help panel
- **F3**: Open directory browser (when in Output Directory field)
- **p**: Toggle preview panel
- **q/Esc**: Quit application

### Directory Browser
The integrated directory browser allows you to:
- Navigate your file system visually
- See folders marked with 📁 and files with 📄
- Access parent directories with ".." entries
- Toggle hidden file visibility with 'h'
- Select any directory as the output location

## Ring Types

### Convex (CX)
- Curved inward toward the lens
- Provides gentle, distributed contact
- Ideal for delicate optical surfaces
- No support structures required for printing

### Concave (CC)
- Curved outward from the lens
- Creates a secure cradle for the lens
- Good for lenses that need stable positioning
- May require light support structures

### Three-Point (3P)
- Three contact points at 120-degree intervals
- Minimal contact with the lens surface
- Maximum stability with minimal stress
- Ideal for precision applications

## File Naming Convention

Generated STL files follow the pattern: `{TYPE}-{INNER_DIAMETER}.stl`

Examples:
- `CX-25.0.stl` - Convex ring with 25mm inner diameter
- `CC-20.0.stl` - Concave ring with 20mm inner diameter
- `3P-15.0.stl` - Three-point ring with 15mm inner diameter

## 3D Printing Recommendations

### General Settings
- **Layer Height**: 0.15-0.2mm for smooth curves
- **Material**: PLA or PETG for optical applications
- **Infill**: 100% for maximum stability
- **Orientation**: Place flat on build plate

### Material Considerations
- **PLA**: Easy to print, good dimensional accuracy
- **PETG**: Better chemical resistance, optical clarity
- **ABS**: Higher temperature resistance (if needed)

### Quality Requirements
- Minimum wall thickness: 1.0mm (automatically validated)
- Surface finish: Consider post-processing for optical contact surfaces
- Dimensional accuracy: ±0.1mm recommended for precision fit

## Validation

The application automatically validates:
- Minimum wall thickness (1.0mm for reliable printing)
- Maximum practical size (300mm outer diameter)
- Minimum practical size (5.0mm inner diameter)
- Geometric constraints (outer > inner diameter)

Use `--skip-validation` to bypass these checks if needed.

## Dependencies

- [clap](https://crates.io/crates/clap) - Command line argument parsing
- [ratatui](https://crates.io/crates/ratatui) - Terminal user interface framework
- [crossterm](https://crates.io/crates/crossterm) - Cross-platform terminal manipulation
- [stl_io](https://crates.io/crates/stl_io) - STL file generation
- [nalgebra](https://crates.io/crates/nalgebra) - Linear algebra for 3D geometry
- [anyhow](https://crates.io/crates/anyhow) - Error handling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is available under the MIT License. See LICENSE file for details.

## Support

For issues, feature requests, or questions, please open an issue on the project repository.

## Technical Notes

### Geometry Generation
- Rings are generated with 64 segments for smooth curves
- Convex/concave curves use parametric equations for optical-quality surfaces
- Three-point rings have contact areas spanning 15 degrees each

### STL Format
- Binary STL format for smaller file sizes
- Proper normal vectors for 3D printing software compatibility
- Watertight meshes suitable for slicing software

### Performance
- Release builds recommended for faster STL generation
- Memory usage scales with complexity (typically <100MB for standard rings)
- Generation time: <1 second for typical ring sizes
