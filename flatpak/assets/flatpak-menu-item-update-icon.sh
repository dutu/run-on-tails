#!/bin/bash

# This script updates the icon for a Flatpak application, given the app's Id as an argument.
# It first checks if the .desktop file for the application exists in the local directory.
# If it does, it examines the Icon entry in the file.
# If the Icon entry matches the app's Id, the script looks for a new icon in two places:
#   - the app's persistent directory
#   - the Flatpak shared directory
# If a new icon is found, the Icon entry in the .desktop file is replaced with the new icon's path.

# Error codes
ERR_NO_ARGS=5
ERR_NOT_AMNESIA=6
ERR_NO_ICON_FILE=2
ERR_NO_ICON_ENTRY=3
ERR_NO_DESKTOP_FILE=4

# Flatpak application id is first argument
app_id="$1"

# Define the persistence directories and file paths
persistence_dir="/home/amnesia/Persistent"
persistent_desktop_dir="$persistence_dir/dotfiles/.local/share/applications"
persistent_desktop_path="$persistent_desktop_dir/$app_id.desktop"
flatpak_share_dir="$persistence_dir/flatpak/exports/share"

# Function to update the Flatpak app's icon
update_flatpak_app_icon() {
  # Check if the .desktop file exists
  if [[ ! -f $persistent_desktop_path ]]; then
    echo "Error: '$persistent_desktop_path' does not exist for app id $app_id."
    exit $ERR_NO_DESKTOP_FILE
  fi

  # Check if there is any icon entry that matches the app id
  if ! grep -q "Icon=$app_id" "$persistent_desktop_path"; then
    echo "Error: No 'Icon=$app_id' entries found."
    exit $ERR_NO_ICON_ENTRY
  fi

  # Check if the icon file exists in the persistence directory
  for ext in .png .svg .xpm .ico; do
    if [[ -f "$persistence_dir/$app_id/$app_id$ext" ]]; then
      new_icon="$persistence_dir/$app_id/$app_id$ext"
      break
    fi
  done

  # If new_icon is not set, check the flatpak applications directory
  if [[ -z $new_icon ]]; then
    # Icon sizes to search for, in descending order of preference
    for size in 128x128 64x64 48x48 32x32 16x16; do
      for ext in .png .svg .xpm .ico; do
        if [[ -f "$flatpak_share_dir/icons/hicolor/$size/apps/$app_id$ext" ]]; then
          new_icon="$flatpak_share_dir/icons/hicolor/$size/apps/$app_id$ext"
          break 2  # Break out of both loops
        fi
      done
    done
  fi

  # If the new icon is found
  if [[ -n $new_icon ]]; then
    # Replace the old icon path with the new one in the .desktop file, only if the icon matches the app id
    sed -i "s|^Icon=$app_id|Icon=$new_icon|" "$persistent_desktop_path"
    echo "Replaced 'Icon=$app_id' with 'Icon=$new_icon'."
  else
    echo "Error: Icon file not found for app id $app_id."
    exit $ERR_NO_ICON_FILE
  fi
}

# Ensure application ID has been passed to the script
if [ $# -eq 0 ]; then
  echo "No arguments supplied. Please provide a flatpak application ID."
  exit $ERR_NO_ARGS
fi

# Ensure we are running as 'amnesia'
if test "$(whoami)" != "amnesia"; then
  echo "You must run this program as 'amnesia' user."
  exit $ERR_NOT_AMNESIA
fi

# Call the function to update the Icon entry
update_flatpak_app_icon
