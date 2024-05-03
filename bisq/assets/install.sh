#!/bin/bash

# This script automates the installation and configuration of Bisq on a Tails OS system,
#
# FUNCTIONAL OVERVIEW:
# - Verification of the Bisq installer's presence.
# - Installation of the Bisq application with dpkg.
# - Removal of automatically created desktop icons to clean up after installation.
# - Deployment of Tor configuration for Bisq.
# - Restart of the onion-grater service to apply new configurations.
#
# The script requires administrative privileges to perform system modifications.


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

# Define version and file locations
VERSION="1.9.15"
persistence_dir="/home/amnesia/Persistent"
bisq_installer="${persistence_dir}/bisq/Bisq-64bit-${VERSION}.deb"

# Check if the Bisq installer exists
if [ ! -f "${bisq_installer}" ]; then
  echo_red "Bisq installer not found at ${bisq_installer}."
  exit 1
fi

# Install Bisq
echo_blue "Installing Bisq..."
dpkg -i "${bisq_installer}" || { echo_red "Failed to install Bisq."; exit 1; }
# Remove installed desktop menu icon
rm -f /usr/share/applications/bisq-Bisq.desktop

# Change access rights for Tor control cookie
echo_blue "Changing access rights for Tor control cookie..."
chmod o+r /var/run/tor/control.authcookie || { echo_red "Failed to change access rights for Tor control cookie."; exit 1; }

# Assume bisq.yml is in the same directory as the script
BISQ_CONFIG_FILE="$(dirname "$0")/bisq.yml"

# Copy bisq.yml configuration file
echo_blue "Copying Tor onion-grater configuration to /etc/onion-grater.d/..."
cp "${BISQ_CONFIG_FILE}" /etc/onion-grater.d/bisq.yml || { echo_red "Failed to copy bisq.yml."; exit 1; }

# Restart onion-grater service
echo_blue "Restarting onion-grater service..."
systemctl restart onion-grater.service || { echo_red "Failed to restart onion-grater service."; exit 1; }

echo_blue "Bisq installation and configuration complete."
