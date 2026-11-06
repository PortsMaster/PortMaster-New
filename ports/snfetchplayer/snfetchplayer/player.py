#!/usr/bin/env python3
"""
Station North SNfetchPLAYER - dArkOS Handheld Edition
Haupteinstiegspunkt:
Startet das interaktive Songo 5-Dashboard im Vollbild (1024x768 KMSDRM).
"""

import sys
from ui_dashboard import SNfetchDashboard

def main():
    dashboard = SNfetchDashboard()
    dashboard.run()

if __name__ == "__main__":
    main()
