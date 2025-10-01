#!/bin/bash

run_as_felix(){
  sudo -u felix "$@"
}
# this ↑ and that ↓ are hardcoded to my user because they caused trouble ($HOME resolving to "/root" as the home of root for example)
INSTALLFILE="/home/felix/Scripts/Vencord/VencordInstallerCli-linux"
DISCORD_PID=$(run_as_felix pgrep -x Discord -o)

# Check if Discord is running
if [ -n "$DISCORD_PID" ]; then
  echo "Discord is running. Killing the process..."
  run_as_felix kill "$DISCORD_PID"
  sleep 2  # Ensure Discord is fully closed
fi

# Download installer if not exists or not executable
if [ ! -x "$INSTALLFILE" ]; then
  echo "Downloading Installer..."
  run_as_felix curl -sS https://github.com/Vendicated/VencordInstaller/releases/latest/download/VencordInstallerCli-Linux \
    --output "$INSTALLFILE" \
    --location
  run_as_felix chmod +x "$INSTALLFILE"
fi

# Execute the installer
if [ "$EUID" -eq 0 ]; then
  SUDO_USER=felix "$INSTALLFILE" -branch stable -repair
else
  sudo "$INSTALLFILE" -branch stable -repair
fi

# Restart Discord if it was originally running
#if [ -n "$DISCORD_PID" ]; then
#  echo "Restarting Discord..."
#  discord &
#fi

