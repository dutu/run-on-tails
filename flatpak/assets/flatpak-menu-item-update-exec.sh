#!/bin/bash

# Script description:
# This script updates the Exec command in a Flatpak application's .desktop file, given the application's ID as parameter.
# The process is as follows:
# 1. Checks if any Exec commands start with "flatpak" or "/usr/bin/flatpak", exits if not.
# 2. Checks the existence of the .desktop file in the persistent desktop directory, exits if not found.
# 3. If 'flatpak-run.sh' in the app's persistent directory exists, uses it. If not, creates it from a generic script.
# 4. Replaces the Exec command in [Desktop Entry] section with a new one to execute the 'flatpak-run.sh' script
# 5. Replaces the Exec command in remaining section with a new one to execute flatpak wrapped within "/bin/bash -c"

# Error codes
ERR_NO_ARGS=5
ERR_NOT_AMNESIA=6
ERR_RUN_SCRIPT_NOT_EXECUTABLE=1
ERR_GENERIC_RUN_SCRIPT_MISSING=2
ERR_NO_FLATPAK_COMMAND=3
ERR_NO_DESKTOP_FILE=4

# Flatpak application id is first argument
app_id="$1"

# Define the persistence directories and file paths
persistence_dir="/home/amnesia/Persistent"
dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
persistent_desktop_dir="$dotfiles_dir/.local/share/applications"
persistent_desktop_path="$persistent_desktop_dir/$app_id.desktop"

# Define the paths for necessary scripts
run_script_generic="$persistence_dir/flatpak/utils/flatpak-run-generic.sh"
run_script="$persistence_dir/$app_id/flatpak-run.sh"

# Function to check and create the flatpak run script if it does not exist
check_and_create_run_script() {
  # Check if $run_script exists
  if [ -f "$run_script" ]; then
    # Check if $run_script is executable
    if [ ! -x "$run_script" ]; then
      echo "Error: flatpak-run.sh exists but is not executable at $run_script. Exiting..."
      exit $ERR_RUN_SCRIPT_NOT_EXECUTABLE
    else
      # "flatpak-run.sh exists at $run_script and will be used to launch the $app_id."
      return
    fi
  else
    # Check if $run_script_generic exists
    if [[ ! -f "$run_script_generic" ]]; then
      echo "Error: Generic run script does not exist at $run_script_generic. Please reinstall flatpak utils. Exiting..."
      exit $ERR_GENERIC_RUN_SCRIPT_MISSING
    fi

    # Create the run_script based on run_script_generic.
    cp "$run_script_generic" "$run_script"
    chmod +x "$run_script"
  fi
}

# Function to update flatpak Exec command in "[Desktop Entry]" section
update_flatpak_exec_in_desktop_entry_section() {
  # Store the new Exec command
  pattern='^Exec=(flatpak|/usr/bin/flatpak)'
  new_exec_command="Exec=$run_script"

  # Replace the Exec command under [Desktop Entry]
  awk -v pattern="$pattern" -v exec_replacement="$new_exec_command" '
    /^\[Desktop Entry\]/ {in_section = 1}
    /^\[/ {if ($0 != "[Desktop Entry]") in_section = 0}
    in_section && match($0, pattern) {
      params = substr($0, RSTART + RLENGTH)
      $0 = exec_replacement params
    }
    {print}
  ' "$persistent_desktop_path" > temp_file

  # Check if the file has been modified
  if ! cmp -s "$persistent_desktop_path" temp_file; then
    mv temp_file "$persistent_desktop_path"
    echo "Replaced 'Exec=flatpak' with '$new_exec_command' in '[Desktop Entry]' section"
  else
    rm temp_file
  fi
}


# Function to update remaining flatpak Exec commands in other sections
update_flatpak_exec_in_other_sections() {
  # Store the new Exec command
  pattern='^Exec=(flatpak|/usr/bin/flatpak)'
  new_exec_command="Exec=/bin/bash -c \"command -v flatpak >/dev/null && flatpak"

  # Wrap Exec flatpak commands within '/bin/bash -c'. Takes into consideration potential placeholder (%f, %u, %d, etc.)
  awk -v pattern="$pattern" -v exec_replacement="$new_exec_command" -v placeholder_pattern='%(.)' -v placeholder_replacement='\\\\%\\1' '
    match($0, pattern) {
      params = substr($0, RSTART + RLENGTH)
      $0 = exec_replacement params "\""
      gsub(placeholder_pattern, placeholder_replacement)
    }
    {print}
  ' "$persistent_desktop_path" > temp_file

  # Check if the file has been modified
  if ! cmp -s "$persistent_desktop_path" temp_file; then
    mv temp_file "$persistent_desktop_path"
    echo "Replaced 'Exec=flatpak' with '$new_exec_command\"' in other sections."
  else
    rm temp_file
  fi
}


# Check for command-line arguments
if [ $# -eq 0 ]; then
  echo "No arguments supplied. Please provide a flatpak application ID."
  exit $ERR_NO_ARGS
fi

# Check the running user
if test "$(whoami)" != "amnesia"; then
  echo "You must run this program as 'amnesia' user."
  exit $ERR_NOT_AMNESIA
fi

if [[ ! -f $persistent_desktop_path ]]; then
  echo "Error: .desktop file does not exist at the following path: $persistent_desktop_path. Exiting..."
  exit $ERR_NO_DESKTOP_FILE
fi

if ! grep -qE "$pattern" "$persistent_desktop_path"; then
  echo "Error: No Exec entry starting with 'flatpak' or '/usr/bin/flatpak' found. Nothing to update. Exiting..."
  exit $ERR_NO_FLATPAK_COMMAND
fi

# Call the function to check and create the flatpak run script if it does not exist
check_and_create_run_script
# Call the functions to update Exec command
update_flatpak_exec_in_desktop_entry_section
update_flatpak_exec_in_other_sections
