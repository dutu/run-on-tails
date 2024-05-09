#!/bin/bash

# This script automates the setup and verification of Electrum on a Tails OS system
#
# FUNCTIONAL OVERVIEW:
# - Retrieval of the latest Electrum version information from GitHub.
# - Validation of the retrieved version to ensure it meets the expected format.
# - Download and verification of Electrum AppImage and source package using GPG signatures.
# - Installation and configuration of desktop icons and menu entries for Electrum.
# - Preparation and configuration of persistent storage directories for Electrum files.
# - Extraction and setup of udev rules necessary for hardware wallet devices.
#

# Function to print messages in blue
echo_blue() {
  echo -e "\033[1;34m$1\033[0m"
}

# Function to print error messages in red
echo_red() {
  echo -e "\033[0;31m$1\033[0m"
}

# Define version and file locations
VERSION=$(wget -qO- https://api.github.com/repos/spesmilo/electrum/tags | grep -Po '"name": "\K.*?(?=")' | grep -P '^\d+\.\d+\.\d+$' | sort -V | tail -n 1)
# Validate the VERSION variable
if [[ -z "$VERSION" || ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo_red "Error: VERSION = $VERSION is empty or does not match the expected format 'd.d.d'."
  exit 1
fi
url_base="https://download.electrum.org/${VERSION}"
appimage_filename="electrum-${VERSION}-x86_64.AppImage"
appimage_signature_filename="${appimage_filename}.asc"
package_filename="Electrum-${VERSION}.tar.gz"
package_signature_filename="${package_filename}.asc"
key_url_base="https://raw.githubusercontent.com/spesmilo/electrum/master/pubkeys"
key_filename="ThomasV.asc"
expected_fingerprint="6694 D8DE 7BE8 EE56 31BE  D950 2BD5 824B 7F94 70E6"
persistence_dir="/home/amnesia/Persistent"
dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
persistent_desktop_dir="$dotfiles_dir/.local/share/applications"
local_desktop_dir="/home/amnesia/.local/share/applications"

echo_blue "Creating persistent directory for Electrum..."
mkdir -p "${persistence_dir}/electrum" || echo_red "Failed to create directory $persistence_dir/electrum"
# Copy utility files to persistent storage and make scripts executable
echo_blue "Copying Electrum utility files to persistent storage..."
assets_dir=$(dirname "$0")/assets
rsync -av "${assets_dir}/" "${persistence_dir}/electrum/utils/" || echo_red "Failed to rsync files to $persistence_dir/electrum/utils"
find "${persistence_dir}/electrum/utils" -type f -name "*.sh" -exec chmod +x {} \; || echo_red "Failed to make scripts executable"

# Download and import GPG key
echo_blue "Downloading and importing signing GPG key..."
curl -L -o "${key_filename}" "${key_url_base}/${key_filename}" || echo_red "Failed to download GPG key."
gpg --import "${key_filename}" || echo_red "Failed to import GPG key."

# Validate the GPG key fingerprint
imported_fingerprints=$(gpg --with-colons --fingerprint | grep -A 1 'pub' | grep 'fpr' | cut -d: -f10 | tr -d '\n')
formatted_expected_fingerprint=$(echo "$expected_fingerprint" | tr -d ' ')
# Check if the expected fingerprint is in the list of imported fingerprints
if [[ ! "$imported_fingerprints" =~ $formatted_expected_fingerprint ]]; then
  echo_red "The imported GPG key fingerprint does not match the expected fingerprint."
  exit 1
fi

echo_blue "The imported GPG key fingerprint matches the expected fingerprint."

# Download, verify, and move Electrum AppImage
echo_blue "Downloading and verifying Electrum AppImage..."
curl -L -o "${appimage_filename}" "${url_base}/${appimage_filename}" || echo_red "Failed to download Electrum AppImage."
curl -L -o "${appimage_signature_filename}" "${url_base}/${appimage_signature_filename}" || echo_red "Failed to download Electrum signature."
OUTPUT=$(gpg --verify "${appimage_signature_filename}" "${appimage_filename}" 2>&1)
if ! echo "$OUTPUT" | grep -q "Good signature from"; then
  echo_red "Verification failed: $OUTPUT"
  exit 1
fi
mkdir -p "${persistence_dir}/electrum"
mv "${appimage_filename}" "${appimage_signature_filename}" "${persistence_dir}/electrum/"
chmod +x "${persistence_dir}/electrum/${appimage_filename}"

echo_blue "Electrum AppImage has been successfully verified."
echo_blue "Files moved to persistent directory ${persistence_dir}/electrum/"

# Download, verify, and move Electrum AppImage
echo_blue "Downloading and verifying Electrum source package..."
curl -L -o "${package_filename}" "${url_base}/${package_filename}" || echo_red "Failed to download Electrum source package."
curl -L -o "${package_signature_filename}" "${url_base}/${package_signature_filename}" || echo_red "Failed to download Electrum signature."
OUTPUT=$(gpg --verify "${package_signature_filename}" "${package_filename}" 2>&1)
if ! echo "$OUTPUT" | grep -q "Good signature from"; then
  echo_red "Verification failed: $OUTPUT"
  exit 1
fi

echo_blue "Electrum source package has been successfully verified."

echo_blue "Extracting and copying udev rules for the HW wallet devices..."
tar -xzf "${package_filename}"
rm -fr "${persistence_dir}/electrum/udev"
rsync -av "Electrum-${VERSION}/contrib/udev/" "${persistence_dir}/electrum/udev/"

echo_blue "Creating desktop menu icon..."
# Create desktop directories
mkdir -p "${local_desktop_dir}" "${persistent_desktop_dir}"
# Create desktop menu icon
persistent_desktop_file="${dotfiles_dir}/.local/share/applications/electrum.desktop"
cp "Electrum-${VERSION}/electrum.desktop" ${persistent_desktop_file}
cp "Electrum-${VERSION}/electrum/gui/icons/electrum.png" $persistence_dir/electrum/
# Update `Icon` entry of the .desktop file to point to Electrum icon file
desktop-file-edit --set-icon="$persistence_dir/electrum/electrum.png" ${persistent_desktop_file}
# Update `Exec` entry of the .desktop file to run `exec.sh`
sed -i "s|Exec=electrum \(.*\)|Exec=$persistence_dir/electrum/utils/exec.sh \1|" $persistent_desktop_file
# Make the menu item visible in "Applications ▸ Other"
desktop-file-edit --remove-category="Network" $persistent_desktop_file
# Create a symbolic link to it in the local .desktop directory, if it doesn't exist
if [ ! -L "$local_desktop_dir/electrum.desktop" ]; then
  ln -s "$persistent_desktop_dir/electrum.desktop" "$local_desktop_dir/electrum.desktop" || { echo_red "Failed to create symbolic link for .desktop file"; exit 1; }
fi

echo_blue "Electrum installation setup completed successfully."
