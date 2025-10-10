#!/bin/bash
# Uninstall script
set -e

POLICY_DEST="/usr/share/polkit-1/actions/com.batapp.battery.limit.policy"
RULES_DEST="/etc/polkit-1/rules.d/90-battery-limit.rules"

echo "Uninstalling PolicyKit files for battery-limit-applet..."

# Require root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo: sudo ./uninstall.sh"
  exit 1
fi

# Remove installed PolicyKit files
if [ -f "$POLICY_DEST" ]; then
  rm -f "$POLICY_DEST"
  echo "Removed $POLICY_DEST"
fi

if [ -f "$RULES_DEST" ]; then
  rm -f "$RULES_DEST"
  echo "Removed $RULES_DEST"
fi

# Optionally remove the 'power' group
if getent group power > /dev/null; then
  read -p "Do you want to remove the 'power' group? (y/N): " choice
  case "$choice" in
    [Yy]* )
      groupdel power
      echo "Removed 'power' group."
      ;;
    * )
      echo "Keeping 'power' group."
      ;;
  esac
fi

# Restart Polkit to apply changes
echo "Restarting polkit service..."
systemctl restart polkit

APP_DIR="/opt/battery-limit-applet"
AUTOSTART_FILE="$HOME/.config/autostart/battery-limit-applet.desktop"

# Remove files
echo "Removing files"
rm -rf "$APP_DIR"
sudo -u "$SUDO_USER" rm -f "$AUTOSTART_FILE" 2>/dev/null || true

echo "Uninstallation complete."
echo "You may need to log out and back in for group changes to take effect."
