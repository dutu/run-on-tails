#!/bin/bash

# Function to print messages in blue
echo_blue() {
  echo -e "\033[1;34m$1\033[0m"
}

# Function to print error messages in red
echo_red() {
  echo -e "\033[0;31m$1\033[0m"
}

# Define version and file locations
VERSION=$(wget -qO- https://api.github.com/repos/sparrowwallet/sparrow/tags | grep -Po '"name": "\K.*?(?=")' | grep -P '^\d+\.\d+\.\d+$' | sort -V | tail -n 1)
# Validate the VERSION variable
if [[ -z "$VERSION" || ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo_red "Error: VERSION = $VERSION is empty or does not match the expected format 'd.d.d'."
  exit 1
fi
url_base="https://github.com/sparrowwallet/sparrow/releases/download/${VERSION}"
tar_filename="sparrowwallet-${VERSION}-x86_64.tar.gz"
manifest_filename="sparrow-${VERSION}-manifest.txt"
manifest_signature_filename="sparrow-${VERSION}-manifest.txt.asc"
key_url_base="https://keybase.io/craigraw"
key_filename="pgp_keys.asc"
expected_fingerprint="D4D0 D320 2FC0 6849 A257 B38D E946 1833 4C67 4B40"
persistence_dir="/home/amnesia/Persistent"
dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
persistent_data_dir="$dotfiles_dir/.sparrow"
local_data_dir="/home/amnesia/.sparrow"
persistent_desktop_dir="$dotfiles_dir/.local/share/applications"
local_desktop_dir="/home/amnesia/.local/share/applications"

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

# Download, verify, and install Sparrow 
echo_blue "Downloading and verifying Sparrow .tar.gz package..."
curl -L -o "${tar_filename}" "${url_base}/${tar_filename}" || echo_red "Failed to download Sparrow .tar.gz package."
curl -L -o "${manifest_filename}" "${url_base}/${manifest_filename}" || echo_red "Failed to download Sparrow manifest file."
curl -L -o "${manifest_signature_filename}" "${url_base}/${manifest_signature_filename}" || echo_red "Failed to download Sparrow manifest signature."
OUTPUT=$(gpg --verify "${manifest_signature_filename}" "${manifest_filename}" 2>&1)
if ! echo "$OUTPUT" | grep -q "Good signature from"; then
  echo_red "Verification of manifest failed: $OUTPUT"
  exit 1
fi
OUTPUT=$(sha256sum --check "${manifest_filename}" --ignore-missing 2>&1)
if ! echo "$OUTPUT" | grep -q "${tar_filename}: OK"; then
  echo_red "Verification of checksum failed: $OUTPUT"
  exit 1
fi
echo_blue "Sparrow .tar.gz package has been successfully verified."

# clean old installation if exists
echo_blue "Installing Sparrow..."
rm -rf ${persistence_dir}/Sparrow
tar -xzf "${tar_filename}" -C "${persistence_dir}"

# Create data directories (.dotfiles)
echo_blue "Creating persistent data directory..."
mkdir -p "${persistent_data_dir}" || echo_red "Failed to create directory ${persistent_data_dir}"

# Create a symbolic link to persistent app directory, if it doesn't exist
if [ ! -L "$local_data_dir" ]; then
  ln -s "$persistent_data_dir" "$local_data_dir" \
    || { echo_red "Failed to create symbolic link for "$local_data_dir""; exit 1; }
fi

echo_blue "Creating desktop menu icon..."
# Create desktop directories
mkdir -p "${local_desktop_dir}" "${persistent_desktop_dir}"
# Copy .desktop file to persistent directory
assets_dir=$(dirname "$0")/assets
cp "$assets_dir/sparrow.desktop" "$persistent_desktop_dir"  || { echo_red "Failed to copy .desktop file to persistent directory $persistent_desktop_dir"; exit 1; }
# Create a symbolic link to it in the local .desktop directory, if it doesn't exist
if [ ! -L "$local_desktop_dir/sparrow.desktop" ]; then
  ln -s "$persistent_desktop_dir/sparrow.desktop" "$local_desktop_dir/sparrow.desktop" || { echo_red "Failed to create symbolic link for .desktop file"; exit 1; }
fi

echo_blue "Sparrow v${VERSION} installation setup completed successfully."

