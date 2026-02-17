#!/usr/bin/env python3
"""
ROCKNIX Screenshot/Recording Hotkey Daemon
Monitors gamepad for right stick click to capture screenshots or video
Runs as background service during gameplay

Usage:
  Start screenshot mode: python3 hotkey_daemon.py start screenshot
  Start record mode:     python3 hotkey_daemon.py start record 10
  Stop:                  python3 hotkey_daemon.py stop
  Status:                python3 hotkey_daemon.py status
"""
import os
import sys
import struct
import time
import signal
import subprocess
import json
from datetime import datetime

# Configuration
GAMEPAD_DEVICE = "/dev/input/event3"
SCREENSHOT_DIR = "/storage/roms/screenshots"
RECORDING_DIR = "/storage/roms/recordings"
CAPTURE_SCRIPT = "/storage/roms/ports/amos_capture/capture.py"
PID_FILE = "/tmp/capture_hotkey.pid"
CONFIG_FILE = "/tmp/capture_hotkey.conf"
LOG_FILE = "/tmp/capture_hotkey.log"

# Button codes for H700 Gamepad (from evtest)
BTN_SELECT = 314  # KEY_SELECT
BTN_START = 315   # KEY_START
BTN_THUMBR = 318    # BTN_THUMBR (Right Plus button)
BTN_L1 = 310      # BTN_TL (L1/LB)

# Input event structure: time_sec, time_usec, type, code, value
EVENT_FORMAT = 'llHHi'
EVENT_SIZE = struct.calcsize(EVENT_FORMAT)

# Event types
EV_KEY = 0x01


class HotkeyDaemon:
    def __init__(self, capture_mode='screenshot', record_duration=10):
        self.running = False
        self.buttons_pressed = set()
        self.last_capture_time = 0
        self.capture_cooldown = 2.0  # Minimum seconds between captures
        self.capture_mode = capture_mode  # 'screenshot' or 'record'
        self.record_duration = record_duration

    def log(self, message):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_line = f"[{timestamp}] {message}\n"
        try:
            with open(LOG_FILE, 'a') as f:
                f.write(log_line)
        except:
            pass
        print(log_line.strip())

    def do_capture(self):
        """Trigger capture based on mode"""
        current_time = time.time()

        # For recording, use longer cooldown
        cooldown = self.record_duration + 5 if self.capture_mode == 'record' else self.capture_cooldown

        if current_time - self.last_capture_time < cooldown:
            self.log("Capture cooldown active, skipping")
            return

        self.last_capture_time = current_time

        if self.capture_mode == 'screenshot':
            self.log("Hotkey triggered! Capturing screenshot...")
            cmd = ['python3', CAPTURE_SCRIPT, 'screenshot']
            timeout = 10
        else:
            # Use 5fps for faster processing (APNG creation is slow)
            fps = 5
            self.log(f"Hotkey triggered! Recording {self.record_duration}s video at {fps}fps...")
            cmd = ['python3', CAPTURE_SCRIPT, 'record', '-d', str(self.record_duration), '-f', str(fps)]
            # APNG creation takes ~2s per frame, so timeout = duration + frames*2 + buffer
            timeout = self.record_duration + (self.record_duration * fps * 2) + 30

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=os.path.dirname(CAPTURE_SCRIPT)
            )

            if result.returncode == 0:
                self.log(f"Capture complete: {result.stdout.strip()}")
            else:
                self.log(f"Capture failed: {result.stderr}")

        except subprocess.TimeoutExpired:
            self.log("Capture timed out")
        except Exception as e:
            self.log(f"Capture error: {e}")

    def check_hotkey(self):
        """Check if hotkey is pressed (Right Plus button)"""
        return BTN_THUMBR in self.buttons_pressed

    def handle_signal(self, signum, frame):
        """Handle shutdown signals"""
        self.log("Received shutdown signal")
        self.running = False

    def run(self):
        """Main daemon loop"""
        self.running = True
        signal.signal(signal.SIGTERM, self.handle_signal)
        signal.signal(signal.SIGINT, self.handle_signal)

        # Write PID file
        with open(PID_FILE, 'w') as f:
            f.write(str(os.getpid()))

        # Write config file
        with open(CONFIG_FILE, 'w') as f:
            json.dump({
                'mode': self.capture_mode,
                'duration': self.record_duration
            }, f)

        self.log(f"Hotkey daemon started (PID: {os.getpid()})")
        self.log(f"Mode: {self.capture_mode}" + (f" ({self.record_duration}s)" if self.capture_mode == 'record' else ""))
        self.log(f"Listening on: {GAMEPAD_DEVICE}")
        self.log("Hotkey: Right Plus button")

        # Ensure output directories exist
        os.makedirs(SCREENSHOT_DIR, exist_ok=True)
        os.makedirs(RECORDING_DIR, exist_ok=True)

        hotkey_was_pressed = False

        try:
            with open(GAMEPAD_DEVICE, 'rb') as gamepad:
                while self.running:
                    try:
                        event_data = gamepad.read(EVENT_SIZE)
                        if not event_data:
                            continue

                        _, _, ev_type, code, value = struct.unpack(EVENT_FORMAT, event_data)

                        # Only process key events
                        if ev_type != EV_KEY:
                            continue

                        # Track button state
                        if value == 1:  # Button pressed
                            self.buttons_pressed.add(code)
                        elif value == 0:  # Button released
                            self.buttons_pressed.discard(code)

                        # Check hotkey button
                        hotkey_pressed = self.check_hotkey()

                        # Trigger on press (not release)
                        if hotkey_pressed and not hotkey_was_pressed:
                            self.do_capture()

                        hotkey_was_pressed = hotkey_pressed

                    except IOError as e:
                        self.log(f"Read error: {e}")
                        time.sleep(1)

        except FileNotFoundError:
            self.log(f"Gamepad not found: {GAMEPAD_DEVICE}")
        except PermissionError:
            self.log(f"Permission denied: {GAMEPAD_DEVICE}")
        except Exception as e:
            self.log(f"Error: {e}")
        finally:
            self.cleanup()

    def cleanup(self):
        """Clean up on exit"""
        try:
            os.remove(PID_FILE)
        except:
            pass
        try:
            os.remove(CONFIG_FILE)
        except:
            pass
        self.log("Hotkey daemon stopped")


