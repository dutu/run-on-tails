#!/bin/bash

# This script facilitates the setup and installation of the Bisq application on Tails OS.
#
# FUNCTIONAL OVERVIEW:
# - Creating necessary persistent directories and copying utility files.
# - Downloading Bisq binary, signature file, and GPG key for verification.
# - Importing and verifying the GPG key to ensure the authenticity of the download.
# - Setting up desktop icons in both local and persistent directories.

# Function to print messages in blue
echo_blue() {
  echo -e "\033[1;34m$1\033[0m"
}

# Function to print error messages in red
echo_red() {
  echo -e "\033[0;31m$1\033[0m"
}

# Define version and file locations
VERSION=$(wget -qO- https://api.github.com/repos/bisq-network/bisq/tags | grep -Po '"name": "v\K.*?(?=")' | grep -P '^\d+\.\d+\.\d+$' | sort -V | tail -n 1)

# Validate the VERSION variable
if [[ -z "$VERSION" || ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: VERSION = $VERSION is empty or does not match the expected format 'd.d.d'."
  exit 1
fi

url_base="https://github.com/bisq-network/bisq/releases/download/v${VERSION}"
binary_filename="Bisq-64bit-${VERSION}.deb"
signature_filename="${binary_filename}.asc"
key_filename="E222AA02.asc"
expected_fingerprint="B493 3191 06CC 3D1F 252E  19CB F806 F422 E222 AA02"
persistence_dir="/home/amnesia/Persistent"
dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
persistent_desktop_dir="$dotfiles_dir/.local/share/applications"
local_desktop_dir="/home/amnesia/.local/share/applications"

# Check if Bisq is already installed
# if [ -f "/opt/bisq/bin/Bisq" ]; then
#  echo_red "Bisq is already installed, please reboot Tails and run the script again..."
#  exit 1
# fi

echo_blue "Creating persistent directory for Bisq..."
mkdir -p $persistence_dir/bisq/Bisq || { echo_red "Failed to create directory $persistence_dir/bisq/Bisq"; exit 1; }

# Copy utility files to persistent storage and make scripts executable
echo_blue "Copying bisq utility files to persistent storage..."
assets_dir=$(dirname "$0")/assets
rsync -av $assets_dir/ $persistence_dir/bisq/utils/ || { echo_red "Failed to rsync files to $persistence_dir/bisq/utils"; exit 1; }
find $persistence_dir/bisq/utils -type f -name "*.sh" -exec chmod +x {} \; || { echo_red "Failed to make scripts executable"; exit 1; }

echo_blue "Creating desktop menu icon..."
# Create desktop directories
mkdir -p "${local_desktop_dir}"
mkdir -p "$persistent_desktop_dir"
# Copy .desktop file to persistent directory
cp "$assets_dir/bisq.desktop" "$persistent_desktop_dir"  || { echo_red "Failed to copy .desktop file to persistent directory $persistent_desktop_dir"; exit 1; }
# Create a symbolic link to it in the local .desktop directory, if it doesn't exist
if [ ! -L "$local_desktop_dir/bisq.desktop" ]; then
    ln -s "$persistent_desktop_dir/bisq.desktop" "$local_desktop_dir/bisq.desktop" || { echo_red "Failed to create symbolic link for .desktop file"; exit 1; }
fi


# Download Bisq binary
echo_blue "Downloading Bisq version ${VERSION}..."
curl -L -o "${binary_filename}" "${url_base}/${binary_filename}" || { echo_red "Failed to download Bisq binary."; exit 1; }

# Download Bisq signature file
echo_blue "Downloading Bisq signature..."
curl -L -o "${signature_filename}" "${url_base}/${signature_filename}" || { echo_red "Failed to download Bisq signature."; exit 1; }

# Download the GPG key
echo_blue "Downloading signing GPG key..."
curl -L -o "${key_filename}" "${url_base}/${key_filename}" || { echo_red "Failed to download GPG key."; exit 1; }

# Import the GPG key
echo_blue "Importing the GPG key..."
gpg --import "${key_filename}" || { echo_red "Failed to import GPG key."; exit 1; }

# Extract imported fingerprints
imported_fingerprints=$(gpg --with-colons --fingerprint | grep -A 1 'pub' | grep 'fpr' | cut -d: -f10 | tr -d '\n')

# Remove spaces from the expected fingerprint for comparison
formatted_expected_fingerprint=$(echo "$expected_fingerprint" | tr -d ' ')

# Check if the expected fingerprint is in the list of imported fingerprints
if [[ ! "$imported_fingerprints" =~ $formatted_expected_fingerprint ]]; then
  echo_red "The imported GPG key fingerprint does not match the expected fingerprint."
  exit 1
fi

# Verify the downloaded binary with the signature
echo_blue "Verifying the signature of the downloaded file..."
OUTPUT=$(gpg --digest-algo SHA256 --verify "${signature_filename}" "${binary_filename}" 2>&1)

if ! echo "$OUTPUT" | grep -q "Good signature from"; then
    echo_red "Verification failed: $OUTPUT"
    exit 1
fi

echo_blue "Bisq binaries have been successfully verified."

# Move the binary and its signature to the persistent directory
mkdir -p "${persistence_dir}/bisq"
# Delete old Bisq binaries
rm -f "${persistence_dir}/bisq/"*.deb*
mv "${binary_filename}" "${signature_filename}" "${persistence_dir}/bisq/"
echo_blue "Files moved to persistent directory ${persistence_dir}/bisq/"

echo_blue "Bisq installation setup completed successfully."
