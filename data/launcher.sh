#!/bin/bash

# Launcher script for Battery Limit Applet

APP_DIR="$HOME/.local/share/battery-limit-applet"
LOG_DIR="$APP_DIR/logs"
LOG_FILE="$LOG_DIR/battery-limit-applet.log"

mkdir -p "$LOG_DIR"

sleep 2
exec python3 "$APP_DIR/battery-limit-applet.py" >> "$LOG_FILE" 2>&1
