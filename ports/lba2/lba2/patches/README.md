# Rebuilding the port

The engine is [LBA2 Classic Community](https://github.com/LBALab/lba2-classic-community)
at `v0.12.0`. The SDL3 shim is [bmdhacks' SDL2 backend](https://github.com/bmdhacks/SDL/tree/sdl2-backend)
at `6057d79baf8321bf190479a699655f06cc2a962f`. The package carries the local
patches for both and their [licences](../licenses/).

## 1. Set up the cross-compiler

Use an x86_64 Ubuntu 20.04 build environment. Its AArch64 toolchain targets the
older glibc baseline; the binaries shipped in this package require glibc 2.29.
The CMake version in Ubuntu 20.04 is too old for the engine.

Run these commands from the package's `lba2` directory, in the same Bash session
as the remaining steps.

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl git gcc-aarch64-linux-gnu \
  g++-aarch64-linux-gnu ninja-build xz-utils

patch_dir="$PWD/patches"
mkdir -p "$PWD/build-aarch64"
cd "$PWD/build-aarch64"
build_dir="$PWD"
sdl_prefix="$build_dir/sdl3"

curl -fLO https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-linux-x86_64.tar.gz
tar -xzf cmake-3.31.8-linux-x86_64.tar.gz
export PATH="$build_dir/cmake-3.31.8-linux-x86_64/bin:$PATH"

cat > "$build_dir/aarch64.cmake" <<'EOF'
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
EOF
```

## 2. Build the SDL3 shim

The cursor patch prevents the host SDL2 cursor from being drawn over the game.
The shim uses the device's SDL2 rather than bundling platform drivers. The game
uses the GLES2 renderer; it does not need SDL's GPU API or SPIRV-Cross.

```bash
git init SDL
git -C SDL fetch --depth 1 https://github.com/bmdhacks/SDL.git 6057d79baf8321bf190479a699655f06cc2a962f
git -C SDL checkout --detach FETCH_HEAD
git -C SDL apply "$patch_dir/sdl2-keep-the-host-cursor-off-the-screen.patch"
cmake -S SDL -B SDL/build -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$build_dir/aarch64.cmake" \
  -DCMAKE_BUILD_TYPE=Release -DSDL_SDL2_BACKEND=ON \
  -DCMAKE_INSTALL_PREFIX="$sdl_prefix" \
  -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF \
  -DSDL_X11=OFF -DSDL_WAYLAND=OFF -DSDL_KMSDRM=OFF -DSDL_VIVANTE=OFF \
  -DSDL_OPENVR=OFF -DSDL_VULKAN=OFF -DSDL_GPU=OFF -DSDL_RENDER_GPU=OFF \
  -DSDL_ALSA=OFF -DSDL_PULSEAUDIO=OFF -DSDL_PIPEWIRE=OFF -DSDL_JACK=OFF \
  -DSDL_SNDIO=OFF -DSDL_OSS=OFF -DSDL_DISKAUDIO=OFF -DSDL_DUMMYAUDIO=OFF \
  -DSDL_OFFSCREEN=OFF -DSDL_DUMMYVIDEO=OFF \
  -DSDL_LIBUDEV=OFF -DSDL_DBUS=OFF -DSDL_IBUS=OFF -DSDL_UNIX_CONSOLE_BUILD=ON
cmake --build SDL/build --parallel "$(nproc)"
cmake --install SDL/build
```

## 3. Build the game engine

Apply the handheld-controls patch first, then the fixed-timestep weapon fix.
The build uses SDL audio and the open-source Smacker decoder. The original
x86 assembly is disabled on AArch64.

```bash
git clone --depth 1 --branch v0.12.0 https://github.com/LBALab/lba2-classic-community.git
git -C lba2-classic-community apply "$patch_dir/lba2cc-handheld-controls.patch"
git -C lba2-classic-community apply "$patch_dir/lba2cc-weapons-below-60fps.patch"
cmake -S lba2-classic-community -B lba2-classic-community/build -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$build_dir/aarch64.cmake" \
  -DCMAKE_FIND_ROOT_PATH="$sdl_prefix" \
  -DCMAKE_PREFIX_PATH="$sdl_prefix" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_SKIP_RPATH=ON \
  -DSOUND_BACKEND=sdl -DMVIDEO_BACKEND=smacker \
  -DLBA2_BUILD_TESTS=OFF -DENABLE_ASM=OFF -DLBA2_LINK_STATIC=OFF
cmake --build lba2-classic-community/build --parallel "$(nproc)"
```

## Patch notes

- **Menu controls:** A and X confirm, and B goes back. If you use a mouse,
  `MenuMouse` is enabled by default. Set it to `0` in `savedata/lba2.cfg` for
  keyboard and gamepad only.
- **Movement and frame rate:** Camera-relative turning uses a time-based angle
  accumulator. Walking uses animation keyframe displacement driven by the
  engine's fixed simulation timestep. At lower rendering rates, several
  simulation steps can run per frame. Keeping held fire input on those steps
  prevents the firing animation from repeatedly restarting before the shot.
- **Handheld bindings:** The D-pad handles movement, the left stick remains
  a secondary binding, L2 snaps the camera by 90 degrees, and R2 dodges.
  The removed D-pad item shortcuts remain available in the inventory.
