#!/bin/bash

# Build SystemMonitor as proper macOS app bundle
# Usage: ./build_app.sh

echo "🔨 Building SystemMonitor..."
swift build -c release

echo "📦 Creating app bundle..."
rm -rf /Applications/SystemMonitor.app
mkdir -p /Applications/SystemMonitor.app/Contents/MacOS

echo "📋 Copying executable..."
cp .build/arm64-apple-macosx/release/SystemMonitor /Applications/SystemMonitor.app/Contents/MacOS/SystemMonitor

echo "📄 Creating Info.plist..."
cat > /Applications/SystemMonitor.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>System Monitor</string>
	<key>CFBundleExecutable</key>
	<string>SystemMonitor</string>
	<key>CFBundleIdentifier</key>
	<string>com.andrei.systemmonitor</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>SystemMonitor</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSSupportsAutomaticGraphicsSwitching</key>
	<true/>
</dict>
</plist>
EOF

echo "🚀 Launching SystemMonitor.app..."
pkill -f SystemMonitor 2>/dev/null
open /Applications/SystemMonitor.app

echo "✅ SystemMonitor deployed successfully as proper macOS app!"
echo "   Location: /Applications/SystemMonitor.app"
echo "   You can now launch it from Launchpad or Applications folder"