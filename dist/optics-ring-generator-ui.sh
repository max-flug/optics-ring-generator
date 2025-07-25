#!/bin/bash

# Optics Ring Generator - macOS Launcher
# This script launches the interactive UI mode in a new terminal window

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY_PATH="$SCRIPT_DIR/optics-ring-generator"

# Check if binary exists
if [[ ! -f "$BINARY_PATH" ]]; then
    echo "Error: optics-ring-generator binary not found at $BINARY_PATH"
    echo "Please run 'cargo build --release' and copy the binary to this directory."
    exit 1
fi

# Launch in UI mode
echo "🔬 Launching Optics Ring Generator UI..."
echo "Press Ctrl+C to exit"
echo

"$BINARY_PATH" --ui
