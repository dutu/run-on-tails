#!/bin/bash

# This script check the status of flatpak installation.
# If flatpak is installed exit code is 0, otherwise a dialogue is displayed and exit code is none-zero.

# File containing the list of additional software packages
additional_software_file="/live/persistence/TailsData_unlocked/live-additional-software.conf"

# Function to display notification message and exit with specified code
display_dialog_and_exit() {
  local level="$1"
  local title="$2"
  local message="$3"
  local exit_code="$4"
  notify-send -u critical -i "dialog-${level}" "${level^}: ${title}" "${message}"
  exit "$exit_code"
}

# Check if 'flatpak' command is available
if command -v flatpak >/dev/null 2>&1; then
  exit 0
fi

# Check dpkg.log for flatpak installation completed message
if grep -q "status installed flatpak" /var/log/dpkg.log; then
  display_dialog_and_exit "error" "flatpak installation is not detected" "Please reinstall flatpak and configure to install every time after reboot." 2
fi

# Check dpkg.log for flatpak installation start message
if grep -q "install flatpak" /var/log/dpkg.log; then
  display_dialog_and_exit "warning" "flatpak installation is in progress" "Please wait a few minutes and try again." 1
fi

# Check if flatpak is in the additional software list
if ! grep -q "^flatpak$" "$additional_software_file"; then
  display_dialog_and_exit  "error" "flatpak is not installed" "Please install flatpak and configure it to install every time after reboot." 2
fi

# Check journalctl for additional software installation start message
if journalctl | grep -q "Installing your additional software"; then
  display_dialog_and_exit "warning" "flatpak installation is pending" "Please wait a few minutes and try again." 1
fi

display_dialog_and_exit "error" "flatpak is not installed" "Please reinstall flatpak and configure it to install every time after reboot." 2
