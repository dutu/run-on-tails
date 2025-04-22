#!/bin/bash

# This script automates the setup and verification of BitBoxApp on a Tails OS system
#
# FUNCTIONAL OVERVIEW:
# - Retrieval of the latest BitBoxApp version information from GitHub.
# - Validation of the retrieved version to ensure it meets the expected format.
# - Download and verification of BitBox AppImage and source package using GPG signatures.
# - Installation and configuration of desktop icons and menu entries for BitBoxApp.
# - Preparation and configuration of persistent storage directories for BitBoxApp files.
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
VERSION=$(wget -qO- https://api.github.com/repos/BitBoxSwiss/bitbox-wallet-app/tags | grep -Po '"name": "\K.*?(?=")' | grep -P '^v\d+\.\d+\.\d+$' | sort -V | tail -n 1)
# Validate the VERSION variable
if [[ -z "$VERSION" || ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo_red "Error: VERSION = $VERSION is empty or does not match the expected format 'vd.d.d'."
  exit 1
else
  VERSION="${VERSION#v}"  # remove leading 'v'
fi
url_base="https://github.com/BitBoxSwiss/bitbox-wallet-app/releases/download/v${VERSION}"
appimage_filename="BitBox-${VERSION}-x86_64.AppImage"
appimage_signature_filename="${appimage_filename}.asc"
key_url_base="https://bitbox.swiss/download"
key_filename="shiftcryptosec-509249B068D215AE.gpg.asc"
expected_fingerprint="DD09 E413 0975 0EBF AE0D EF63 5092 49B0 68D2 15AE"
persistence_dir="/home/amnesia/Persistent"
dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
persistent_desktop_dir="${dotfiles_dir}/.local/share/applications"
local_desktop_dir="/home/amnesia/.local/share/applications"
assets_dir=$(dirname "$0")/assets

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

# Download, verify, and move BitBox AppImage
echo_blue "Downloading and verifying BitBox AppImage ${VERSION} ..."
curl -L -o "${appimage_filename}" "${url_base}/${appimage_filename}" || echo_red "Failed to download BitBox AppImage."
curl -L -o "${appimage_signature_filename}" "${url_base}/${appimage_signature_filename}" || echo_red "Failed to download BitBox signature."
OUTPUT=$(gpg --verify "${appimage_signature_filename}" "${appimage_filename}" 2>&1)
if ! echo "$OUTPUT" | grep -q "Good signature from"; then
  echo_red "Verification failed: $OUTPUT"
  exit 1
fi
echo_blue "BitBox AppImage has been successfully verified."

echo_blue "Creating persistent directory for BitBoxApp..."
mkdir -p "${persistence_dir}/bitbox/conf" || echo_red "Failed to create directory $persistence_dir/bitbox/conf"

# Copy utility files to persistent storage and make scripts executable
echo_blue "Copying BitBox asset files to persistent storage..."
rsync -av "${assets_dir}/" "${persistence_dir}/bitbox/" || echo_red "Failed to rsync files to $persistence_dir/bitbox"
find "${persistence_dir}/bitbox/utils" -type f -name "*.sh" -exec chmod +x {} \; || echo_red "Failed to make scripts executable"
mv "${appimage_filename}" "${appimage_signature_filename}" "${persistence_dir}/bitbox/"
chmod +x "${persistence_dir}/bitbox/${appimage_filename}"
echo_blue "Files moved to persistent directory ${persistence_dir}/bitbox/"

echo_blue "Creating desktop menu icon..."
# Create desktop directories
mkdir -p "${local_desktop_dir}" "${persistent_desktop_dir}"
# Copy .desktop file to persistent directory
mv "${persistence_dir}/bitbox/bitbox.desktop" "${persistent_desktop_dir}"  || { echo_red "Failed to move .desktop file to persistent directory ${persistent_desktop_dir}"; exit 1; }
# Create a symbolic link to it in the local .desktop directory, if it doesn't exist
if [ ! -L "${local_desktop_dir}/bitbox.desktop" ]; then
  ln -s "${persistent_desktop_dir}/bitbox.desktop" "${local_desktop_dir}/bitbox.desktop" || { echo_red "Failed to create symbolic link for .desktop file"; exit 1; }
fi

echo_blue "BitBoxApp v${VERSION} installation setup completed successfully."

