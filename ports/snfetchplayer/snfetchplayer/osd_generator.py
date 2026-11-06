#!/usr/bin/env python3
"""
Station North SNfetchPLAYER - Authentic Nord TV OSD Generator
Renders the floating broadcast OSD for ffplay on 1024x768 (dArkOS / PortMaster).
- Appears ONLY on manual interaction (manual skip, pause, repeat toggle).
- When show_osd=False, renders an empty event list for 100% clean video playback.
- Uses official Nord color palette: Nord0 (Dark BG), Nord6 (Snow White), Nord8 (Ice Cyan).
"""

from pathlib import Path
from typing import Dict

# ASS Farbdefinitionen in &HAABBGGRR (Hex BGR mit Alpha):
COLOR_NORD0_BG      = "&H2240342E"  # #2E3440 (~87% opacity dark background)
COLOR_NORD1_PANEL   = "&H1552423B"  # #3B4252 (Panel fill)
COLOR_NORD2_BORDER  = "&H005E4C43"  # #434C5E (Card border)
COLOR_NORD6_SNOW    = "&H00F4EFEF"  # #ECEFF4 (Snow White title)
COLOR_NORD8_CYAN    = "&H00D0C088"  # #88C0D0 (Station North Cyan)
COLOR_NORD13_GOLD   = "&H008BCBEB"  # #EBCB8B (Repeat Gold)
COLOR_NORD14_GREEN  = "&H008CBEA3"  # #A3BE8C (Live Green)

def generate_osd_ass(
    track: Dict[str, str],
    show_osd: bool = True,
    is_repeat: bool = False,
    output_path: str = "/tmp/sn_osd.ass"
) -> str:
    """
    Generiert die ASS-Untertitel-Datei für ffplay.
    Wenn show_osd=False, bleibt das Video 100% sauber ohne Overlays.
    """
    ass_lines = [
        "[Script Info]",
        "ScriptType: v4.00+",
        "PlayResX: 1024",
        "PlayResY: 768",
        "",
        "[V4+ Styles]",
        "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding",
        # 0. Top Header
        f"Style: TopHeaderStyle, DejaVu Sans, 14, {COLOR_NORD8_CYAN}, &H00000000, &H00000000, {COLOR_NORD0_BG}, 1, 0, 0, 0, 100, 100, 0, 0, 3, 3, 1, 7, 36, 10, 24, 1",
        # 1. Status Badge (oben in der Karte)
        f"Style: BadgeStyle, DejaVu Sans, 14, {COLOR_NORD14_GREEN if not is_repeat else COLOR_NORD13_GOLD}, &H00000000, &H00000000, {COLOR_NORD0_BG}, 1, 0, 0, 0, 100, 100, 0, 0, 3, 3, 1, 1, 36, 10, 96, 1",
        # 2. Titel: Große, fette Schrift (26pt)
        f"Style: TitleStyle, DejaVu Sans, 26, {COLOR_NORD6_SNOW}, &H00000000, {COLOR_NORD2_BORDER}, {COLOR_NORD0_BG}, 1, 0, 0, 0, 100, 100, 0, 0, 3, 5, 2, 1, 36, 10, 62, 1",
        # 3. Artist: Schöne Schrift (19pt)
        f"Style: ArtistStyle, DejaVu Sans, 19, {COLOR_NORD8_CYAN}, &H00000000, {COLOR_NORD2_BORDER}, {COLOR_NORD0_BG}, 1, 0, 0, 0, 100, 100, 0, 0, 3, 4, 2, 1, 36, 10, 32, 1",
        "",
        "[Events]",
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text"
    ]

    if show_osd and track:
        title = track.get("title", "Unknown Title").replace("{", "(").replace("}", ")")
        artist = track.get("artist", "Unknown Artist").replace("{", "(").replace("}", ")")
        badge = "🔂 REPEAT LOOP ACTIVE • STATION NORTH TV" if is_repeat else "▶ NOW PLAYING • STATION NORTH TV"

        # Blendet nach 0.2s weich ein und nach 4.8s weich aus
        ass_lines.append(f"Dialogue: 1,0:00:00.20,0:00:04.80,TopHeaderStyle,,0,0,0,,{{\\fad(250,500)}}  STATION NORTH TV • THE QUEEN'S FREQUENCY  ")
        ass_lines.append(f"Dialogue: 1,0:00:00.20,0:00:04.80,BadgeStyle,,0,0,0,,{{\\fad(250,500)}}  {badge}  ")
        ass_lines.append(f"Dialogue: 1,0:00:00.20,0:00:04.80,TitleStyle,,0,0,0,,{{\\fad(250,500)}}  {title}  ")
        ass_lines.append(f"Dialogue: 1,0:00:00.20,0:00:04.80,ArtistStyle,,0,0,0,,{{\\fad(250,500)}}  {artist}  ")

    content = "\n".join(ass_lines) + "\n"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(content)

    return output_path

if __name__ == "__main__":
    t = {"title": "Changes", "artist": "2Pac ft. Talent"}
    out = generate_osd_ass(t, show_osd=True, is_repeat=False, output_path="/tmp/sn_osd.ass")
    print(f"OSD ASS generiert: {out}")
