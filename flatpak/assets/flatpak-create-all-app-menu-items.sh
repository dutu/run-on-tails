#!/bin/bash

# This script automatically creates menu items for all installed Flatpak applications.
# If the Flatpak package is already installed, menu creation is immediate.
# Otherwise, the script starts monitoring for the Flatpak installation, triggering menu creation upon its completion.
# Monitoring Flatpak installations times out after a given duration

# Define the timeout value
timeout_duration='5m'

# Logs a message to the terminal or the system log, depending on context
log() {
  if [ -t 1 ]; then
    # If File descriptor 1 (stdout) is open and refers to a terminal
    echo "$1"
  else
    # If stdout is not a terminal (maybe it's a pipe, a file, or /dev/null)
    logger "$1"
  fi
}

create_all_app_menu_items() {
  # Get a list of all installed flatpak applications
  flatpak_list=$(flatpak list --columns=application)
  # Iterate over each item in the flatpak list
  for app in $flatpak_list; do
    # Check if the app name is not empty
    if [[ -n "$app" ]]; then
      # Extract the app id from the app string
      app_id=$(echo "$app" | awk -F'/' '{print $NF}')
      # Call the create-flatpak-app-menu-item.sh script for each app_id
      ./create-flatpak-app-menu-item.sh "$app_id"
    fi
  done
  exit 0
}

# Check if flatpak is already installed
if command -v flatpak >/dev/null 2>&1; then
  log 'Flatpak package is installed. Creating app menu items...'
  create_all_app_menu_items
fi

# Start monitoring dpkg.log to determine completion of flakpak installation
# The `timeout` command allows the script to exit if the specified duration is reached.
# The `tail -F` command outputs the end of the dpkg.log file and watches it for new content.
timeout "$timeout_duration" tail -F /var/log/dpkg.log | while read -r line; do
  if echo "$line" | grep -q 'status installed flatpak'; then
    log "$line"
    # Kills the `tail` process that is a child of the current script process ($$).
    # This effectively stops the monitoring of dpkg.log when flatpak is detected as installed.
    pkill -P $$ tail
  fi
done

if [ $? -eq 124 ]; then
  # Timeout occurred
  log 'Timeout occurred while waiting for "status installed flatpak"'
fi

# Check if flatpak has been installed
if ! command -v flatpak >/dev/null 2>&1; then
  log 'Flatpak installation did not complete'
  exit 1
fi

log 'Flatpak installation completed. Creating app menu items...'
create_all_app_menu_items
