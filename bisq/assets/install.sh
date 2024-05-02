#!/bin/bash

# Function to print messages in blue
echo_blue() {
  echo -e "\033[0;34m$1\033[0m"
}

# Function to print error messages in red
echo_red() {
  echo -e "\033[0;31m$1\033[0m"
}


persistence_dir="/home/amnesia/Persistent"
binary_name="Bisq-64bit-${VERSION}.deb"

# Check if variables are already set, otherwise default them
: ${VERSION:="1.9.15"}
: ${persistence_dir:="/home/amnesia/Persistent"}
: ${base_dir:=${persistence_dir}/bisq}
: ${bisq_installer:="${base_dir}/Bisq-64bit-${VERSION}.deb"}

# Check if the Bisq installer exists
if [ ! -f "${bisq_installer}" ]; then
  echo_red "Bisq installer not found at ${bisq_installer}."
  exit 1
fi

# Install Bisq
echo_blue "Installing Bisq..."
dpkg -i "${bisq_installer}" || { echo_red "Failed to install Bisq."; exit 1; }

# Change access rights for Tor control cookie
echo_blue "Changing access rights for Tor control cookie..."
chmod o+r /var/run/tor/control.authcookie || { echo_red "Failed to change access rights for Tor control cookie."; exit 1; }

# Assume bisq.yml is in the same directory as the script, or adjust the path accordingly
BISQ_CONFIG_FILE="$(dirname "$0")/bisq.yml"

# Copy bisq.yml configuration file
echo_blue "Copying bisq.yml to /etc/onion-grater.d/..."
cp "${BISQ_CONFIG_FILE}" /etc/onion-grater.d/bisq.yml || { echo_red "Failed to copy bisq.yml."; exit 1; }

# Restart onion-grater service
echo_blue "Restarting onion-grater service..."
systemctl restart onion-grater.service || { echo_red "Failed to restart onion-grater service."; exit 1; }

echo_blue "Bisq installation and configuration complete."
