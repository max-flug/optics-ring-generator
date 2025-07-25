#!/bin/bash

echo "Testing Directory Browser Functionality"
echo "======================================="
echo ""
echo "This script will launch the interactive UI mode."
echo "Follow these steps to test the directory browser:"
echo ""
echo "1. Press Tab until you reach the 'Output Directory' field"
echo "2. Press F3 to open the directory browser"
echo "3. Use ↑/↓ arrow keys to navigate directories"
echo "4. Press Enter to enter a selected directory"
echo "5. Press Space to select the current directory"
echo "6. Press h to toggle hidden files visibility"
echo "7. Press Esc to cancel, or Space to confirm selection"
echo ""
echo "Press Enter to start the application..."
read

cargo run -- --ui
