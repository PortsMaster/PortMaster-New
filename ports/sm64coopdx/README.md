## Notes

Thanks to the [Coop Deluxe Team](https://github.com/coop-deluxe/sm64coopdx) for making sm64coopdx, and to Nintendo for the original Super Mario 64.

Thanks to CODEHEX4EVER for the original PortMaster port, which this release replaces.

This build targets aarch64 handhelds (tested on RK3326 / ArkOS). It uses native SDL2 gamepad input, so no gptokeyb mapping is needed.

## Controls

The gamepad uses the standard N64 layout and bindings can be remapped in-game. Gamepads work out of the box via SDL2.

Text fields (e.g. player name or chat) use the controller-operated on-screen keyboard:

| Button | Action |
|--|--|
| D-pad / Analog stick | Move between keys |
| A | Enter the selected key |
| B | Backspace (hold to repeat) |
| L / R | Shift / capitalized characters |
| OK | Close the keyboard and keep the entered value |
| Start | Close the keyboard |

The chat window can be opened with R3 and scrolled with the right analog stick.

## Compile

```sh
docker run --rm --platform linux/arm64 \
  -v "$PWD":/build -w /build debian:bullseye bash -l <<'DOCKER'
apt-get update && apt-get install -y --no-install-recommends \
  build-essential python3 libglew-dev libsdl2-dev libz-dev \
  libcurl4-openssl-dev bsdmainutils file binutils zip pkg-config
make TARGET_RK3326=1 UPDATER=0 \
  EXTRA_CPP_FLAGS="-std=c++17" -j"$(nproc)"
DOCKER
```

The output binary is `build/us_pc/sm64coopdx.arm` (rename to `sm64coopdx.aarch64` when packaging).

## Install

Copy your legally obtained US Super Mario 64 ROM to `ports/sm64coopdx/` as a `.z64` file (e.g. `baserom.us.z64`). The launcher renames it automatically on first run.

Cheers! - **DTS**
