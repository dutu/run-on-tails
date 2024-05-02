#!/bin/bash

persistence_dir="/home/amnesia/Persistent"
base_dir="${persistence_dir}/bisq}"
data_dir="${base_dir}/Bisq"

# Check if Bisq is already installed and configured
if [ ! -f "/opt/bisq/bin/Bisq" ] || [ ! -f "/etc/onion-grater.d/bisq.yml" ]; then
  echo_blue "Installing Bisq and/or configuring system..."
  pkexec ./install.sh
else
  echo_blue "Bisq is already installed and configured."
fi

ln -s $data_dir /home/amnesia/.local/share/Bisq
/opt/bisq/bin/Bisq --torControlPort 951 --torControlCookieFile=/var/run/tor/control.authcookie --torControlUseSafeCookieAuth
