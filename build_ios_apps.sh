#!/bin/bash

# Function to create a minimal project.pbxproj file
create_pbxproj() {
  local project_name="$1"
  local pbxproj_path="$project_name.xcodeproj/project.pbxproj"
  
  echo "Creating project.pbxproj for $project_name..."
  cat <<EOF > "$pbxproj_path"
// !$*UTF8*$!
{  
  archiveVersion = 1;
  classes = {};
  objectVersion = 46;
  objects = {
    /* Begin PBXProject section */
    1E0C65F31CFC2289001FAAA9 /* Project object */ = {
      isa = PBXProject;
      attributes = {
        LastUpgradeCheck = 1400;
        ORGANIZATIONNAME = "RBXRemake Co (family project)"; // Replace with your organization name
      };
      buildConfigurationList = 1E0C65F21CFC2289001FAAA9 /* Build configuration list */;
      compatibilityVersion = "Xcode 15.4";
      mainGroup = 1E0C65F21CFC2289001FAAA9 /* Source Files */;
      productRefGroup = 1E0C65F31CFC2289001FAAA9 /* Products */;
      targets = (
        1E0C65F21CFC2289001FAAA9 /* Target */;
      );
    };
    /* End PBXProject section */
    
    /* Begin PBXNativeTarget section */
    1E0C65F21CFC2289001FAAA9 /* Target */ = {
      isa = PBXNativeTarget;
      buildConfigurationList = 1E0C65F21CFC2289001FAAA9 /* Build configuration list */;
      dependencies = ();
      name = "$project_name";
      productName = "$project_name";
      productReference = 1E0C65F41CFC2289001FAAA9 /* $project_name */;
      productType = "com.apple.product-type.application";
    };
    /* End PBXNativeTarget section */

    /* Begin PBXFileReference section */
    1E0C65F41CFC2289001FAAA9 /* $project_name */ = {
      isa = PBXFileReference;
      lastKnownFileType = "wrapper.application";
      path = "$project_name.ipa";
      sourceTree = "<group>";
    };
    /* End PBXFileReference section */
  };

  rootObject = 1E0C65F31CFC2289001FAAA9 /* Project object */;
}
EOF
}

# Function to add files to the project.pbxproj
add_files_to_pbxproj() {
  local project_name="$1"
  local pbxproj_path="$project_name.xcodeproj/project.pbxproj"
  local files_dir="$project_name/ios"
  local file_refs=""

  echo "Adding files from $files_dir to project.pbxproj..."
  
  # Iterate over all files in the directory and add them to the pbxproj
  for file in "$files_dir"/*; do
    if [ -f "$file" ]; then
      # Generate a unique identifier for the file
      local file_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
      # Add the file entry to the project.pbxproj
      echo "Adding $file to project.pbxproj"
      file_refs+="$file_id /* $(basename "$file") */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.objc; path = \"$(basename "$file")\"; sourceTree = \"<group>\"; };\n"
    fi
  done
  
  # Append the file references to the pbxproj
  {
    echo "/* Begin PBXFileReference section */"
    echo -e "$file_refs"
    echo "/* End PBXFileReference section */"
  } >> "$pbxproj_path"
}

# Function to build an iOS app
build_ios_app() {
  local project_name="$1"
  local ipa_path="Apps/$project_name.ipa"

  # Navigate to the iOS folder
  cd "$project_name/ios" || exit

  # Generate Xcode project (if needed)
  mkdir -p "$project_name.xcodeproj"
  
  # Create a minimal project.pbxproj file
  create_pbxproj "$project_name"

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

  # Add files from the ios folder to the project.pbxproj
  add_files_to_pbxproj "$project_name"

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
      -exportPath "$ipa_path"

  echo "IPA path: $ipa_path"
  echo "$ipa_path"  # Return the IPA path
  if [[ -f "$ipa_path" ]]; then
    echo "$project_name IPA built successfully at $ipa_path."
    
    # Add, commit, and push the IPA file to the repository
    git config --global user.name "github-actions[bot]"
    git config --global user.email "github-actions[bot]@users.noreply.github.com"
    git checkout -b build-artifacts || git checkout build-artifacts
    git add "$ipa_path"
    git commit -m "Add $project_name IPA build artifact"
    git push origin build-artifacts
  else
    echo "Error: IPA file not found at $ipa_path."
    exit 1
  fi
}

# Build RBXRemake
build_ios_app "RBXRemake"
# build_ios_app "RbxRemakeStudio" temporarily removed for testing!
