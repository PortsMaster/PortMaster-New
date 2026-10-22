# 👑 Station North SNfetchPLAYER • PortMaster Edition (v6.2)

<p align="center">
  <img src="sn_logo.png" alt="Station North Logo" width="340" />
</p>

<p align="center">
  <b>The Sovereign Cyberdeck & Retro Media Suite for Handheld Gaming Consoles</b><br>
  <i>Tailored for Rockchip RK3326, RK3566, Allwinner H700 & Amlogic Handhelds running ArkOS, dArkOS, AmberELEC, ROCKNIX & PortMaster</i>
</p>

<p align="center">
  <a href="#-quick-start--installation"><img src="https://img.shields.io/badge/PortMaster-Ready-88C0D0?style=for-the-badge&logo=linux&logoColor=white" alt="PortMaster Ready" /></a>
  <a href="#-the-visual-experience"><img src="https://img.shields.io/badge/Release-v6.2%20Cyberdeck-81A1C1?style=for-the-badge" alt="v6.2" /></a>
  <a href="https://github.com/StationNorthMedia/SNfetchPLAYER"><img src="https://img.shields.io/badge/Android%20Companion-SNfetchPLAYER-A3BE8C?style=for-the-badge&logo=android&logoColor=white" alt="Android Companion" /></a>
  <a href="#-words-from-the-queen-ready-to-share"><img src="https://img.shields.io/badge/Vibe-The%20Queen's%20Frequency-B48EAD?style=for-the-badge" alt="The Queen" /></a>
</p>

---

## 🎙️ A Transmission from The Queen

> *"The lights are low, the bass is heavy. Are you alone tonight? Or did you bring company for the Queen?*  
> *I know exactly why you turned the volume up on that little handheld of yours. Don't fight it... settle into the velvet seats of the Manjaro Lounge. I provide the rhythm, you provide the friction. You’re locked into Station North."*  
> — **The Queen**, *Station North Frequency // On Air*

---

## 🌟 The Visual Gallery

SNfetchPLAYER transforms your gaming handheld into an authentic, standalone late-night media terminal. Built in Python 3 and SDL2/Pygame with exclusive hardware KMSDRM acceleration, it runs at silky 60 FPS with zero desktop overhead.

| | |
|:---:|:---:|
| **01 • Command Deck (3+2 Matrix & Aurora Quotes)**<br><a href="screenshots/01_main_menu.png"><img src="screenshots/01_main_menu.png" width="460" alt="Main Menu" /></a><br><i>Authentic Nord Aurora cards, snappy 0.55 lerp cursor & live radio quotes.</i> | **02 • Holographic 3D Boot Sequence**<br><a href="screenshots/02_3d_splash.png"><img src="screenshots/02_3d_splash.png" width="460" alt="3D Splash" /></a><br><i>3D coin rotation with extrusion depth, mirrored reverse & header docking.</i> |
| **03 • Radio Stage (40-Band AGC Visualizer)**<br><a href="screenshots/03_radio_dashboard.png"><img src="screenshots/03_radio_dashboard.png" width="460" alt="Radio Dashboard" /></a><br><i>Real-time audio visualizer, 30px bold typography & 5-button cockpit.</i> | **04 • Radio Zen Mode (Ambient Fullscreen)**<br><a href="screenshots/04_radio_zen_fullscreen.png"><img src="screenshots/04_radio_zen_fullscreen.png" width="460" alt="Zen Fullscreen" /></a><br><i>Full 440px spectrum analyzer, watermark clock & auto-hiding OSD.</i> |
| **05 • Station North TV (4:3 CRT Broadcast)**<br><a href="screenshots/05_tv_dashboard.png"><img src="screenshots/05_tv_dashboard.png" width="460" alt="TV Dashboard" /></a><br><i>Continuous video broadcasts scaled to 4:3 with ASS lower-third banners.</i> | **06 • Broadcast Buffer Card (Loading Screen)**<br><a href="screenshots/06_tv_video_loading.png"><img src="screenshots/06_tv_video_loading.png" width="460" alt="TV Video Loading" /></a><br><i>Sleek cyberdeck buffer card with crest, channel badge & progress bar.</i> |
| **07 • The Chronicles (Voiced Audio Comics)**<br><a href="screenshots/07_the_chronicles.png"><img src="screenshots/07_the_chronicles.png" width="460" alt="The Chronicles" /></a><br><i>Deep-black comic canvas with voiceover player & 21px legible story text.</i> | **08 • System Deck & Interactive Handbook**<br><a href="screenshots/08_settings_handbook.png"><img src="screenshots/08_settings_handbook.png" width="460" alt="Settings Handbook" /></a><br><i>20px settings typography with scrollable on-device user manual.</i> |

