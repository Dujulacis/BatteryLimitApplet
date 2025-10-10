#!/bin/bash
# Launcher script for Battery Limit Applet

APP_DIR="$HOME/.local/share/battery-limit-applet"
LOG_DIR="$APP_DIR/logs"

mkdir -p "$LOG_DIR"

# Delay to ensure session DBus is ready
sleep 5

# Run the Python applet
nohup python3 "$APP_DIR/battery-limit-applet.py" >> "$LOG_FILE" 2>&1 &
