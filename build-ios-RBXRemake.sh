#!/bin/bash

# Navigate to the iOS folder with raw source
cd RBXRemake/ios

# Generate Xcode project from raw source
echo "Generating Xcode project for RBXRemake..."

# Create the .xcodeproj folder structure manually or use CMake if the project supports it
mkdir -p RBXRemake.xcodeproj

# Add all the necessary files to the xcodeproj (this is highly project-dependent)
# For a basic structure, we need the following directories and files
mkdir -p RBXRemake.xcodeproj/project.pbxproj

# Add raw decompiled code to the project
# This part will need adjustments based on how the code is structured
cp -R ../code/* RBXRemake.xcodeproj/

# Optional: create Info.plist and configure Bundle ID
echo "Setting up Info.plist..."
cat <<EOF > RBXRemake.xcodeproj/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.rbxremake.app</string>
    <key>CFBundleName</key>
    <string>RBXRemake</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOF

# Build the app using xcodebuild (the shell script should be run in GitHub Actions)
echo "Building iOS app RBXRemake..."
xcodebuild -project RBXRemake.xcodeproj -scheme RBXRemake -sdk iphoneos -configuration Release

# Export the IPA (iOS app package)
echo "Exporting RBXRemake IPA..."
xcodebuild -exportArchive -archivePath build/RBXRemake.xcarchive -exportOptionsPlist exportOptions.plist -exportPath RBXR.ipa

echo "RBXRemake build completed!"
