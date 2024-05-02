#!/bin/bash

# Function to print messages in blue
echo_blue() {
  echo -e "\033[0;34m$1\033[0m"
}

# Function to print error messages in red
echo_red() {
  echo -e "\033[0;31m$1\033[0m"
}

# Define common environment variables
VERSION="1.9.15"
persistence_dir="/home/amnesia/Persistent"
dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
persistent_desktop_dir="$dotfiles_dir/.local/share/applications"

# Check if Bisq is already installed
if [ -f "/opt/bisq/bin/Bisq" ]; then
  echo_red "Bisq is already installed, please reboot Tails..."
  exit 1
fi

echo_blue "Creating persistent directory for Bisq..."
mkdir -p $persistence_dir/bisq || { echo_red "Failed to create directory $persistence_dir/bisq"; exit 1; }

# Copy utility files to persistent storage and make scripts executable
echo_blue "Copying bisq utility files to persistent storage..."
assets_dir=$(dirname "$0")/assets
rsync -av $assets_dir/ $persistence_dir/bisq/utils/ || { echo_red "Failed to rsync files to $persistence_dir/bisq/utils"; exit 1; }
find $persistence_dir/bisq/utils -type f -name "*.sh" -exec chmod +x {} \; || { echo_red "Failed to make scripts executable"; exit 1; }


# Location and filenames for the download
url_base="https://bisq.network/downloads/v${VERSION}"
binary_name="Bisq-64bit-${VERSION}.deb"
signature_name="${binary_name}.asc"

# The public GPG key URL
gpg_key_url="https://bisq.network/pubkey/E222AA02.asc"

# Download Bisq binary
echo_blue "Downloading Bisq version ${VERSION}..."
wget -q "${url_base}/${binary_name}" || { echo_red "Failed to download Bisq binary."; exit 1; }

# Download Bisq signature file
echo_blue "Downloading the Bisq signature..."
wget -q "${url_base}/${signature_name}" || { echo_red "Failed to download Bisq signature."; exit 1; }

# Import the Bisq signing key
echo_blue "Importing the GPG key..."
wget -qO- "${gpg_key_url}" | gpg --import || { echo_red "Failed to import GPG key."; exit 1; }

# Verify the downloaded binary with the signature
echo_blue "Verifying the signature of the downloaded file..."
OUTPUT=$(gpg --digest-algo SHA256 --verify "${signature_name}" "${binary_name}" 2>&1)

if echo "$OUTPUT" | grep -q "Good signature from"; then
  echo_blue "Bisq has been successfully verified."
  # Move the binary and its signature to the persistent directory
  mkdir -p "${persistence_dir}/bisq"
  mv "${binary_name}" "${signature_name}" "${persistence_dir}/bisq/"
  echo_blue "Files moved to ${persistence_dir}/bisq/"
else
  echo_red "Signature verification failed. Please check the following output for details:"
  echo_red "$OUTPUT"
  exit 1
fi

echo_blue "Bisq installation setup completed successfully."
