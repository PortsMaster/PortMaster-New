#!/usr/bin/env python3
"""
File Fetcher for ROCKNIX
Enhanced version with interactive features
"""
import os
import sys

def show_rom_collection():
    """Show current file collection"""
    rom_base = "/storage/roms"
    
    print("📦 Current File Collection:")
    print("=" * 30)
    
    consoles_found = []
    total_files = 0
    
    if os.path.exists(rom_base):
        for item in os.listdir(rom_base):
            path = os.path.join(rom_base, item)
            if os.path.isdir(path) and item != "ports":
                try:
                    roms = [f for f in os.listdir(path) if f.endswith(('.zip', '.7z', '.rom', '.iso', '.bin', '.cue', '.p8.png'))]
                    if roms:
                        consoles_found.append((item, len(roms)))
                        total_roms += len(roms)
                except:
                    continue
    
    if consoles_found:
        for console, count in sorted(consoles_found):
            print(f"   • {console}: {count} file(s)")
        print(f"\nTotal: {total_roms} files")
    else:
        print("   No files found")
    print()

def show_supported_consoles():
    """Show supported consoles for download"""
    consoles = [
        "Game Boy", "Game Boy Color", "Game Boy Advance",
        "NES", "SNES", "Genesis", "Game Gear", 
        "Master System", "Saturn", "Dreamcast",
        "PlayStation 1", "PSP", "Nintendo DS", 
        "Nintendo 64", "Famicom Disk System",
        "PC Engine - TurboGrafx-16"
    ]
    
    print("🎮 Supported Consoles for Download:")
    print("=" * 35)
    for i, console in enumerate(consoles, 1):
        print(f"{i:2d}. {console}")
    print()

def main():
    print("File Downloader for ROCKNIX")
    print("=" * 40)
    print()
    
    show_rom_collection()
    show_supported_consoles()
    
    print("💡 How to Download Files:")
    print("   1. Choose a console number (1-16)")
    print("   2. Browse available files")
    print("   3. Select files to download")
    print("   4. Files saved to /storage/roms/[console]/")
    print()
    
    print("📡 Network Status:")
    print("   Device: 192.168.0.159")
    print("   Source: GitHub (file repository)")
    print()
    
    print("For full interactive downloading, use the complete File Downloader system.")

if __name__ == "__main__":
    main()
