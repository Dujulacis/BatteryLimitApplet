#!/bin/bash

# Uninstall script
set -e

if [ -z "$SUDO_USER" ]; then
    USERNAME="$USER"
else
    USERNAME="$SUDO_USER"
fi

USER_HOME="$(getent passwd "$USERNAME" | cut -d: -f6 || echo "$HOME")"
APP_DIR="$USER_HOME/.local/share/battery-limit-applet"
SERVICE_FILE="$USER_HOME/.config/systemd/user/battery-limit-applet.service"
POLKIT_RULE="/usr/share/polkit-1/rules.d/90-battery-limit.rules"

echo "Uninstalling Battery Limit Applet..."

systemctl --user stop battery-limit-applet.service || true
systemctl --user disable battery-limit-applet.service || true
systemctl --user daemon-reload

sudo rm -f "$SERVICE_FILE"
sudo rm -rf "$APP_DIR"
sudo rm -f "$POLKIT_RULE"

sudo gpasswd -d "$SUDO_USER" battery || true
sudo groupdel battery || true

echo "Polkit rule removed."

echo "Uninstallation complete."
echo "You may need to log out and back in for group changes to take effect."
