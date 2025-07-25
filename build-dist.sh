#!/bin/bash

echo "🔧 Building Cross-Platform Executables for Optics Ring Generator"
echo "================================================================"
echo

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "❌ Error: Rust/Cargo not found. Please install Rust first."
    exit 1
fi

# Create dist directory
mkdir -p dist
echo "📁 Created dist directory"

# Build for current platform (development)
echo "🔨 Building for current platform..."
cargo build --release
if [ $? -eq 0 ]; then
    echo "✅ Current platform build successful"
else
    echo "❌ Current platform build failed"
    exit 1
fi

# Copy binary to dist for current platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    cp target/release/optics-ring-generator dist/
    echo "✅ Copied macOS binary to dist/"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    cp target/release/optics-ring-generator dist/
    echo "✅ Copied Linux binary to dist/"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows
    cp target/release/optics-ring-generator.exe dist/
    echo "✅ Copied Windows binary to dist/"
fi

echo
echo "📦 Available files in dist/:"
ls -la dist/

echo
echo "🎯 To build for other platforms, install targets and use:"
echo "   rustup target add x86_64-pc-windows-gnu  # Windows"
echo "   rustup target add x86_64-apple-darwin    # macOS Intel"
echo "   rustup target add aarch64-apple-darwin   # macOS Apple Silicon"
echo "   rustup target add x86_64-unknown-linux-gnu  # Linux"
echo
echo "   Then run:"
echo "   cargo build --release --target x86_64-pc-windows-gnu"
echo "   cargo build --release --target x86_64-apple-darwin"
echo "   etc."

echo
echo "🚀 Ready to use! Run the appropriate launcher:"
echo "   macOS/Linux: ./dist/optics-ring-generator-ui.sh"
echo "   Windows:     dist\\optics-ring-generator-ui.bat"
