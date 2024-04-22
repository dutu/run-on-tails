#!/bin/bash

# This script is designed to execute the 'flatpak' command along with any parameters passed to this script.
# Firstly, the verifies the availability of the Flatpak package. If not available, it terminates.
# The script provides a designated section where users can insert additional commands or settings to be configured before launching the Flatpak application (e.g., setting a proxy server).

# Define the persistence directories and file paths
persistence_dir="/home/amnesia/Persistent"

# Logs a message to the terminal or the system log, depending on context.
# The first argument is the type of message ("info"|"warning"|"error"|"question"), the second argument is the actual message to log.
log() {
  if [ -t 1 ]; then
    # If stdout is a terminal, simply echo the message type and the message
    echo "${1^}: $2"
  else
    # If stdout is not a terminal, send a desktop notification
    notify-send -u critical -i "dialog-${1}" "${1^}: $2"
  fi
}

# Run the flatpak-installation-check.sh script and capture the exit code
$persistence_dir/flatpak/utils/flatpak-installation-check.sh
exit_code=$?

# If the exit code is not 0, exit with the same code
if [ $exit_code -ne 0 ]; then
  log "error" "Flatpak installation check failed with exit code: $exit_code. Exiting..."
  exit $exit_code
fi

### START: Insert pre-launch commands or configurations here.
### For instance, to set up a proxy server or perform any pre-launch configurations.

### END: Pre-launch customization.

# Executes 'flatpak' command with all parameters passed to this script
notify-send -u normal "Starting: flatpak $*"
flatpak "$@"