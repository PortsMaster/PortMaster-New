#!/usr/bin/env python3
"""
ROCKNIX Screen Capture - DRM PRIME dma-buf Screenshot & Recording
Works with Weston compositor on sun4i-drm (H700/Allwinner)

Dependencies: Python 3 standard library only (no external packages)
"""
import os
import fcntl
import mmap
import ctypes
import struct
import zlib
import sys
import time
import json
import argparse
from datetime import datetime

# Output directories
SCREENSHOT_DIR = "/storage/roms/screenshots"
RECORDING_DIR = "/storage/roms/recordings"
PROGRESS_FILE = "/tmp/capture_progress.json"

# DRM IOCTL definitions
DRM_IOCTL_BASE = ord('d')

def _IOWR(nr, size):
    return 0xC0000000 | (size << 16) | (DRM_IOCTL_BASE << 8) | nr

class drm_mode_crtc(ctypes.Structure):
    _fields_ = [
        ('set_connectors_ptr', ctypes.c_uint64),
        ('count_connectors', ctypes.c_uint32),
        ('crtc_id', ctypes.c_uint32),
        ('fb_id', ctypes.c_uint32),
        ('x', ctypes.c_uint32),
        ('y', ctypes.c_uint32),
        ('gamma_size', ctypes.c_uint32),
        ('mode_valid', ctypes.c_uint32),
        ('mode', ctypes.c_uint8 * 68),
    ]

class drm_mode_fb_cmd2(ctypes.Structure):
    _fields_ = [
        ('fb_id', ctypes.c_uint32),
        ('width', ctypes.c_uint32),
        ('height', ctypes.c_uint32),
        ('pixel_format', ctypes.c_uint32),
        ('flags', ctypes.c_uint32),
        ('handles', ctypes.c_uint32 * 4),
        ('pitches', ctypes.c_uint32 * 4),
        ('offsets', ctypes.c_uint32 * 4),
        ('modifier', ctypes.c_uint64 * 4),
    ]

class drm_prime_handle(ctypes.Structure):
    _fields_ = [
        ('handle', ctypes.c_uint32),
        ('flags', ctypes.c_uint32),
        ('fd', ctypes.c_int32),
    ]

DRM_IOCTL_MODE_GETCRTC = _IOWR(0xA1, ctypes.sizeof(drm_mode_crtc))
DRM_IOCTL_MODE_GETFB2 = _IOWR(0xCE, ctypes.sizeof(drm_mode_fb_cmd2))
DRM_IOCTL_PRIME_HANDLE_TO_FD = _IOWR(0x2d, ctypes.sizeof(drm_prime_handle))


class DRMCapture:
    """DRM framebuffer capture using PRIME dma-buf export"""

    def __init__(self):
        self.card_fd = None
        self.crtc = drm_mode_crtc()
        self.crtc_id = None
        self._init_drm()

    def _init_drm(self):
        """Initialize DRM device"""
        # Try card1 first (sun4i-drm on H700), then card0
        for card in ['/dev/dri/card1', '/dev/dri/card0']:
            try:
                self.card_fd = os.open(card, os.O_RDWR)
                break
            except OSError:
                continue

        if self.card_fd is None:
            raise RuntimeError("Could not open DRM device")

        # Find active CRTC
        for crtc_id in [36, 50, 41, 31, 71]:
            self.crtc.crtc_id = crtc_id
            try:
                fcntl.ioctl(self.card_fd, DRM_IOCTL_MODE_GETCRTC, self.crtc)
                if self.crtc.fb_id > 0:
                    self.crtc_id = crtc_id
                    break
            except OSError:
                continue

        if self.crtc_id is None:
            os.close(self.card_fd)
            raise RuntimeError("No active CRTC found")

    def capture_frame(self):
        """Capture current framebuffer and return raw BGR0 data with dimensions"""
        # Refresh CRTC to get current framebuffer (handles double-buffering)
        fcntl.ioctl(self.card_fd, DRM_IOCTL_MODE_GETCRTC, self.crtc)

        # Get framebuffer info
        fb = drm_mode_fb_cmd2()
        fb.fb_id = self.crtc.fb_id
        fcntl.ioctl(self.card_fd, DRM_IOCTL_MODE_GETFB2, fb)

        width = fb.width
        height = fb.height
        pitch = fb.pitches[0]

        # Export to dma-buf
        prime = drm_prime_handle()
        prime.handle = fb.handles[0]
        prime.flags = 0
        fcntl.ioctl(self.card_fd, DRM_IOCTL_PRIME_HANDLE_TO_FD, prime)

        # Read pixel data
        size = pitch * height
        mem = mmap.mmap(prime.fd, size, mmap.MAP_SHARED, mmap.PROT_READ)
        raw_data = mem.read(size)
        mem.close()
        os.close(prime.fd)

        return raw_data, width, height, pitch

    def close(self):
        """Close DRM device"""
        if self.card_fd is not None:
            os.close(self.card_fd)
            self.card_fd = None


