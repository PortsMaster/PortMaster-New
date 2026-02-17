#!/bin/bash
# Auto-start screenshot hotkey daemon on boot
# Place this in /storage/.config/autostart/ to run at boot

CAPTURE_DIR="/storage/roms/ports/amos_capture"

# Wait for system to be ready
sleep 5

# Start the hotkey daemon
python3 "$CAPTURE_DIR/hotkey_daemon.py" start

echo "Screenshot hotkey daemon started (SELECT + R1)"
