## Notes

Special thanks to [wootbeer](https://github.com/wootbeer/snprecomp) for creating `snprecomp`, [Wiseguy](https://github.com/N64Recomp/N64ModernRuntime) for `N64Recomp` and `N64ModernRuntime`, and Treasure for the original Nintendo 64 rail shooter and its tight blend of free-aimed gunplay and close-range sword parrying.

To play, copy your legally obtained Nintendo 64 cartridge dump (`.z64`, `.n64`, or `.v64`) into `ports/sinandpunishment/roms/` before launching. Optional community translation patches (`.bps`, `.ups`, `.ips`, `.xdelta`) placed in `ports/sinandpunishment/roms/` will be verified and applied automatically on first boot.

On first boot, PortMaster verifies and normalizes your ROM, applies any optional translation patch, reconstructs the game binary from the clean-room ROM-keyed `snp.patch`, and caches the verified ROM for zero-write instant fast boot on subsequent launches.

First boot automatically selects `Stickless: Strafe + Shift` on stickless/single-stick handhelds and `Twin Stick` on dual-stick handhelds. Both `Hor+` widescreen (`3:2`, `16:9`, `16:10`) and `Vert+` square/tallscreen (`1:1` `720x720` RGB30 / RG CubeXX, `5:4`) aspect ratios are natively supported alongside `4:3 Original`, dynamically expanding 3D field-of-view, scissor boxes, and reticle reach without stretching or letterboxing. You can press `Select` or `Menu` at any time during gameplay to open the Quick Settings overlay and customize aspect ratios, control schemes, aiming curves, sensitivity, and graphics options.

Optional RetroAchievements support (Softcore Mode) is included via `rcheevos`. Existing credentials from NextUI (`minuisettings.txt`) and RetroArch (`retroarch.cfg`) are automatically discovered and imported on boot, or can be specified in `snprecomp.toml`. Full offline caching allows playing and unlocking achievements without an active internet connection; earned unlocks are queued with RTC-safe timestamping and synchronized automatically or via the `Sync Achievements` Quick Settings row.

## Controls

| Key | Action |
|--|--|
| D-Pad | Strafe left / right (Aim crosshair while holding L1/L2 in Stickless; navigate menus) |
| Left Analog | Strafe left / right (Move character in Twin Stick) |
| Right Analog | Reticle aiming (Twin Stick) |
| A | Fire / Sword slash (Confirm in menus; Lock-on in Twin Stick) |
| B | Jump / Double jump (Cancel in menus) |
| X | Cycle lock-on targets / Quick crosshair re-center (Dodge roll in Twin Stick) |
| Y | Dodge roll |
| L1 | Shift to manual aim (Stickless) / Jump (Twin Stick) / Strafe left (Bumper Strafe) |
| L2 | Shift to manual aim (Stickless) / Jump (Twin Stick) / Dodge roll (Legacy) |
| R1 | Fire / Sword slash |
| R2 | Fire / Sword slash |
| Start | Pause game |
| Select | Open / Close Quick Settings overlay |
| Select + Start | Quick save and exit |

## Compile

```bash
git clone --recursive https://github.com/wootbeer/snprecomp.git
cd snprecomp
git checkout 6e76c24c84e6fc65faeae89e8e75d7fac92aba1f
git submodule update --init --recursive
git clone --depth 1 https://github.com/RetroAchievements/rcheevos.git lib/rcheevos

# Apply PortMaster GLES3 handheld patches
git apply /path/to/patches/snprecomp-portmaster-gles3.patch

# Build host tools and patches
cmake -B build-host -G Ninja -DSNP_BACKEND_GLES3=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build-host --target file_to_c N64RecompCLI RSPRecomp PatchesLib snp-patch

# Generate C code and audio microcode from Japanese ROM
./build-host/N64RecompCLI snp.jp.toml
./build-host/RSPRecomp n_aspMain.jp.toml

# Cross-compile SnPRecompiled and snp-patch for aarch64
cmake -B build-aarch64 -G Ninja \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
  -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \
  -DCMAKE_CROSSCOMPILING=ON \
  -DSNP_BACKEND_GLES3=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="-march=armv8-a -ffp-contract=off" \
  -DCMAKE_CXX_FLAGS="-march=armv8-a -ffp-contract=off" \
  -DSNP_HOST_TOOLS_DIR="$PWD/build-host"
ninja -C build-aarch64 SnPRecompiled snp-patch
```
