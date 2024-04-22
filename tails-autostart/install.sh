#!/bin/bash

# Function to print messages in blue
echo_blue() {
  echo -e "\033[0;34m$1\033[0m"
}

# Function to print error messages in red
echo_red() {
  echo -e "\033[0;31m$1\033[0m"
}

# Navigate to the Downloads directory
echo_blue "Changing to the Downloads directory..."
cd ~/Downloads || { echo_red "Failed to change directory to ~/Downloads"; exit 1; }

# Download the tails-autostart files
echo_blue "Downloading Tails-autostart files..."
wget https://raw.githubusercontent.com/dutu/tails-autostart/master/assets/tails-autostart.tar.gz || { echo_red "Failed to download tails-autostart.tar.gz"; exit 1; }

# Unpack the downloaded tar.gz file
echo_blue "Unpacking Tails-autostart files..."
tar -xzvf tails-autostart.tar.gz || { echo_red "Failed to unpack tails-autostart.tar.gz"; exit 1; }

# Change the permissions to make the script executable
echo_blue "Setting execute permissions on installation script..."
chmod +x tails-autostart/install_tails_autostart.sh || { echo_red "Failed to make install script executable"; exit 1; }

# Run the installation script
echo_blue "Running the installation script..."
./tails-autostart/install_tails_autostart.sh || { echo_red "Failed to execute the installation script"; exit 1; }

echo_blue "Tails-autostart installation completed successfully."