def xbgr_to_rgb(raw_data, width, height, pitch):
    """Convert XBGR8888 to RGB for PNG"""
    rgb_data = bytearray()
    for y in range(height):
        rgb_data.append(0)  # PNG filter byte (none)
        for x in range(width):
            offset = y * pitch + x * 4
            x, b, g, r = raw_data[offset], raw_data[offset+1], raw_data[offset+2], raw_data[offset+3]
            rgb_data.extend([r, g, b])
    return rgb_data


def create_png(rgb_data, width, height):
    """Create PNG file from RGB data"""
    def png_chunk(chunk_type, data):
        chunk = chunk_type + data
        return struct.pack('>I', len(data)) + chunk + struct.pack('>I', zlib.crc32(chunk) & 0xffffffff)

    png = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    png += png_chunk(b'IHDR', ihdr)
    compressed = zlib.compress(bytes(rgb_data), 9)
    png += png_chunk(b'IDAT', compressed)
    png += png_chunk(b'IEND', b'')
    return png


def write_progress(status, percent=0, message="", extra=None):
    """Write progress to JSON file for UI"""
    progress = {
        "status": status,
        "percent": percent,
        "message": message,
        "timestamp": time.time()
    }
    if extra:
        progress.update(extra)

    try:
        with open(PROGRESS_FILE, 'w') as f:
            json.dump(progress, f)
            f.flush()
    except:
        pass


def take_screenshot(output_path=None):
    """Capture a single screenshot"""
    try:
        write_progress("capturing", 0, "Initializing DRM...")

        capture = DRMCapture()

        write_progress("capturing", 25, "Capturing framebuffer...")
        raw_data, width, height, pitch = capture.capture_frame()
        capture.close()

        write_progress("converting", 50, "Converting to PNG...")
        rgb_data = xbgr_to_rgb(raw_data, width, height, pitch)

        write_progress("converting", 75, "Compressing...")
        png_data = create_png(rgb_data, width, height)

        # Generate output path if not provided
        if output_path is None:
            os.makedirs(SCREENSHOT_DIR, exist_ok=True)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = os.path.join(SCREENSHOT_DIR, f"screenshot_{timestamp}.png")

        write_progress("saving", 90, "Saving file...")
        with open(output_path, 'wb') as f:
            f.write(png_data)

        file_size = len(png_data) / 1024  # KB

        result = {
            "status": "success",
            "file": output_path,
            "width": width,
            "height": height,
            "size_kb": round(file_size, 1)
        }

        write_progress("complete", 100, f"Screenshot saved: {output_path}", result)
        return result

    except Exception as e:
        error = {"status": "error", "error": str(e)}
        write_progress("error", 0, str(e), error)
        return error


def create_apng(frames_rgb, width, height, fps):
    """Create APNG (animated PNG) from list of RGB frames"""
    def png_chunk(chunk_type, data):
        chunk = chunk_type + data
        return struct.pack('>I', len(data)) + chunk + struct.pack('>I', zlib.crc32(chunk) & 0xffffffff)

    # Calculate delay (in 1/1000ths of a second)
    delay_num = 1000 // fps
    delay_den = 1000

    num_frames = len(frames_rgb)

    # PNG signature
    apng = b'\x89PNG\r\n\x1a\n'

    # IHDR chunk
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    apng += png_chunk(b'IHDR', ihdr)

    # acTL chunk (animation control) - must come before first IDAT
    actl = struct.pack('>II', num_frames, 0)  # num_frames, num_plays (0 = infinite)
    apng += png_chunk(b'acTL', actl)

    seq_num = 0

    for frame_idx, rgb_data in enumerate(frames_rgb):
        # Compress frame data
        compressed = zlib.compress(bytes(rgb_data), 6)

        # fcTL chunk (frame control)
        fctl = struct.pack('>IIIIIHHBB',
            seq_num,        # sequence_number
            width,          # width
            height,         # height
            0,              # x_offset
            0,              # y_offset
            delay_num,      # delay_num
            delay_den,      # delay_den
            0,              # dispose_op (0 = none)
            0               # blend_op (0 = source)
        )
        apng += png_chunk(b'fcTL', fctl)
        seq_num += 1

        if frame_idx == 0:
            # First frame uses IDAT
            apng += png_chunk(b'IDAT', compressed)
        else:
            # Subsequent frames use fdAT
            fdat = struct.pack('>I', seq_num) + compressed
            apng += png_chunk(b'fdAT', fdat)
            seq_num += 1

    # IEND chunk
    apng += png_chunk(b'IEND', b'')

    return apng


