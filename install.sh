#!/bin/bash
# Optional install script for autostart and no password requirement
set -e

POLICY_SRC="data/polkit/com.batapp.battery.limit.policy"
RULES_SRC="data/polkit/90-battery-limit.rules"

POLICY_DEST="/usr/share/polkit-1/actions/com.batapp.battery.limit.policy"
RULES_DEST="/etc/polkit-1/rules.d/90-battery-limit.rules"

echo "Installing PolicyKit files for battery-limit-applet..."

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo: sudo ./install.sh"
  exit 1
fi

# Install PolicyKit files
install -Dm644 "$POLICY_SRC" "$POLICY_DEST"
install -Dm644 "$RULES_SRC" "$RULES_DEST"

echo "Installed:"
echo "  $POLICY_DEST"
echo "  $RULES_DEST"

# Create 'power' group if missing
if ! getent group power > /dev/null; then
  echo "Creating group 'power'..."
  groupadd power
else
  echo "ℹGroup 'power' already exists."
fi

# Add current user to 'power'
if id "$SUDO_USER" | grep -q "power"; then
  echo "User '$SUDO_USER' is already in 'power' group."
else
  usermod -aG power "$SUDO_USER"
  echo "Added user '$SUDO_USER' to 'power' group."
  echo "You may need to log out and back in for group changes to take effect."
fi

# Restart Polkit
echo "Restarting polkit service..."
systemctl restart polkit

# Install program files
echo "Installing files, configuring autostart"

APP_DIR="/opt/battery-limit-applet"
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
AUTOSTART_DIR="$USER_HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/battery-limit-applet.desktop"

mkdir -p "$APP_DIR"

install -Dm755 battery-limit-applet.py "$APP_DIR/battery-limit-applet.py"
install -Dm755 launcher.sh "$APP_DIR/launcher.sh"

sudo -u "$SUDO_USER" mkdir -p "$AUTOSTART_DIR"
sudo -u "$SUDO_USER" tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Battery Limit Applet
Exec=/opt/battery-limit-applet/launcher.sh
Icon=battery
Comment=Tray applet to set battery charge thresholds
X-GNOME-Autostart-enabled=true
EOF

echo "Battery Limit Applet installed successfully."
echo "It will start automatically on next login."
