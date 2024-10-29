#!/bin/bash

# Function to create a minimal project.pbxproj file
# nvm about ALL that, we can just use something else. brew install xcodegen


# Function to add files to the project.pbxproj (UNNEEDED
# Function to build an iOS app
build_ios_app() {
  local project_name="$1"
  local ipa_path="$project_name.ipa"

  # Navigate to the iOS folder
  cd "xcodeproj" || exit

  # Generate Xcode project (if needed)
  #mkdir -p "$project_name.xcodeproj"
  
  # Create a minimal project.pbxproj file
  #create_pbxproj "$project_name"

  # Add raw decompiled code (if necessary)
  #cp -R ../code/* "$project_name.xcodeproj"
  echo "Built $project_name!"
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

  # Add files from the ios folder to the project.pbxproj
  #add_files_to_pbxproj "$project_name"

  # Build the app without code signing
  echo "Building iOS app $project_name..."
  # xcodebuild -list "$project_name.xcodeproj"
  xcodebuild -project "$project_name.xcodeproj" \
      -sdk iphoneos \
      -scheme "MyApp" \
      -configuration Release \
      CODE_SIGN_IDENTITY="" \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGNING_ALLOWED=NO \
      PROVISIONING_PROFILE_SPECIFIER=""
      -archivePath "$project_name.xcarchive"

  # Export the IPA
  echo "Exporting $project_name IPA..."
  xcodebuild -exportArchive \
      -archivePath "$project_name.xcarchive" \
      -exportOptionsPlist exportOptions.plist \
      -exportPath "$ipa_path"

  echo "IPA path: $ipa_path"
  echo "$ipa_path"  # Return the IPA path
}

# Build RBXRemake
build_ios_app "RBXRemake"
# build_ios_app "RbxRemakeStudio" temporarily removed for testing!