def record_video(duration=10, fps=10, output_path=None):
    """Record video - saves frames to folder, then encodes to APNG"""
    try:
        write_progress("initializing", 0, "Initializing recording...")

        capture = DRMCapture()

        total_frames = duration * fps
        frame_interval = 1.0 / fps

        # Create output folder for frames
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_dir = os.path.join(RECORDING_DIR, f"recording_{timestamp}")
        os.makedirs(output_dir, exist_ok=True)

        write_progress("recording", 0, f"Recording {duration}s at {fps}fps...")

        width = height = 0
        frame_paths = []
        frames_rgb = []  # Keep RGB data in memory for APNG encoding

        # Phase 1: Capture frames - save PNGs to folder AND keep RGB in memory
        for frame_num in range(total_frames):
            frame_start = time.time()

            # Capture frame
            raw_data, width, height, pitch = capture.capture_frame()

            # Convert to RGB
            rgb_data = xbgr_to_rgb(raw_data, width, height, pitch)

            # Keep RGB in memory for APNG encoding later
            frames_rgb.append(rgb_data)

            # Save as PNG to folder (visible to user during recording)
            png_data = create_png(rgb_data, width, height)
            frame_path = os.path.join(output_dir, f"frame_{frame_num:04d}.png")
            with open(frame_path, 'wb') as f:
                f.write(png_data)
            frame_paths.append(frame_path)

            # Update progress (0-50% for recording)
            percent = int((frame_num + 1) * 50 / total_frames)
            write_progress("recording", percent, f"Recording {frame_num + 1}/{total_frames}")

            # Maintain frame rate
            elapsed = time.time() - frame_start
            sleep_time = frame_interval - elapsed
            if sleep_time > 0:
                time.sleep(sleep_time)

        capture.close()

        # Phase 2: Encode to APNG using the RGB data kept in memory
        write_progress("encoding", 55, "Creating animated PNG...")

        apng_path = os.path.join(RECORDING_DIR, f"recording_{timestamp}.png")

        # Create APNG from in-memory RGB frames
        apng_data = create_apng(frames_rgb, width, height, fps)

        write_progress("encoding", 90, "Saving APNG...")

        with open(apng_path, 'wb') as f:
            f.write(apng_data)

        # Calculate file sizes
        frames_size = sum(os.path.getsize(f) for f in frame_paths) / (1024 * 1024)
        apng_size = len(apng_data) / (1024 * 1024)

        result = {
            "status": "success",
            "file": apng_path,
            "frames_folder": output_dir,
            "width": width,
            "height": height,
            "duration": duration,
            "fps": fps,
            "frames": total_frames,
            "apng_size_mb": round(apng_size, 2),
            "frames_size_mb": round(frames_size, 2)
        }

        write_progress("complete", 100, f"Recording saved: {apng_path}", result)
        return result

    except Exception as e:
        error = {"status": "error", "error": str(e)}
        write_progress("error", 0, str(e), error)
        return error


def get_platforms():
    """Return available capture modes (for UI compatibility)"""
    return {
        "platforms": [
            {"name": "Screenshot", "folder": "screenshots", "description": "Capture single screenshot (PNG)"},
            {"name": "Record 5s", "folder": "recordings", "description": "Record 5 seconds at 10fps"},
            {"name": "Record 10s", "folder": "recordings", "description": "Record 10 seconds at 10fps"},
            {"name": "Record 30s", "folder": "recordings", "description": "Record 30 seconds at 10fps"},
        ]
    }


def main():
    parser = argparse.ArgumentParser(description='ROCKNIX Screen Capture')
    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Screenshot command
    shot_parser = subparsers.add_parser('screenshot', help='Take a screenshot')
    shot_parser.add_argument('-o', '--output', help='Output file path')

    # Record command
    rec_parser = subparsers.add_parser('record', help='Record video')
    rec_parser.add_argument('-d', '--duration', type=int, default=10, help='Duration in seconds (default: 10)')
    rec_parser.add_argument('-f', '--fps', type=int, default=10, help='Frames per second (default: 10)')
    rec_parser.add_argument('-o', '--output', help='Output file path')

    # Platforms command (for fetcher UI compatibility)
    subparsers.add_parser('platforms', help='List available capture modes')

    args = parser.parse_args()

    if args.command == 'screenshot':
        result = take_screenshot(args.output)
    elif args.command == 'record':
        result = record_video(args.duration, args.fps, args.output)
    elif args.command == 'platforms':
        result = get_platforms()
    else:
        parser.print_help()
        sys.exit(1)

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
