#!/bin/bash

# Function to build an iOS app
build_ios_app() {
  local project_name="$1"
  local ipa_path="RBXR/$project_name.ipa"

  # Navigate to the iOS folder
  cd "$project_name/ios" || exit

  # Generate Xcode project (if needed)
  mkdir -p "$project_name.xcodeproj"

  # Add raw decompiled code (if necessary)
  cp -R ../code/* "$project_name.xcodeproj"

  # Create Info.plist and configure Bundle ID
  echo "Setting up Info.plist..."
  cat <<EOF > "$project_name.xcodeproj/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.$project_name.app</string>
    <key>CFBundleName</key>
    <string>$project_name</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOF

  # Build the app without code signing
  echo "Building iOS app $project_name..."
  xcodebuild -project "$project_name.xcodeproj" \
      -scheme "$project_name" \
      -sdk iphoneos \
      -configuration Release \
      CODE_SIGN_IDENTITY="" \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGNING_ALLOWED=NO \
      PROVISIONING_PROFILE_SPECIFIER=""

  # Export the IPA
  echo "Exporting $project_name IPA..."
  xcodebuild -exportArchive \
      -archivePath "build/$project_name.xcarchive" \
      -exportOptionsPlist exportOptions.plist \
      -exportPath RBXR

  echo "IPA path: $ipa_path"
  echo "$ipa_path"  # Return the IPA path
}

# Build RBXRemake and RbxRemakeStudio
build_ios_app "RBXRemake"
build_ios_app "RbxRemakeStudio"