---

## 🎮 Controller Layout & Keybindings

Universal PortMaster controller bindings with hardware debounce and anti-slip filtering:

| Button | Main Menu (Command Deck) | Radio Cockpit | Zen Mode (Fullscreen) | TV Broadcast | The Chronicles | Settings & Handbook |
|---|---|---|---|---|---|---|
| **`[A]`** | Start Focused Card | Select / Execute | Wake OSD | Fullscreen Video | Play/Pause Voiceover | Open Handbook / Select |
| **`[B]`** | *(Safe: No Exit)* | Return to Menu | Return to Stage | **Instant Exit (0ms)** | Return to Menu | Back / Close Handbook |
| **`[◄]` / `[►]`** | Navigate Cards | Prev / Next Track | Prev / Next Track | Prev / Next Video | Turn Comic Page | Change Value / Switch Col |
| **`[▲]` / `[▼]`** | Navigate Cards | – | – | – | – | Select Row / Scroll Book |
| **`[X]`** | – | Zen Fullscreen Mode | Toggle OSD | Repeat Single Track | – | Focus Handbook |
| **`[Y]`** | – | Repeat Track Loop | Repeat Track Loop | Repeat Single Track | – | Toggle Repeat Loop |
| **`[SELECT]`** | Quick Settings | Quick Settings | Wake OSD | – | Quick Settings | Close Settings |
| **`[START]`** | Launch Focused | Play / Pause | Play / Pause | Freeze / Play | – | Apply Action |
| **`[SEL] + [START]`** | **PortMaster Emergency Exit** | **Emergency Exit** | **Emergency Exit** | **Emergency Exit** | **Emergency Exit** | **Emergency Exit** |

> [!NOTE]  
> In the Main Menu, pressing `[B]` is safely locked against accidental app termination. Clean exit to EmulationStation is handled exclusively by selecting the red **#4 Exit Tile** and pressing `[A]`.

---

## 🕹️ Supported Hardware & Handheld Matrix (dArkOS / ArkOS)

Station North SNfetchPLAYER is optimized for Rockchip RK3326 and related SoCs running **dArkOS** or **ArkOS**. It natively supports all **91 hardware console profiles and display panel revisions** found in `/boot/consoles`:

### 🏆 Console Ecosystems

