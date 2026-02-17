#!/bin/bash
# Bridge script for capture.py - handles UI interaction
# Similar to download_bridge.sh in fetcher

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

ACTION="$1"
PARAM1="$2"
PARAM2="$3"

case "$ACTION" in
    platforms)
        # Return available capture modes
        python3 capture.py platforms
        ;;

    screenshot)
        # Take a screenshot
        python3 capture.py screenshot ${PARAM1:+-o "$PARAM1"}
        ;;

    record)
        # Record video
        # PARAM1 = duration, PARAM2 = fps
        DURATION=${PARAM1:-10}
        FPS=${PARAM2:-10}
        python3 capture.py record -d "$DURATION" -f "$FPS"
        ;;

    progress)
        # Return current progress (for UI polling)
        if [ -f /tmp/capture_progress.json ]; then
            cat /tmp/capture_progress.json
        else
            echo '{"status": "idle", "percent": 0}'
        fi
        ;;

    *)
        echo "Usage: $0 {platforms|screenshot|record|progress}"
        echo ""
        echo "Commands:"
        echo "  platforms              - List available capture modes"
        echo "  screenshot [output]    - Take a screenshot"
        echo "  record [duration] [fps] - Record video (default: 10s at 10fps)"
        echo "  progress               - Get current operation progress"
        exit 1
        ;;
esac
