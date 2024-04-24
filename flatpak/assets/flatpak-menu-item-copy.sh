#!/bin/bash

# This script generates a menu item, represented by a .desktop file, for a specific Flatpak application, the Id of which is passed as a parameter.
# If a custom .desktop file is available in the application's persistent directory, it is used as the source for the menu item.
# If this custom file does not exist, the script defaults to using the .desktop file from the Flatpak application's own directory.
# A copy of the source .desktop file is placed in the persistent dotfile directory, and a corresponding symbolic link is created in the local directory.

# Error codes
ERR_NO_ARGS=5
ERR_NOT_AMNESIA=6
ERR_NO_DESKTOP_FILE=4

# Flatpak application id is first argument
app_id="$1"

# Define the persistence directories and file paths
persistence_dir="/home/amnesia/Persistent"
dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
persistent_desktop_dir="$dotfiles_dir/.local/share/applications"
flatpak_share_dir="$persistence_dir/flatpak/exports/share"

# Define local desktop directory
local_desktop_dir="/home/amnesia/.local/share/applications"

create_app_menu_item() {
  # Determine the source of the .desktop file for the app
  if [[ -f "$persistence_dir/$app_id/$app_id.desktop" ]]; then
    # If a custom desktop file exists in the persistence directory use this as source
    desktop_file_path="$persistence_dir/$app_id/$app_id.desktop"
  else
    # If no custom desktop file, use the one from flatpak application directory as source
    desktop_file_path="$flatpak_share_dir/applications/$app_id.desktop"
  fi

  # Check if the source .desktop file has been located
  if [[ -f $desktop_file_path ]]; then
    # Create a copy of it in the persistent .desktop directory
    cp "$desktop_file_path" "$persistent_desktop_dir/$app_id.desktop"

    # Check if a symbolic link or file already exists in local .desktop directory
    if [[ -e "$local_desktop_dir/$app_id.desktop" ]]; then
      # If it does, delete it
      rm "$local_desktop_dir/$app_id.desktop"
    fi

    # Create a symbolic link to it in the local .desktop directory
    ln -s "$persistent_desktop_dir/$app_id.desktop" "$local_desktop_dir/$app_id.desktop"
    echo -e "Created $app_id.desktop file, representing the menu item for application ID '$app_id'.\nThe menu item may still not be visible without updating .desktop file entries."
    exit 0
  else
    echo "Could not locate the source .desktop file for application ID '$app_id'. Exiting..."
    exit $ERR_NO_DESKTOP_FILE
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

# Call the function
create_app_menu_item