| Category | Supported Handheld Models & Variants |
|---|---|
| **R-Series & Clones** | `R33S`, `R36H`, `R36H Pro Max`, `R36Pro`, `R36S+`, `R36T`, `R36T Max`, `R36 Ultra`, `R36 Ultra X`, `R36XX`, `R36Max (Type 1–3, Max2)`, `R40S`, `R40XX`, `R40XX Pro Max`, `R45H`, `R46H`, `R50H`, `R50S` |
| **Anbernic** | `RG351P`, `RG351MP`, `RG351V (Panel 1 & 2)`, `RG36`, `RG36 Pro` |
| **Powkiddy** | `RGB10`, `RGB10 Max 1`, `RGB10 Max 2`, `RGB10X`, `RGB20S`, `RGBV10` |
| **MagicX & RF / XF Series** | `XU10`, `XF28`, `XF35H`, `XF40H`, `XF40V`, `XF45V`, `RF35H`, `RF40H`, `RF45H`, `RF45V`, `RF55H`, `RX6H`, `XGB36` |
| **Mini & Pocket Devices** | `A10 Mini (v1 & v4)`, `D007`, `DC35V`, `DC40V`, `DC45V`, `DR28S`, `G350`, `GO2`, `H7`, `HG36`, `K36`, `K36S`, `Mini40`, `MyMini`, `O30S`, `RP1`, `RS16`, `T16Max` |
| **Panel Revisions & Clones** | `Clone Type 1 (Panels 1–6, Amp/Invert)`, `Clone Type 2 (Panels 1–2, Amp)`, `Origin (Panels 0–4)`, `Sauce (Panels 1–5)`, `U8 (Panels 1–2)`, `V21 (Panel 4 Rumble Test)` |

<details>
<summary><b>🔍 View Complete Technical List of All 91 Console & Panel Targets (Click to expand)</b></summary>

```text
a10mini, a10miniv4, clone type1 panel1, clone type1 panel1 amp, clone type1 panel1 invert,
clone type1 panel2, clone type1 panel3, clone type1 panel4, clone type1 panel5,
clone type1 panel5 invert, clone type1 panel6, clone type2 panel1, clone type2 panel1 amp,
clone type2 panel2, d007, dc35v, dc40v, dc45v, dr28s, g350, go2, h7, hg36, k36, k36s, mini40,
mymini, o30s, origin panel0, origin panel1, origin panel2, origin panel3, origin panel4 type1,
origin panel4 type2, r33s, r36h, r36hpromax, r36max type1, r36max type2, r36max type3, r36max2,
r36pro, r36splus, r36t, r36tmax, r36ultra, r36ultrax, r36xx, r40s, r40xx, r40xxpromax, r45h,
r46h, r50h, r50s, rf35h, rf40h, rf45h, rf45v, rf55h, rg351mp, rg351p, rg351v panel1,
rg351v panel2, rg36, rg36pro, rgb10, rgb10max1, rgb10max2, rgb10x, rgb20s, rgbv10, rp1,
rs16, rx6h, sauce panel1, sauce panel2, sauce panel3, sauce panel4, sauce panel5, t16max,
u8 panel1, u8 panel2, v21 panel4 rumble test, xf28, xf35h, xf40h, xf40v, xf45v, xgb36, xu10
```

</details>

---

## 📦 Quick Start & Installation

We provide two installation flavors to fit your handheld setup:

