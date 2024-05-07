#!/bin/bash

# This script serves as the execution entry point for the Electrum application from a desktop menu icon,
# specifically tailored for use in the Tails OS. It is intended to be linked as the 'Exec' command
# in a .desktop file, enabling users to start Electrum directly from the desktop interface.
#
# FUNCTIONAL OVERVIEW:
# - Checks if udev rules needed for the HW wallet devices have been applied already.
#   If not, it applies the rules by copying them to /etc/udev/rules.d/ and notifying udevadm.
# - Starts Electrum from AppImage
#
# NOTE:
# This script assumes that Electrum related configuration and files are correctly placed and accessible
# in the specified directories.

# Function to print messages in blue
echo_blue() {
  if [ -t 1 ]; then
    # If File descriptor 1 (stdout) is open and refers to a terminal
    echo -e "\033[1;34m$1\033[0m"
  else
    # If stdout is not a terminal, send a desktop notification
    notify-send -i "${persistence_dir}/electrum/utils/icon.png" "Starting Electrum..." "$1"
  fi
}

# Function to print error messages in red
echo_red() {
  if [ -t 1 ]; then
    # If File descriptor 1 (stdout) is open and refers to a terminal
    echo -e "\033[0;31m$1\033[0m"
  else
    # If stdout is not a terminal, send a desktop notification
    notify-send -u critical -i "error" "Staring Electrum" "$1\nExiting..."
  fi
}

# Define the persistence directory
persistence_dir="/home/amnesia/Persistent"

# Function to apply udev rules needed for the HW wallet devices to be usable
function apply_udev_rules {
  local rules_src="${persistence_dir}/electrum/udev/*.rules"
  local rules_dest="/etc/udev/rules.d/"

  # Copy the rules file to /etc/udev/rules.d/
  if ! rsync -a "${rules_src}" "${rules_dest}"; then
    echo_red "Failed to copy udev rules."
    return 1  # Return failure status
  fi

  # Reload rules and trigger udev
  if ! udevadm control --reload-rules || ! udevadm trigger; then
    echo_red "Failed to reload or trigger udev rules."
    return 1  # Return failure status
  fi

  return 0  # Return success status
}

# Check if udev rules needed for the HW wallet devices have been applied already
rules_file="/etc/udev/rules.d/51-coinkite.rules"
if [ ! -e "$rules_file" ]; then
  # If not, run 'apply_udev_rules' function with superuser privileges
  echo_blue "Setting up udev rules for the HW wallet devices..."
  if ! pkexec bash -c "persistence_dir=$persistence_dir; $(declare -f apply_udev_rules); apply_udev_rules"; then
    echo_red "Failed to set up udev rules. Ensure you enter the admin password correctly."
    exit 1
  fi
fi

echo_blue "Starting Electrum..."
# Get the electrum AppImage file path
electrum_AppImage=$(find ${persistence_dir}/electrum/*.AppImage | tail -n 1)
# Check if Electrum AppImage is found
if [[ -z "$electrum_AppImage" ]]; then
  echo_red "Electrum AppImage not found in the persistence directory."
  exit 1
fi

# Attempt to start Electrum AppImage
if ! ${electrum_AppImage} "$@"; then
  echo_red "Failed to start Electrum."
  exit 1
fi
