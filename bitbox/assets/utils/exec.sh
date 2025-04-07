#!/bin/bash

# This script serves as the execution entry point for the BitBoxApp application from a desktop menu icon,
# specifically tailored for use in the Tails OS. It is intended to be linked as the 'Exec' command
# in a .desktop file, enabling users to start BitBoxApp directly from the desktop interface.
#
# FUNCTIONAL OVERVIEW:
# - Checks if udev rules needed for the HW wallet devices have been applied already.
#   If not, it applies the rules by copying them to /etc/udev/rules.d/ and notifying udevadm.
# - Starts BitBoxApp from AppImage
#
# NOTE:
# This script assumes that BitBoxApp related configuration and files are correctly placed and accessible
# in the specified directories.

# Function to print messages in blue
echo_blue() {
  if [ -t 1 ]; then
    # If File descriptor 1 (stdout) is open and refers to a terminal
    echo -e "\033[1;34m$1\033[0m"
  else
    # If stdout is not a terminal, send a desktop notification
    notify-send -i "${persistence_dir}/bitbox/utils/icon.png" "Starting BitBoxApp..." "$1"
  fi
}

# Function to print error messages in red
echo_red() {
  if [ -t 1 ]; then
    # If File descriptor 1 (stdout) is open and refers to a terminal
    echo -e "\033[0;31m$1\033[0m"
  else
    # If stdout is not a terminal, send a desktop notification
    notify-send -u critical -i "error" "Staring BitBoxApp" "$1\nExiting..."
  fi
}

# Define the persistence directory
persistence_dir="/home/amnesia/Persistent"

# Function to apply udev rules needed for the HW wallet devices to be usable
function apply_udev_rules {
 local rules_src="${persistence_dir}/bitbox/udev/"  # Directory containing .rules files
  local rules_dest="/etc/udev/rules.d/"

  # Copy the rules file to /etc/udev/rules.d/
  if ! rsync -a ${rules_src}*.rules "${rules_dest}"; then
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
rules_file="/etc/udev/rules.d/51-hid-digitalbitbox.rules"
if [ ! -e "$rules_file" ]; then
  # If not, run 'apply_udev_rules' function with superuser privileges
  echo_blue "Setting up udev rules for the HW wallet devices..."
  if ! pkexec bash -c "persistence_dir=$persistence_dir; $(declare -f apply_udev_rules); apply_udev_rules"; then
    echo_red "Failed to set up udev rules. Ensure you enter the admin password correctly."
    exit 1
  fi
fi

# create link to persistent configuration
# workaround from https://github.com/BitBoxSwiss/bitbox-wallet-app/issues/3131#issuecomment-2605634039
persistent_conf_dir="${persistence_dir}/bitbox/conf"
local_conf_dir="/home/amnesia/.config/bitbox"
if [ ! -d "${persistent_conf_dir}" ]; then
  mkdir -p "${persistent_conf_dir}" || { echo_red "Failed to create directory ${persistent_conf_dir}"; exit 1; }
fi
if [ ! -L "${local_conf_dir}" ]; then
  ln -s "${persistent_conf_dir}" "${local_conf_dir}" || { echo_red "Failed to create symbolic link for ${local_conf_dir}"; exit 1; }
fi

echo_blue "Starting BitBoxApp..."
# Get the BitBoxApp AppImage file path
bitbox_AppImage=$(find ${persistence_dir}/bitbox/*.AppImage | tail -n 1)
# Check if BitBoxApp AppImage is found
if [[ -z "$bitbox_AppImage" ]]; then
  echo_red "BitBoxApp AppImage not found in the persistence directory."
  exit 1
fi

# Attempt to start BitBoxApp AppImage
if ! ${bitbox_AppImage} "$@"; then
  echo_red "Failed to start BitBoxApp."
  exit 1
fi
