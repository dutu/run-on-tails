#!/bin/bash

# Function to print messages in blue
echo_blue() {
  echo -e "\033[0;34m$1\033[0m"
}

# Function to print error messages in red
echo_red() {
  echo -e "\033[0;31m$1\033[0m"
}

dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
persistence_dir="/home/amnesia/Persistent"
assets_dir=$(dirname "$0")/assets

echo_blue "Creating persistent directory for Flatpak..."
mkdir -p $persistence_dir/flatpak || { echo_red "Failed to create directory $persistence_dir/flatpak"; exit 1; }

# Copy utility files to persistent storage and make scripts executable
echo_blue "Copying flatpak utility files to persistent storage..."
rsync -av assets_dir/ $persistence_dir/flatpak/utils/ || { echo_red "Failed to rsync files to $persistence_dir/flatpak/utils"; exit 1; }
find $persistence_dir/flatpak/utils -type f -name "*.sh" -exec chmod +x {} \; || { echo_red "Failed to make scripts executable"; exit 1; }

# Execute scripts for setting up persistent Flatpak apps and make it autostart
echo_blue "Setting up persistent Flatpak apps and configuring autostart..."
$persistence_dir/flatpak/utils/flatpak-setup-persistent-apps.sh || { echo_red "Failed to execute setup script for persistent Flatpak apps"; exit 1; }
rsync -a $persistence_dir/flatpak/utils/flatpak-setup-persistent-apps.sh $dotfiles_dir/.config/autostart/amnesia.d/ || { echo_red "Failed to rsync the script to autostart directory"; exit 1; }

# Add Flatpak repository
echo_blue "Adding Flatpak repository..."
torsocks flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || { echo_red "Failed to add Flatpak repository"; exit 1; }

echo_blue "Flatpak installation setup completed successfully."
