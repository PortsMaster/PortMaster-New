================================================================================
👑 STATION NORTH SNfetchPLAYER • PRIVATE VIDEO REPOSITORY
================================================================================

Welcome to your private offline Video Deck!
Drop your favorite music videos, retro concerts, and visuals directly into this
folder or into genre subfolders to watch and listen anywhere on your handheld.

--------------------------------------------------------------------------------
📁 FOLDER STRUCTURE & AUTO-INDEXING:
--------------------------------------------------------------------------------
Every subfolder in this directory is automatically discovered and indexed by
SNfetchPLAYER as its own dedicated station:

  videos/
  ├── HipHop/            -> Appears as: "🎬 Video • Hip Hop"
  │   └── 2Pac - Hit Em Up.mp4
  ├── Rock/              -> Appears as: "🎬 Video • Rock"
  │   └── AC_DC - Thunderstruck.mp4
  └── ... (Create any custom folders you like!)

--------------------------------------------------------------------------------
🎬 SUPPORTED VIDEO FORMATS:
--------------------------------------------------------------------------------
• MP4 (.mp4)
• MKV (.mkv)
• AVI (.avi)
• MOV (.mov)
• WEBM (.webm)

--------------------------------------------------------------------------------
🏷️ FILE NAMING CONVENTION:
--------------------------------------------------------------------------------
For the best on-screen display (OSD) and title banner formatting, name files as:

  Artist - Title.mp4
  Example: "Kendrick Lamar - Alright.mp4"

--------------------------------------------------------------------------------
📺 TV MODE VS. RADIO MODE (DUAL COMPATIBILITY):
--------------------------------------------------------------------------------
• TV BROADCAST MODE:
  Plays your videos scaled to 4:3 handheld displays with authentic Station North
  corner watermark, scanline-compatible fill, and floating broadcast banners.

• RADIO STAGE MODE (BONUS!):
  SNfetchPLAYER can play video files in Radio Mode! It extracts the audio stream
  in real-time and pumps it into the 40-band AGC Spectrum Analyzer.
  👉 PERFECT FOR: Music videos, live concert recordings, and lyric videos!

--------------------------------------------------------------------------------
⚡ PRO TIP: DOWNSCALING VIDEOS TO 480P FOR HANDHELDS (FFMPEG)
--------------------------------------------------------------------------------
Handheld displays (RK3326/RK3566) typically have 640x480 resolution.
Encoding your 1080p/4K videos to 480p saves huge amounts of MicroSD card space,
reduces battery drain, and guarantees silky 60 FPS playback with zero stutter.

1) Single Video Downscale (to 640x480 4:3 fit):
   ffmpeg -i "input_1080p.mp4" -vf "scale=640:-2" -c:v libx264 -crf 22 -preset fast -c:a aac -b:a 192k "Artist - Title.mp4"

2) Batch Convert All Videos in Current Folder to 480p:
   for f in *.mp4 *.mkv; do ffmpeg -i "$f" -vf "scale=640:-2" -c:v libx264 -crf 22 -preset fast -c:a aac -b:a 192k "480p_${f%.*}.mp4"; done

3) Extract Clean Audio (MP3) from a Video for the Music Deck:
   ffmpeg -i "video.mp4" -vn -c:a libmp3lame -q:a 2 "Artist - Title.mp3"

Tune in and enjoy the broadcast! 👑✨
