<p align="center">
  <img src="/demo.png" alt="demo" width="320" />
  &nbsp;&nbsp;&nbsp;
  <img src="/pico.png" alt="pico" width="320" />
</p>


# Capture

A dedicated **Rocknix** app that captures still screenshots or creates recordings as animated PNGs.

## Installation

1. Choose your console:
   - `rg34xx` (720w)
   - `rgb10x` (640w)

2. Copy the entire `capture` directory to the `roms/ports/` folder.

3. Final directory structure:
   ```text
   /roms/ports/
   ├─ capture/
   │  ├─ captureui
   │  ├─ conf
   │  ├─ libs
   └─ capture.sh


## How to Use

1. Select an option:
   - **Still Screenshot**  
     Saved to `roms/screenshots`
   - **Recording Duration**
     - 5s (24 frames)
     - 10s (48 frames)
     - 30s (127 frames)  
     Saved to `roms/recordings`
   - **Disable Hotkey**  
     Closes the daemon running in the background

2. Press **Start** to exit.

3. While the daemon is running in the background, press:
   - **Select + R1** (rg34xx)
   - **Right Thumbstick + Plus Button** (rgb10x)

4. After capturing:
   - Screenshots are collected automatically
   - An **Animated PNG** is generated from the captured frames


**Components:**
- `main.lua` - Change UI to your liking using Font sizes & Color palette

## Important Disclaimer

This tool is designed for downloading legally obtained files only. Users are solely responsible for ensuring they have the legal right to download and possess any files obtained through this software.

## License

Free to use for personal retro gaming purposes. Use at your own risk and in compliance with applicable laws.
