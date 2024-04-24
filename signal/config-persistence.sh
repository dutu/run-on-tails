#!/bin/bash

# Function to print messages in blue
echo_blue() {
  echo -e "\033[0;34m$1\033[0m"
}

# Function to print error messages in red
echo_red() {
  echo -e "\033[0;31m$1\033[0m"
}

# Set variables
app_id="org.signal.Signal"
persistence_dir="/home/amnesia/Persistent"
dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"

# Create the application directory
echo_blue "Creating Signal application directory..."
mkdir -p $persistence_dir/$app_id || { echo_red "Failed to create directory $persistence_dir/$app_id"; exit 1; }

# Copy application .desktop file to persistent local directory
echo_blue "Copying application .desktop file..."
$persistence_dir/flatpak/utils/flatpak-menu-item-copy.sh $app_id || { echo_red "Failed to copy .desktop file"; exit 1; }

# Update Icon entry of the .desktop file
echo_blue "Updating .desktop file Icon entry..."
$persistence_dir/flatpak/utils/flatpak-menu-item-update-icon.sh $app_id || { echo_red "Failed to update Icon entry"; exit 1; }

# Update Exec entry of the .desktop file
echo_blue "Updating .desktop file Exec entry..."
$persistence_dir/flatpak/utils/flatpak-menu-item-update-exec.sh $app_id || { echo_red "Failed to update Exec entry"; exit 1; }

# Update .desktop file for compatibility with Tails OS
echo_blue "Updating .desktop file for Tails compatibility..."
persistent_desktop_file="$dotfiles_dir/.local/share/applications/$app_id.desktop"
desktop-file-edit --remove-key="SingleMainWindow" $persistent_desktop_file || { echo_red "Failed to remove SingleMainWindow key"; exit 1; }
desktop-file-edit --remove-category="Network" $persistent_desktop_file || { echo_red "Failed to remove Network category"; exit 1; }

# Force GNOME to recognize a change in the .desktop file
local_desktop_dir="/home/amnesia/.local/share/applications"
mv "$local_desktop_dir/$app_id.desktop" "$local_desktop_dir/$app_id.temp.desktop" || { echo_red "Failed to rename .desktop file"; exit 1; }
mv "$local_desktop_dir/$app_id.temp.desktop" "$local_desktop_dir/$app_id.desktop" || { echo_red "Failed to restore .desktop file name"; exit 1; }

# Insert proxy settings into flatpak-run.sh
echo_blue "Configuring proxy settings for Signal..."
flatpak_run_script="$persistence_dir/$app_id/flatpak-run.sh"
sed -i '/### START: Insert pre-launch commands or configurations here./a export HTTP_PROXY=socks://127.0.0.1:9050\nexport HTTPS_PROXY=socks://127.0.0.1:9050' "$flatpak_run_script" || { echo_red "Failed to insert proxy settings into $flatpak_run_script"; exit 1; }

echo_blue "Signal application setup completed successfully."
