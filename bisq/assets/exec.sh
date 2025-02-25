#!/bin/bash

# This script serves as the execution entry point for the Bisq application from a desktop menu icon,
# specifically tailored for use in the Tails OS. It is intended to be linked as the 'Exec' command
# in a .desktop file, enabling users to start Bisq directly from the desktop interface.
#
# FUNCTIONAL OVERVIEW:
# - Automatic installation and configuration of Bisq if not already set up.
# - Linking Bisq data directories to persistent storage to preserve user data across sessions.
#
# NOTE:
# This script assumes that Bisq's related utility scripts and files are correctly placed and accessible
# in the specified directories.

# Function to print messages in blue
echo_blue() {
  if [ -t 1 ]; then
    # If File descriptor 1 (stdout) is open and refers to a terminal
    echo -e "\033[1;34m$1\033[0m"
  else
    # If stdout is not a terminal, send a desktop notification
    notify-send -i "/home/amnesia/Persistent/bisq/utils/icon.png" "Starting Bisq" "$1"
  fi
}

# Function to print error messages in red
echo_red() {
  if [ -t 1 ]; then
    # If File descriptor 1 (stdout) is open and refers to a terminal
    echo -e "\033[0;31m$1\033[0m"
  else
    # If stdout is not a terminal, send a desktop notification
    notify-send -u critical -i "error" "Staring Bisq" "$1\nExiting..."
  fi
}

# Define file locations
persistence_dir="/home/amnesia/Persistent"
bisq_dir="${persistence_dir}/bisq"
data_dir="${persistence_dir}/bisq/Bisq"

# Find the highest version available
VERSION=$(ls "${bisq_dir}"/Bisq-64bit-*.deb 2>/dev/null | sed -E 's|.*/Bisq-64bit-([0-9]+\.[0-9]+\.[0-9]+)\.deb|\1|' | sort -V | tail -n 1)
bisq_installer="${bisq_dir}/Bisq-64bit-${VERSION}.deb"

# Check if the Bisq installer exists
if [ ! -f "${bisq_installer}" ]; then
  echo_red "Bisq installer not found at ${bisq_installer}."
  exit 1
fi

# Check if Bisq is already installed and its version
installed_version=$(dpkg-query -W -f='${Version}' bisq 2>/dev/null | cut -d'-' -f1)

# Check if installation or configuration is required
if [ ! -f "/opt/bisq/bin/Bisq" ] || [ ! -f "/etc/onion-grater.d/bisq.yml" ] || [ "$installed_version" != "$VERSION" ]; then
  echo_blue "Installing Bisq and configuring system..."
  pkexec "${persistence_dir}/bisq/utils/install.sh"
  # Redirect user data to Tails Persistent Storage
  ln -s $data_dir /home/amnesia/.local/share/Bisq
else
  echo_blue "Bisq v${VERSION} is already installed and correctly configured."
fi

echo_blue "Starting Bisq..."
/opt/bisq/bin/Bisq --torControlPort 951 --torControlCookieFile=/var/run/tor/control.authcookie --torControlUseSafeCookieAuth
