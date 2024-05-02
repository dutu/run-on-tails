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


# Define version and file locations
VERSION="1.9.15"
url_base="https://github.com/bisq-network/bisq/releases/download/v${VERSION}"
binary_filename="Bisq-64bit-${VERSION}.deb"
signature_filename="${binary_filename}.asc"
key_filename="E222AA02.asc"
expected_fingerprint="B493 3191 06CC 3D1F 252E  19CB F806 F422 E222 AA02"

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

# Extract the fingerprint from GPG output
imported_fingerprint=$(gpg --with-colons --fingerprint | grep -A 1 'pub' | grep 'fpr' | cut -d: -f10)

# Remove spaces from the expected fingerprint for comparison
formatted_expected_fingerprint=$(echo "$expected_fingerprint" | tr -d ' ')

if [[ "$imported_fingerprint" != "$formatted_expected_fingerprint" ]]; then
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
