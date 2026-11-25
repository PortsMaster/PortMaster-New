## Notes

PocketTube is an unofficial YouTube client for Linux handhelds, made by Elmar: <https://github.com/ElmarYolchuyev23/pockettube>. The interface is in English, Russian and Turkish. It is not affiliated with or endorsed by YouTube or Google.

- Needs Wi-Fi.
- Video playback uses the firmware's own `mpv`. If your firmware has no `mpv`, the menus work but videos won't play.
- Downloads go to `/userdata/videos/youtube` and `/userdata/music/youtube` on Batocera / KNULLI, and to `ports/pockettube/downloads` and `ports/pockettube/music` on other firmware.
- yt-dlp can be updated from **Settings → yt-dlp** when YouTube changes.
- deno is not included, so some videos play in 480p instead of 720p.

Thanks to the [yt-dlp](https://github.com/yt-dlp/yt-dlp) team, to [pygame](https://www.pygame.org), and to Cebion for the pygame build from the Angry Drunken Dwarves port.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move |
| A | Select / watch |
| B | Back |
| X | Erase a character; delete or cancel a download; search filters |
| Y | Space; open search; save to a playlist |
| Start | Search; audio only on the video screen; play a whole playlist |
| Select | Settings |
| L1 / R1 | Switch sections |
| Select + Start | Quit |

### Player

| Button | Action |
|--|--|
| A | Pause / play |
| B | Exit (the position is remembered) |
| Left / Right | -10 / +10 seconds |
| Up / Down | +1 / -1 minute |
| L1 / R1 | Previous / next chapter |
| X | Subtitles on / off |
| Y | Menu: speed, subtitles, chapters, audio only, sleep timer |
| Start | Controls help |

## Build

The app is plain Python and runs on PortMaster's `python_3.11` runtime.

- `pockettube/` — PocketTube, built from the same source as the KNULLI and muOS packages (`build.py` in the PocketTube repository).
- `pockettube/pylib/pygame` — pygame 2.6.1 built against the system SDL2 for `python_3.11` (taken from the `angrydd` port).
- `pockettube/ytdlp_src` — the official yt-dlp release (`yt-dlp` zipapp) unpacked.
- `pockettube/assets/fonts` — Inter.
- `pockettube/libs.aarch64` — OpenSSL 1.1 (`libssl.so.1.1`, `libcrypto.so.1.1`) and `libffi.so.7` for aarch64: the `python_3.11` runtime needs them for HTTPS, and newer firmware (muOS) only ships OpenSSL 3.
- `pockettube/pylib/certifi` — CA certificates, used when the firmware has no certificate bundle.