def get_pid():
    """Get running daemon PID"""
    try:
        with open(PID_FILE, 'r') as f:
            return int(f.read().strip())
    except:
        return None


def is_running():
    """Check if daemon is running"""
    pid = get_pid()
    if pid is None:
        return False
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def start_daemon(capture_mode='screenshot', record_duration=10):
    """Start the daemon in background"""
    if is_running():
        print("Daemon already running, stop it first")
        return

    # Fork to background
    if os.fork() > 0:
        print("Hotkey daemon starting...")
        time.sleep(0.5)
        if is_running():
            print(f"Daemon started (PID: {get_pid()})")
            if capture_mode == 'screenshot':
                print("Mode: Screenshot")
            else:
                print(f"Mode: Record {record_duration}s")
            print("Hotkey: Right Plus button")
        return

    # Detach from terminal
    os.setsid()

    # Second fork
    if os.fork() > 0:
        os._exit(0)

    # Redirect standard file descriptors
    sys.stdin.close()
    sys.stdout = open(LOG_FILE, 'a')
    sys.stderr = sys.stdout

    # Run daemon
    daemon = HotkeyDaemon(capture_mode, record_duration)
    daemon.run()


def stop_daemon():
    """Stop the running daemon"""
    pid = get_pid()
    if pid is None:
        print("Daemon not running")
        return

    try:
        os.kill(pid, signal.SIGTERM)
        print(f"Stopping daemon (PID: {pid})...")

        # Wait for process to exit
        for _ in range(10):
            time.sleep(0.5)
            if not is_running():
                print("Daemon stopped")
                return

        # Force kill if still running
        os.kill(pid, signal.SIGKILL)
        print("Daemon force killed")
    except OSError as e:
        print(f"Error stopping daemon: {e}")


def show_status():
    """Show daemon status"""
    if is_running():
        pid = get_pid()
        print(f"Hotkey daemon is running (PID: {pid})")

        # Show current mode
        try:
            with open(CONFIG_FILE, 'r') as f:
                config = json.load(f)
                mode = config.get('mode', 'screenshot')
                duration = config.get('duration', 10)
                if mode == 'screenshot':
                    print("Mode: Screenshot")
                else:
                    print(f"Mode: Record {duration}s")
        except:
            pass

        print(f"Log file: {LOG_FILE}")

        # Show recent log entries
        try:
            with open(LOG_FILE, 'r') as f:
                lines = f.readlines()
                if lines:
                    print("\nRecent log entries:")
                    for line in lines[-5:]:
                        print(f"  {line.strip()}")
        except:
            pass
    else:
        print("Hotkey daemon is not running")


def main():
    if len(sys.argv) < 2:
        print("Usage: hotkey_daemon.py [start|stop|status|run] [mode] [duration]")
        print("  start screenshot     - Start in screenshot mode")
        print("  start record 10      - Start in record mode (10 seconds)")
        print("  stop                 - Stop running daemon")
        print("  status               - Show daemon status")
        print("  run                  - Run in foreground (for testing)")
        sys.exit(1)

    command = sys.argv[1].lower()

    if command == 'start':
        # Parse mode and duration
        capture_mode = 'screenshot'
        record_duration = 10

        if len(sys.argv) >= 3:
            mode_arg = sys.argv[2].lower()
            if mode_arg in ['screenshot', 'ss', 's']:
                capture_mode = 'screenshot'
            elif mode_arg in ['record', 'rec', 'r', 'video', 'v']:
                capture_mode = 'record'
                if len(sys.argv) >= 4:
                    try:
                        record_duration = int(sys.argv[3])
                    except ValueError:
                        pass

        start_daemon(capture_mode, record_duration)
    elif command == 'stop':
        stop_daemon()
    elif command == 'status':
        show_status()
    elif command == 'run':
        capture_mode = 'screenshot'
        record_duration = 10
        if len(sys.argv) >= 3:
            if sys.argv[2].lower() in ['record', 'rec', 'r']:
                capture_mode = 'record'
                if len(sys.argv) >= 4:
                    record_duration = int(sys.argv[3])
        daemon = HotkeyDaemon(capture_mode, record_duration)
        daemon.run()
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == '__main__':
    main()
