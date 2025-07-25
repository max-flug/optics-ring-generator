#!/bin/bash

echo "🌐 Cross-Platform Build Guide for Optics Ring Generator"
echo "======================================================="
echo
echo "This script helps you build binaries for multiple platforms."
echo

# Check available targets
echo "📋 Currently installed Rust targets:"
rustup target list --installed

echo
echo "🎯 To add more targets for cross-compilation:"
echo "   rustup target add x86_64-pc-windows-gnu     # Windows (GNU)"
echo "   rustup target add x86_64-pc-windows-msvc    # Windows (MSVC)"
echo "   rustup target add x86_64-apple-darwin       # macOS Intel"
echo "   rustup target add aarch64-apple-darwin      # macOS Apple Silicon"
echo "   rustup target add x86_64-unknown-linux-gnu  # Linux x64"
echo "   rustup target add aarch64-unknown-linux-gnu # Linux ARM64"

echo
echo "🔨 Building for available targets..."

# Create dist directories
mkdir -p dist/windows
mkdir -p dist/macos-intel
mkdir -p dist/macos-arm
mkdir -p dist/linux

# Build for current platform
echo "Building for current platform..."
cargo build --release
cp target/release/optics-ring-generator* dist/

# Try building for other platforms if targets are available
if rustup target list --installed | grep -q "x86_64-pc-windows-gnu"; then
    echo "Building for Windows (GNU)..."
    cargo build --release --target x86_64-pc-windows-gnu
    cp target/x86_64-pc-windows-gnu/release/optics-ring-generator.exe dist/windows/
    cp dist/optics-ring-generator-ui.bat dist/windows/
fi

if rustup target list --installed | grep -q "x86_64-apple-darwin"; then
    echo "Building for macOS Intel..."
    cargo build --release --target x86_64-apple-darwin
    cp target/x86_64-apple-darwin/release/optics-ring-generator dist/macos-intel/
    cp dist/optics-ring-generator-ui.sh dist/macos-intel/
fi

if rustup target list --installed | grep -q "aarch64-apple-darwin"; then
    echo "Building for macOS Apple Silicon..."
    cargo build --release --target aarch64-apple-darwin
    cp target/aarch64-apple-darwin/release/optics-ring-generator dist/macos-arm/
    cp dist/optics-ring-generator-ui.sh dist/macos-arm/
fi

if rustup target list --installed | grep -q "x86_64-unknown-linux-gnu"; then
    echo "Building for Linux x64..."
    cargo build --release --target x86_64-unknown-linux-gnu
    cp target/x86_64-unknown-linux-gnu/release/optics-ring-generator dist/linux/
    cp dist/optics-ring-generator-ui.sh dist/linux/
fi

echo
echo "✅ Build complete! Check the dist/ directory for platform-specific builds."
echo "📦 To create distributable packages:"
echo "   cd dist && tar -czf optics-ring-generator-macos.tar.gz optics-ring-generator* OpticsRingGenerator.app"
echo "   cd dist && zip -r optics-ring-generator-windows.zip windows/"
echo "   cd dist && tar -czf optics-ring-generator-linux.tar.gz linux/"
