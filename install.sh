#!/bin/bash

# Install script with optional password-less threshold management
set -e

if [ -z "$SUDO_USER" ]; then
    USERNAME="$USER"
else
    USERNAME="$SUDO_USER"
fi

# Directories
USER_HOME="$(getent passwd "$USERNAME" | cut -d: -f6 || echo "$HOME")"
SRC_DIR="$(pwd)"
APP_DIR="$USER_HOME/.local/share/battery-limit-applet"

RULES_SRC="$SRC_DIR/data/polkit/90-battery-limit.rules"
RULES_DEST="/usr/share/polkit-1/rules.d"

SERVICE_DIR="$USER_HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/battery-limit-applet.service"


# Install program files
echo "Installing Battery Limit Applet for $USERNAME"

mkdir -p "$APP_DIR" "$SERVICE_DIR"

cp "$SRC_DIR/battery-limit-applet.py" "$APP_DIR/"
cp "$SRC_DIR/launcher.sh" "$APP_DIR/"
cp "$SRC_DIR/uninstall.sh" "$APP_DIR/"


# Install polkit rule

echo "Installing Polkit rule..."
sudo mkdir -p "$RULES_DEST"
sudo cp "$RULES_SRC" "$RULES_DEST/"

sudo groupadd -f battery
sudo usermod -aG battery "$USERNAME"

echo "Polkit rule installed."


# Create systemd user service
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Battery Limit Applet
After=graphical-session.target

[Service]
ExecStart=%h/.local/share/battery-limit-applet/launcher.sh
Restart=on-failure
Environment=DISPLAY=:0
Environment=XDG_RUNTIME_DIR=/run/user/%U

[Install]
WantedBy=default.target
EOF


# Fix permissions in case
chown "$USERNAME:$USERNAME" "$SERVICE_FILE"
chmod +x "$APP_DIR/launcher.sh" "$APP_DIR/uninstall.sh"


# Reload, enable, and start service immediately
mkdir -p "$SERVICE_DIR/default.target.wants"
systemctl --user daemon-reload
systemctl --user enable battery-limit-applet.service
systemctl --user restart battery-limit-applet.service

echo "Battery Limit Applet installed successfully."
