#!/bin/bash

# Function to print messages in blue
echo_blue() {
  echo -e "\033[1;34m$1\033[0m"
}

# Function to print error messages in red
echo_red() {
  echo -e "\033[0;31m$1\033[0m"
}

# Define file locations
persistence_dir="/home/amnesia/Persistent"
data_dir="${persistence_dir}/bisq/Bisq"

# Check if Bisq is already installed and configured
if [ ! -f "/opt/bisq/bin/Bisq" ] || [ ! -f "/etc/onion-grater.d/bisq.yml" ]; then
  echo_blue "Installing Bisq and configuring system..."
  pkexec "${persistence_dir}/bisq/utils/install.sh"
  # Redirect user data to Tails Persistent Storage
  ln -s $data_dir /home/amnesia/.local/share/Bisq
else
  echo_blue "Bisq is already installed and configured."
fi

echo_blue "Starting Bisq..."
/opt/bisq/bin/Bisq --torControlPort 951 --torControlCookieFile=/var/run/tor/control.authcookie --torControlUseSafeCookieAuth
