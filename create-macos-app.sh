#!/bin/bash

echo "📱 Creating macOS App Bundle"
echo "============================"

APP_NAME="Optics Ring Generator"
BUNDLE_NAME="OpticsRingGenerator.app"
BUNDLE_DIR="dist/$BUNDLE_NAME"

# Create app bundle structure
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

# Copy binary
cp target/release/optics-ring-generator "$BUNDLE_DIR/Contents/MacOS/"

# Create Info.plist
cat > "$BUNDLE_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>optics-ring-generator-launcher</string>
    <key>CFBundleIdentifier</key>
    <string>com.opticsring.generator</string>
    <key>CFBundleName</key>
    <string>Optics Ring Generator</string>
    <key>CFBundleDisplayName</key>
    <string>Optics Ring Generator</string>
    <key>CFBundleVersion</key>
    <string>0.1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

# Create launcher script that opens Terminal
cat > "$BUNDLE_DIR/Contents/MacOS/optics-ring-generator-launcher" << 'EOF'
#!/bin/bash

# Get the directory of this app bundle
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BINARY_PATH="$APP_DIR/MacOS/optics-ring-generator"

# Create a temporary script that will run in Terminal
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << INNER_EOF
#!/bin/bash
echo "🔬 Optics Ring Generator"
echo "======================="
echo "Launching interactive UI mode..."
echo
"$BINARY_PATH" --ui
echo
echo "Press Enter to close this window..."
read
INNER_EOF

chmod +x "$TEMP_SCRIPT"

# Open Terminal and run our script
osascript -e "tell application \"Terminal\" to do script \"$TEMP_SCRIPT; exit\""

# Clean up
sleep 1
rm "$TEMP_SCRIPT"
EOF

chmod +x "$BUNDLE_DIR/Contents/MacOS/optics-ring-generator-launcher"

echo "✅ Created $BUNDLE_NAME"
echo "   Double-click the app to launch the UI in Terminal"
echo "   Located at: $BUNDLE_DIR"
