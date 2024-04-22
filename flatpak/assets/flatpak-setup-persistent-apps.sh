#!/bin/sh

persistence_dir="/home/amnesia/Persistent"
install_dir="/home/amnesia/.local/share"
apps_data_dir="/home/amnesia/.var/app"

# Create the directory for flatpak software packages
mkdir -p $install_dir

# Link flatpak software packages location to persistent storage directory
if ! file $install_dir/flatpak | grep -q "symbolic link"; then
  rm -rf --one-file-system $install_dir/flatpak
  ln -s $persistence_dir/flatpak $install_dir/flatpak
fi

# Create the directory for user specific data of the apps
mkdir -p $apps_data_dir