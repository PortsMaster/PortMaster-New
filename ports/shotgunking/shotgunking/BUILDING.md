# Building the Shotgun King Port

The port ships pre-built aarch64 Linux binaries. These must be built on a
**Debian Bullseye (11)** aarch64 system (or chroot) for glibc compatibility
with handheld Linux distributions (ArkOS, ROCKNIX, etc.).

## Prerequisites

### Bullseye chroot setup

If you don't have a native Bullseye aarch64 system, create a chroot:

```bash
sudo debootstrap --arch=arm64 bullseye /path/to/chroot
sudo chroot /path/to/chroot
```

### Build dependencies

Inside the chroot, install:

```bash
apt-get update
apt-get install build-essential cmake ninja-build clang git \
    libsdl2-dev libfreetype-dev libluajit-5.1-dev \
    libegl-dev libgles-dev
```

## Build steps

### 1. machismo + libsystem_shim.so + libsugar_patches.so

```bash
cd machismo/build && cmake -S .. -B . && make
```

Output: `machismo`, `libsystem_shim.so`, `libsugar_patches.so`

`libsugar_patches.so` intercepts Sugar's `_load_ogg` to cache the decoded
and resampled PCM under `<gamedata>/.machismo-pcm-cache/` and `mmap` it on
subsequent loads. On Shotgun King this cuts resident memory by ~330 MB and
eliminates the per-track Vorbis decode on startup after the first run.

### 2. Apple-ABI libc++

```bash
cd machismo && ./scripts/build-libcxx.sh
cd build-libcxx && ninja cxx cxxabi
```

Output: `build-libcxx/lib/libc++.so.1`, `build-libcxx/lib/libc++abi.so.1`

### 3. LuaJIT

```bash
cd machismo && ./scripts/build-luajit.sh
```

Output: `build-luajit/lib/libluajit-5.1.so.2`

## Packaging

```bash
DEST=/path/to/port/shotgunking

# Loader
cp machismo/build/machismo "$DEST/bin/"

# Libraries
cp machismo/build/libsystem_shim.so "$DEST/libs/"
cp machismo/build/libsugar_patches.so "$DEST/libs/"
cp machismo/build-libcxx/lib/libc++.so.1 "$DEST/libs/"
cp machismo/build-libcxx/lib/libc++abi.so.1 "$DEST/libs/"
cp machismo/build-luajit/lib/libluajit-5.1.so.2 "$DEST/libs/"
```

### Repackage zip

```bash
cd port
rm -f shotgunking.zip
zip -r shotgunking.zip shotgunking/ -x "shotgunking/gamedata/*" "shotgunking/userdata/*"
```
