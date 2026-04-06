#!/bin/bash

INSTALLFILE="/usr/local/bin/Vencord/VencordInstallerCli-linux"
RESTART_DISCORD=0

# This ↓ is hardcoded to my user because it caused trouble ($HOME resolving to "/root" as the home of root for example)
run_as_felix(){
  sudo -u felix "$@"
}

# If Discord is running, kill it and wait 2 seconds for it to fully close
if run_as_felix killall -s 9 Discord; then
    RESTART_DISCORD=1
    sleep 2
fi

# Download installer if it does not exist or is not executable
if [ ! -x "$INSTALLFILE" ]; then
    echo "Downloading Installer..."
    run_as_felix mkdir -p "$(dirname "$INSTALLFILE")"
    curl -sS https://github.com/Vendicated/VencordInstaller/releases/latest/download/VencordInstallerCli-Linux \
        --output "$INSTALLFILE" \
        --location
    chmod +x "$INSTALLFILE"
fi

# Execute the installer
if [ "$EUID" -eq 0 ]; then
    SUDO_USER=felix "$INSTALLFILE" -branch stable -repair
else
    sudo "$INSTALLFILE" -branch stable -repair
fi

# Restarting Discord if it was running before is difficult because of how Discord behaves
#if [ "$RESTART_DISCORD" -eq 1 ]; then
#    echo "Restarting Discord..."
#    run_as_felix discord &
#fi
