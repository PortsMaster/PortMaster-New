#!/usr/bin/env python3
"""
ROM Index Builder for ROCKNIX
Scans /storage/roms and outputs platform + file lists with caching.
"""
import json
import os
import sys
import time

ROMS_DIR = "/storage/roms"
CACHE_DIR = "/tmp/file_cache"
CACHE_FILE = os.path.join(CACHE_DIR, "rom_index.json")
CACHE_EXPIRY = 6 * 3600  # 6 hours

# Platform mapping (folder -> display name)
FOLDER_TO_PLATFORM = {
    "gb": "Game Boy",
    "gbc": "Game Boy Color",
    "gba": "Game Boy Advance",
    "nes": "NES",
    "fds": "Famicom Disk System",
    "snes": "SNES",
    "gamegear": "Game Gear",
    "mastersystem": "Master System",
    "genesis": "Genesis",
    "saturn": "Saturn",
    "dreamcast": "Dreamcast",
    "psx": "PlayStation 1",
    "psp": "PSP",
    "nds": "Nintendo DS",
    "n64": "Nintendo 64",
    "pcengine": "PC Engine",
}

EXTENSIONS = (
    ".zip", ".7z", ".rom", ".iso", ".bin", ".cue", ".chd", ".p8.png"
)


def ensure_cache_dir():
    if not os.path.exists(CACHE_DIR):
        os.makedirs(CACHE_DIR, exist_ok=True)


def is_cache_valid(path, expiry):
    if not os.path.exists(path):
        return False
    return (time.time() - os.path.getmtime(path)) < expiry


def clean_display_name(filename):
    lower = filename.lower()
    if lower.endswith(".p8.png"):
        return filename[:-7]
    for ext in EXTENSIONS:
        if lower.endswith(ext):
            return filename[: -len(ext)]
    return filename


def scan_roms():
    platforms = []
    files_by_folder = {}

    if not os.path.exists(ROMS_DIR):
        return {"platforms": [], "files": {}}

    for entry in sorted(os.listdir(ROMS_DIR)):
        if entry == "ports" or entry.startswith("."):
            continue
        folder_path = os.path.join(ROMS_DIR, entry)
        if not os.path.isdir(folder_path):
            continue

        display_name = FOLDER_TO_PLATFORM.get(entry, entry)
        files = []

        try:
            for item in sorted(os.listdir(folder_path)):
                item_path = os.path.join(folder_path, item)
                if not os.path.isfile(item_path):
                    continue

                item_lower = item.lower()
                if not item_lower.endswith(EXTENSIONS):
                    continue

                files.append({
                    "name": clean_display_name(item),
                    "filename": item,
                })
        except OSError:
            continue

        if len(files) == 0:
            continue

        files_by_folder[entry] = files
        platforms.append({
            "name": display_name,
            "folder": entry,
            "count": len(files),
        })

    return {"platforms": platforms, "files": files_by_folder}


def build_index():
    ensure_cache_dir()
    data = scan_roms()
    data["generated"] = int(time.time())
    with open(CACHE_FILE, "w") as f:
        json.dump(data, f)
    return data


def load_index(force_refresh=False):
    if not force_refresh and is_cache_valid(CACHE_FILE, CACHE_EXPIRY):
        try:
            with open(CACHE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return build_index()


def find_platform_folder(index_data, platform_name):
    for platform in index_data.get("platforms", []):
        if platform.get("name") == platform_name:
            return platform.get("folder")
    return None


def main():
    args = sys.argv[1:]
    force_refresh = "--refresh" in args

    if "--platforms" in args:
        index_data = load_index(force_refresh)
        print(json.dumps({"platforms": index_data.get("platforms", [])}, indent=2))
        return

    if "--files" in args:
        try:
            platform_name = args[args.index("--files") + 1]
        except (ValueError, IndexError):
            print(json.dumps({"error": "Missing platform name"}, indent=2))
            return

        index_data = load_index(force_refresh)
        folder = find_platform_folder(index_data, platform_name)
        if not folder:
            print(json.dumps({"platform": platform_name, "count": 0, "files": []}, indent=2))
            return

        files = index_data.get("files", {}).get(folder, [])
        print(json.dumps({"platform": platform_name, "count": len(files), "files": files}, indent=2))
        return

    # Default: full index
    index_data = load_index(force_refresh)
    print(json.dumps(index_data, indent=2))


if __name__ == "__main__":
    main()
