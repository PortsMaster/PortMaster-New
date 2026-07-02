# Building the NecroDancer Port

The port ships pre-built aarch64 Linux binaries. Build on a **Debian Bullseye
(11) aarch64** system (or chroot) for glibc compatibility with handheld distros.

## Clone and init submodules

```bash
git clone https://github.com/bmdhacks/machismo.git
cd machismo
git submodule update --init extern/bgfx extern/bimg extern/bx extern/sfml extern/LuaJIT
git submodule update --init --depth 1 extern/llvm-project
cd extern/llvm-project && git checkout llvmorg-15.0.7 && cd ../..
```

## Build dependencies (Bullseye)

```bash
apt-get install build-essential cmake ninja-build clang git \
    libsdl2-dev libfreetype-dev libluajit-5.1-dev \
    libopenal-dev libvorbis-dev libogg-dev libflac-dev \
    libtheora-dev libcurl4-openssl-dev libzstd-dev \
    libx11-dev libxrandr-dev libgl-dev libglu1-mesa-dev \
    libegl-dev libgles-dev libudev-dev
```

## Build steps

All from the machismo repo root:

```bash
# 1. machismo + libsystem_shim.so + libgalaxy_shim.so
mkdir -p build && cd build && cmake .. && make -j$(nproc) && cd ..

# 2. Apple-ABI libc++ (LLVM 15, with _LIBCPP_ABI_ALTERNATE_STRING_LAYOUT)
./scripts/build-libcxx.sh
cd build-libcxx && ninja cxx cxxabi && cd ..

# 3. LuaJIT (optimized, unstripped for perf visibility)
./scripts/build-luajit.sh

# 4. bgfx (GLES 3.1 renderer, links Apple-ABI libc++)
./scripts/build-bgfx.sh

# 5. SFML 2.5.1 (links Apple-ABI libc++)
./scripts/build-sfml.sh
```

## Package for the port

```bash
DEST=/path/to/ports/necrodancer/necrodancer

# Core
cp build/machismo        "$DEST/bin/"
cp build/machismo        "$DEST/libs/"
cp build/libsystem_shim.so "$DEST/libs/"
cp build/libgalaxy_shim.so "$DEST/libs/"

# Apple-ABI libc++
cp build-libcxx/lib/libc++.so.1    "$DEST/libs/"
cp build-libcxx/lib/libc++abi.so.1 "$DEST/libs/"

# LuaJIT
cp build-luajit/lib/libluajit-5.1.so.2 "$DEST/libs/"

# bgfx
cp build-bgfx/libbgfx-shared.so "$DEST/libs/"

# SFML (use soname versions)
cp build-sfml/lib/libsfml-{graphics,window,network,system}.so.2.5 "$DEST/libs/"

# Remove desktop GL deps (handhelds have GLES only)
patchelf --remove-needed libGL.so.1 "$DEST/libs/libbgfx-shared.so"
for lib in libsfml-graphics.so.2.5 libsfml-window.so.2.5; do
    patchelf --remove-needed libGL.so.1  "$DEST/libs/$lib"
    patchelf --remove-needed libGLU.so.1 "$DEST/libs/$lib"
done
```

## Submodule versions

| Submodule | Version | Purpose |
|-----------|---------|---------|
| `extern/llvm-project` | `llvmorg-15.0.7` | Apple-ABI libc++ |
| `extern/bgfx` | `36ec932f4` (API v118) | bgfx renderer |
| `extern/bimg` | `1955d8f` | bgfx image library |
| `extern/bx` | `20efa22` | bgfx base library |
| `extern/sfml` | `2f11710a` (2.5.1) | SFML |
| `extern/LuaJIT` | v2.1 branch | LuaJIT |
