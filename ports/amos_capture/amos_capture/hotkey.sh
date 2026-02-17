#!/bin/bash
# ROCKNIX Screenshot Hotkey Service
# Runs in background, press SELECT+R1 to capture screenshot

CAPTURE_DIR="/storage/roms/ports/amos_capture"
DAEMON="$CAPTURE_DIR/hotkey_daemon.py"

case "$1" in
    start)
        python3 "$DAEMON" start
        ;;
    stop)
        python3 "$DAEMON" stop
        ;;
    status)
        python3 "$DAEMON" status
        ;;
    restart)
        python3 "$DAEMON" stop
        sleep 1
        python3 "$DAEMON" start
        ;;
    *)
        echo "ROCKNIX Screenshot Hotkey"
        echo "Usage: $0 {start|stop|status|restart}"
        echo ""
        echo "Press SELECT + R1 anytime to capture screenshot"
        exit 1
        ;;
esac