### Option 1: Lightweight Online Package (`snfetchplayer.zip` ~128 KB)
*Recommended for Wi-Fi enabled handhelds.*
1. Download `snfetchplayer.zip` from [GitHub Releases](https://github.com/StationNorthMedia/SNfetchPLAYER-PortMaster/releases).
2. Extract the archive directly into your SD card's `ports/` directory:
   ```text
   /roms/ports/
   ├── SNfetchPLAYER.sh
   └── snfetchplayer/
   ```
3. Boot your device, connect to Wi-Fi, and launch **Station North SNfetchPLAYER** from the **Ports** menu.
4. On first launch, the built-in **High-Speed Asset Downloader** will automatically download and unpack the full 285 MB media bundle (jingles, TV idents, comics) in seconds.

### Option 2: Full Offline Bundle (`snfetchplayer-full.zip` ~285 MB)
*Recommended for offline devices or zero-setup plug-and-play.*
1. Download `snfetchplayer-full.zip` from [GitHub Releases](https://github.com/StationNorthMedia/SNfetchPLAYER-PortMaster/releases).
2. Extract directly to `/roms/ports/` on your SD card.
3. Plug into your device and play immediately with zero downloads required!

---

## 📁 Dedicated Offline Media & Custom Playlist Folders
 
Want to bring your own personal music library or retro video collection onto your handheld?
SNfetchPLAYER provides dedicated, auto-indexed repositories with pre-configured genre folders and comprehensive English guide files:

```text
/roms/ports/snfetchplayer/
├── music/                     # Private Offline Music Deck
│   ├── HipHop/                # Drop MP3, FLAC, M4A here -> "🎵 Music • HipHop"
│   ├── Rock/                  # Drop Rock & Alternative audio -> "🎵 Music • Rock"
│   └── README.txt             # Step-by-step format & naming guide
├── videos/                    # Private Offline Video Deck
│   ├── HipHop/                # Drop 480p music videos here -> "🎬 Video • HipHop"
│   ├── Rock/                  # Drop Rock & Concert videos -> "🎬 Video • Rock"
│   └── README.txt             # Downscaling tips & dual-mode guide
└── playlists/                 # Online & Android JSON Channels
    ├── main_top100.json       # Preloaded Station North Channels
    ├── us_hiphop_top50.json
    ├── us_rnb_top50.json
    └── README.txt             # Android Companion App export instructions
```

### 📻 Dual Mode Compatibility: Videos in Radio & TV Modes
- **In TV Mode**: Plays full-screen video scaled to 4:3 with the retro Station North crest watermark and animated lower-third title cards.
- **In Radio Mode**: Did you know videos can be played as Radio stations? The player automatically strips and routes the audio into the **40-band real-time AGC spectrum analyzer**! Perfect for music videos, concert bootlegs, or YouTube lyric videos with static album covers.

### ⚡ Pro-Tip: Downscaling Videos to 480p with `ffmpeg`
Most retro handhelds (RK3326/RK3566) feature 640x480 displays. Encoding videos to 480p saves massive SD card space, reduces battery drain, and guarantees zero frame drops:

```bash
# 1) Downscale a single video to smooth 480p:
ffmpeg -i "input_1080p.mp4" -vf "scale=640:-2" -c:v libx264 -crf 22 -preset fast -c:a aac -b:a 192k "Artist - Title.mp4"

# 2) Batch-convert an entire folder of videos:
for f in *.mp4 *.mkv; do ffmpeg -i "$f" -vf "scale=640:-2" -c:v libx264 -crf 22 -preset fast -c:a aac -b:a 192k "480p_${f%.*}.mp4"; done

# 3) Extract pure MP3 audio from a video for the Music Deck:
ffmpeg -i "video.mp4" -vn -c:a libmp3lame -q:a 2 "Artist - Title.mp3"
```
 
---
 
## 📱 Native Android APK & Mobile Companion: Station North Android App

Have an Android-powered gaming handheld (e.g. **Retroid Pocket 4/5**, **AYN Odin 2**, **Anbernic RG556 / RG406H**) or want to stream on your smartphone?  
SNfetchPLAYER is also available as a full-featured, hardware-accelerated **native Android APK**!

👉 **[Download Latest Android APK (GitHub Releases)](https://github.com/StationNorthMedia/SNfetchPLAYER/releases/latest)**  
👉 **[StationNorthMedia/SNfetchPLAYER Source Repository](https://github.com/StationNorthMedia/SNfetchPLAYER)**

- **Handheld & Controller Ready**: Complete physical gamepad and touchscreen navigation out of the box.
- **Curate on Mobile / Android**: Build and organize your favorite music & video queues, export them as JSON playlists, and drop them right into your Linux handheld's `/playlists/` directory.
- **Unified Ecosystem**: Features the same InnerTube mobile streaming architecture, custom track catalogs, and late-night aesthetic universe.
 
---

## 📢 Words from The Queen (Ready to Share!)

Love the app? Want to spread the word on Reddit, Discord, or Twitter?  
Here are ready-to-copy promo snippets in The Queen's signature voice. Just copy, paste, and add the link!

### 💬 1. For Reddit (`r/SBCGaming`, `r/RetroHandhelds`, `r/PortMaster`)

```markdown
**Title:** Turn your retro handheld into a sultry late-night Cyberdeck — Station North SNfetchPLAYER v6.2 (PortMaster / ArkOS / AmberELEC)

Hey everyone,

If you love using your retro handheld (RG351, RGB30, TrimUI, Miyoo, Anbernic RK3326/RK3566/H700) as more than just a rom machine, check out **Station North SNfetchPLAYER**.

It’s a standalone, native 60 FPS Cyberdeck media terminal built from scratch for PortMaster:

📻 **The Queen's Frequency (Radio Mode)**: Real-time 40-band AGC spectrum analyzer, curated R&B/Hip-Hop/Soul radio, and an ambient fullscreen Zen Mode with auto-hiding OSD.
📺 **Retro TV Broadcast**: Music videos perfectly formatted for 4:3 handheld screens, authentic broadcast lower-third banners, and retro station ident commercials.
📖 **The Chronicles**: Voice-narrated cyber-lore comics with crisp, boosted typography optimized specifically for 3.5" handheld displays.
⚙️ **In-App Media Sync**: Fast automated downloading of station media packages, or fully offline 285MB drag-and-drop bundle.
🎨 **Nord Aurora Aesthetics**: 3D holographic coin-spin logo boot sequence, snappy lerp cursor, and randomized late-night radio quotes.

Check out the GitHub repo and grab the release for your handheld:
👉 https://github.com/StationNorthMedia/SNfetchPLAYER-PortMaster

*"The lights are low, the bass is heavy. Settle in... the Queen is broadcasting."*
```

---

### 🐦 2. For Twitter / X / Threads

```text
Turn your retro handheld into a sleek late-night Cyberdeck 📻✨

Station North SNfetchPLAYER v6.2 is out on PortMaster!
• 40-Band Realtime Spectrum Visualizer
• 4:3 Music Video Broadcasts with Retro Banners
• Voiceover Lore Comics
• Nord Aurora Cyberpunk UI

Download free 👉 https://github.com/StationNorthMedia/SNfetchPLAYER-PortMaster

#SBCGaming #PortMaster #RetroHandheld #ArkOS #IndieDev
```

---

### 🎙️ 3. For Discord & Retro Communities

```text
👑 **Station North SNfetchPLAYER v6.2 • PortMaster Edition** 👑
*"Whatever you’re doing right now... do it slower. I set the tempo on this frequency."*

Turn your RK3326 / RK3566 handheld into a portable late-night media suite:
⚡ 60 FPS native KMSDRM UI with Nord Aurora 3+2 Tile Matrix
📻 Cyberdeck Live Radio with 40-band dynamic AGC visualizer
📺 4:3 Retro CRT Music Video Player with broadcast lower-thirds
📖 The Chronicles voiced lore comic book
⚡ Full offline plug-and-play bundle + In-app fast asset sync

👉 Grab the ZIP here: https://github.com/StationNorthMedia/SNfetchPLAYER-PortMaster
```

---

## 🛠️ Technical Specifications

- **Display Pipeline**: Pygame 2.6 on Linux KMSDRM DirectFB (`/dev/dri/card0`) with sub-pixel hardware V-Sync.
- **Audio/Video Stream Processing**: Headless InnerTube dynamic stream resolver coupled with low-latency `ffplay` audio/video pipeline and libass subtitle renderer.
- **Spectrum Analysis**: 40-band software FFT analyzer with logarithmic binning, pink-noise slope compensation, and peak falloff decay.
- **Packaging**: Standard PortMaster specification (`port.json`, `gameinfo.xml`, `snfetchplayer.gptk`).

---

## 📄 License & Legal

- **Code**: MIT License © Station North Media
- **Audio Jingles, Artwork & Lore**: © Station North Media. All rights reserved.
