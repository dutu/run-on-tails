#!/bin/bash

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
