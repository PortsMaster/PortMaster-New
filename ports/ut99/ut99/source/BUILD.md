# Rebuilding NOpenGLESDrv for ARM64

This directory contains the exact PortMaster compatibility patch and the small
standalone CMake project used to build `NOpenGLESDrv.so` against OldUnreal 469e.

## Inputs

1. Clone `https://github.com/Andiweli/UT99-Android.git` and check out commit
   `85b1a9ada6ae28c422570d4603e57e4e4cef6eb1`.
2. Download `OldUnreal-UTPatch469e-SDK.zip` and
   `OldUnreal-UTPatch469e-Linux-arm64.tar.bz2` from the official v469e release.
3. Prepare an AArch64 Linux sysroot containing SDL2 and GLES2 headers and link
   libraries. The released binary was cross-compiled with Zig for
   `aarch64-linux-gnu.2.29` against the TrimUI firmware sysroot.
4. Use CMake 3.16 or newer and an AArch64 Linux C/C++ cross-compiler. The build
   that produced the package used Zig 0.14.1.

Verify the downloaded archives:

```text
b213789a18d736beacdf8bc2740bcc6e031789b806823b9f7eb3a75b2dacedcc  OldUnreal-UTPatch469e-SDK.zip
4c3978073b12b049c3ffdeb4d275cfc7a2313650f3eb5b94db06fbfee77c3e3b  OldUnreal-UTPatch469e-Linux-arm64.tar.bz2
```

## Apply the renderer patch

From the pinned UT99-Android checkout:

```sh
git apply /path/to/source/NOpenGLESDrv469.patch
```

Only these upstream renderer files are changed:

- `third_party/ut99dc/Source/NOpenGLESDrv/CMakeLists.txt`
- `third_party/ut99dc/Source/NOpenGLESDrv/NOpenGLESDrv.cpp`
- `third_party/ut99dc/Source/NOpenGLESDrv/NOpenGLESDrvPrivate.h`

## Configure and build

Set `CC` and `CXX` to AArch64 Linux compiler commands or wrappers. For the
original Zig build, the wrappers invoked:

```text
zig cc  -target aarch64-linux-gnu.2.29 --sysroot "$UT99_SYSROOT"
zig c++ -target aarch64-linux-gnu.2.29 --sysroot "$UT99_SYSROOT"
```

Then configure the standalone project:

```sh
export UT99_SYSROOT=/path/to/aarch64-linux-sysroot
export CC=/path/to/aarch64-linux-cc-wrapper
export CXX=/path/to/aarch64-linux-cxx-wrapper

cmake -S /path/to/source -B build-nopengles \
  -DCMAKE_TOOLCHAIN_FILE=/path/to/source/aarch64-linux.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DUT99DC_ROOT=/path/to/UT99-Android/third_party/ut99dc \
  -DUT99DC_COMPAT_ROOT=/path/to/UT99-Android/app/src/main/cpp \
  -DUT469_SDK=/path/to/extracted-469e-sdk \
  -DUT469_SYSTEM=/path/to/extracted-469e-arm64/SystemARM64 \
  -DUT99_SYSROOT="$UT99_SYSROOT"

cmake --build build-nopengles --parallel
```

The result is `build-nopengles/out/NOpenGLESDrv.so`. Its runtime dependencies
must resolve to the official 469e `Engine.so`, `Core.so`, `SDLDrv.so`, firmware
SDL2, and firmware GLESv2. Install it beside the other 469e ARM64 engine modules.

The binary bundled with this port has SHA-256:

```text
c6d8411e94fe8a279eb5664174243de5a2986a425e365604a113fb8dcf8bd161  NOpenGLESDrv.so
```

This hash records the tested release artifact; compiler and linker differences
may prevent an independently rebuilt binary from being bit-for-bit identical.
