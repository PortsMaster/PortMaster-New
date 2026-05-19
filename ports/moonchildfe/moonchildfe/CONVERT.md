# AGENTS.md -- SDL2 + ARM64 Porting Notes

This document exists specifically to remember:
- how SDL3 functionality was ported to SDL2
- how to build ARM64/PortMaster releases
- packaging/runtime gotchas that break handheld builds

---

# SDL3 → SDL2 Conversion Checklist

When SDL3 backend functionality changes, keep the SDL2 backend in sync.

| Concern | SDL3 API | SDL2 API |
|---|---|---|
| Cursor hide | `SDL_HideCursor()` | `SDL_ShowCursor(SDL_DISABLE)` |
| Audio open | `SDL_OpenAudioDeviceStream()` | `SDL_OpenAudioDevice()` |
| Audio stream | SDL stream API | Manual callback + mutex |
| WAV load | `SDL_LoadWAV()` | `SDL_LoadWAV_RW()` |
| Quit event | `SDL_EVENT_QUIT` | `SDL_QUIT` |
| Gamepad | SDL3 gamepad events | handled externally via gptokeyb |
| Fullscreen | runtime toggle | fullscreen at creation |

## SDL2 backend files

Keep these aligned with SDL3 behavior:

- `Platform/Backends/Window/SDL2Window.cpp`
- `Platform/Backends/Audio/SDL2Audio.cpp`
- `Platform/Backends/Input/SDL2Input.cpp`

Renderer remains GLES via `GLESRenderer.cpp`.

---

# Critical Audio Notes

Movie audio glitches are usually caused by thread safety issues.

Both functions MUST hold `AudioLock`:

- `SubmitMovieAudio()`
- `MixMovieAudio()`

Without locking:
- pops
- crackles
- race conditions
- use-after-free

Movie lead time:

```cpp
plm_set_audio_lead_time(PlmInstance, 16384.0 / sampleRate);
```

Mixer assumptions:
- 48kHz
- stereo
- float32

All movie/music/SFX audio must end up as 48kHz stereo float.

---

# ARM64 PortMaster Build

## One-time QEMU setup

```bash
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

## Pull builder image

```bash
docker pull --platform=linux/arm64 \
  ghcr.io/monkeyx-net/portmaster-build-templates/portmaster-builder:aarch64-latest
```

## Build

```bash
rm -rf CMakeOut/PortMaster

docker run --rm --platform=linux/arm64 \
  -v "$(pwd)":/workspace \
  ghcr.io/monkeyx-net/portmaster-build-templates/portmaster-builder:aarch64-latest \
  bash -c 'cd /workspace && cmake -B CMakeOut/PortMaster/Release \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local \
    -DMOONCHILD_WINDOW_BACKEND=SDL2 \
    -DMOONCHILD_RENDERER_BACKEND=GLES \
    -DMOONCHILD_INPUT_BACKEND=SDL2 \
    -DMOONCHILD_AUDIO_BACKEND=SDL2 \
    -DMOONCHILD_OUTPUT_PLATFORM=PortMaster \
    -DMOONCHILD_VENDORED_SDL3=OFF \
    -DMOONCHILD_VENDORED_ZLIB=OFF \
    -DMOONCHILD_VENDORED_GAMECONTROLLERDB=OFF \
    -DMOONCHILD_VENDORED_PL_MPEG=ON && \
    cmake --build CMakeOut/PortMaster/Release --parallel $(nproc)'
```

## Verify binary

```bash
file Bin/PortMaster/Release/MoonChildFE
```

Expected:

```text
ELF 64-bit LSB pie executable, ARM aarch64
```

---

# Packaging

## Copy binary

```bash
cp Bin/PortMaster/Release/MoonChildFE moonchildfe/moonchildfe/MoonChildFE
chmod +x moonchildfe/moonchildfe/MoonChildFE
```

## Recompress movies

```bash
./Scripts/RecompressMovies.sh \
  Data/movies/ \
  moonchildfe/moonchildfe/data/movies/
```

Target:
- 800kbps video
- 128kbps MP2 audio
- 48kHz stereo
- 640x480 @ 25fps

---

# Launch Script Gotchas

## Required

- `chmod +x` must target exact filename: `MoonChildFE`
- binary is native ARM64 (NO box64)
- SDL2 Wayland backend handles display directly
- gamepad handled via gptokeyb
- `pm_platform_helper` must receive binary path

## Rocknix

```bash
export XDG_RUNTIME_DIR=/var/run/0-runtime-dir
export WAYLAND_DISPLAY=wayland-1
export SDL_VIDEODRIVER=wayland
```

---

# Runtime Gotchas

- `data/mc.art` is mandatory
- `mc_opts.dat` should exist before first launch
- mixer frequency must stay 48000
- fullscreen is always enabled in SDL2 backend
- hardware cursor must be hidden
- no `SDL_INIT_GAMECONTROLLER` on SDL2 builds

---

# PortMaster Package Layout

```text
moonchildfe/
├── Moon Child FE.sh
└── moonchildfe/
    ├── MoonChildFE
    ├── moonchildfe.gptk
    ├── mc_opts.dat
    ├── libs/
    └── data/
```

---

# Movie Compression

Movies can be recompressed significantly for handheld builds and smaller package size.

Typical reduction:
- ~122 MB → ~27 MB

Requirements:
- MPEG-1 video
- 640x480
- 25fps
- 48kHz stereo MP2 audio

Recommended ffmpeg settings:
- video bitrate: `800k`
- audio bitrate: `128k`
- output format: MPEG program stream

Reference script:

```bash
#!/bin/bash
set -euo pipefail

SRC="${1:-Data/movies}"
DST="${2:-Data/movies}"

mkdir -p "$DST"

for movie in "$SRC"/*.mpg; do
    name=$(basename "$movie")

    ffmpeg -y -i "$movie" \
        -c:v mpeg1video -b:v 800k -maxrate 1200k -bufsize 800k \
        -vf "scale=640:480:force_original_aspect_ratio=decrease,pad=640:480:(ow-iw)/2:(oh-ih)/2" \
        -r 25 \
        -c:a mp2 -b:a 128k -ar 48000 -ac 2 \
        -f mpeg "$DST/$name"
done
```

No recompression script is shipped in releases, so document this process in README/package notes if distributing source or build instructions.

