#!/bin/bash

# Navigate to the iOS folder with raw source
cd RBXRemake/ios

# Generate Xcode project from raw source
echo "Generating Xcode project for RBXRemake..."

# Optional: Create the .xcodeproj folder structure manually or use CMake if the project supports it
mkdir -p RBXRemake.xcodeproj

# Add the necessary path for exporting the IPA:
mkdir -p RBXR

# Add raw decompiled code to the project
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

# Build the app without code signing
echo "Building iOS app RBXRemake without code signing..."
xcodebuild -project RBXRemake.xcodeproj \
  -scheme RBXRemake \
  -sdk iphoneos \
  -configuration Release \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  PROVISIONING_PROFILE_SPECIFIER=""

# Export the IPA
echo "Exporting RBXRemake IPA..."
xcodebuild -exportArchive \
  -archivePath build/RBXRemake.xcarchive \
  -exportOptionsPlist exportOptions.plist \
  -exportPath RBXR

echo "RBXRemake build completed!"
