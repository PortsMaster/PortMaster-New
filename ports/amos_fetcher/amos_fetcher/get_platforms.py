#!/usr/bin/env python3
"""
Export platform list from fetcher.py for Lua consumption
"""
import json
from fetcher import PLATFORM_URLS

def get_platform_list():
    """Convert PLATFORM_URLS to Lua-compatible format"""
    platforms = []
    
    # Platform name to folder mapping
    folder_mapping = {
        "pico-8": "pico-8",
        "Game Boy": "gb",
        "Game Boy Color": "gbc", 
        "Game Boy Advance": "gba",
        "NES": "nes",
        "Famicom Disk System": "fds",
        "SNES": "snes",
        "Game Gear": "gamegear",
        "Master System": "mastersystem",
        "Genesis": "genesis",
        "Saturn": "saturn",
        "Dreamcast": "dreamcast",
        "PlayStation 1": "psx",
        "PSP": "psp",
        "Nintendo DS": "nds",
        "Nintendo 64": "n64",
        "PC Engine": "pcengine"
    }
    
    for platform_name in PLATFORM_URLS.keys():
        folder = folder_mapping.get(platform_name, platform_name.lower().replace(" ", ""))
        platforms.append({
            "name": platform_name,
            "folder": folder
        })
    
    return {"platforms": platforms}

if __name__ == "__main__":
    result = get_platform_list()
    print(json.dumps(result, indent=2))
