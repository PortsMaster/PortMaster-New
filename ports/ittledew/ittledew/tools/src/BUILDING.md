# Building Ittle Dew's port files

The port runs the GOG Linux build (Unity 4.7, x86_64), or the data of the other builds on a Unity 4.7.2 Linux player (see below), with box64 and gl4es. The Unity player's X11 and GLX calls are answered by small stand-in libraries on top of the firmware's SDL2, so no Westonpack or X server is needed. Sources of everything built for the port are in `ittledew/tools/src/`.

The commands below run from the folder that holds `ittledew/` (the installed port, or `ports/ittledew/` in PortMaster-New).

## box64 (`ittledew/box64`)

[box64](https://github.com/ptitSeb/box64) 0.4.4 with one small change (a wrapped library's missing helper libraries are not errors), from [Knifethrower/box64-portmaster](https://github.com/Knifethrower/box64-portmaster); the shipped binary is its release asset. Cross-compiled on Ubuntu 24.04 (`gcc-aarch64-linux-gnu`, `cmake`, `symlinks`) against a Debian 10 sysroot (glibc 2.28). `-DBAD_SIGNAL=ON` is required on Rockchip kernels.

1. Sysroot:

```
SR=$HOME/sysroot-buster/root; mkdir -p $SR debs; cd debs
wget http://archive.debian.org/debian/pool/main/g/glibc/libc6_2.28-10+deb10u1_arm64.deb
wget http://archive.debian.org/debian/pool/main/g/glibc/libc6-dev_2.28-10+deb10u1_arm64.deb
wget http://archive.debian.org/debian/pool/main/l/linux/linux-libc-dev_4.19.249-2_arm64.deb
for p in *.deb; do dpkg-deb -x $p $SR; done
symlinks -cr $SR
```

2. box64:

```
git clone --branch portmaster --depth 1 https://github.com/Knifethrower/box64-portmaster.git && cd box64-portmaster && mkdir build && cd build
SR=$HOME/sysroot-buster/root
FLAGS="-nostdinc -isystem $(aarch64-linux-gnu-gcc -print-file-name=include) -isystem $SR/usr/include/aarch64-linux-gnu -isystem $SR/usr/include --sysroot=$SR -march=armv8-a -mtune=cortex-a55"
cmake .. -DARM64=1 -DARM_DYNAREC=ON -DBAD_SIGNAL=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_ASM_COMPILER=aarch64-linux-gnu-gcc \
  -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_ASM_FLAGS="$FLAGS" \
  -DCMAKE_EXE_LINKER_FLAGS="--sysroot=$SR -B$SR/usr/lib/aarch64-linux-gnu -L$SR/lib/aarch64-linux-gnu -L$SR/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,$SR/lib/aarch64-linux-gnu"
make -j$(nproc)
```

`libs.x64/libstdc++.so.6` and `libgcc_s.so.1` are the x86_64 libraries from box64's `x64lib` folder.

## The aarch64 tools and libraries

Everything else built for the port is built natively in a Debian bullseye arm64 chroot (on an x86_64 Linux PC through qemu-user-static), with glibc, libstdc++ and libgcc linked dynamically. Each tool has its sources and a `build` script in `ittledew/tools/src/<tool>/`:

- `unity4shrink`: `tools/unity4shrink`, shrinks the large textures and re-encodes DXT5 textures as ASTC with [ARM's astc-encoder](https://github.com/ARM-software/astc-encoder) 5.3.0.
- `xstub`: `libs.aarch64/libX11.so.6`, `libXcursor.so.1` and `libGLU.so.1` (stand-ins with only the functions the player imports) and `libglxsdl.so` (GLX on an SDL2 window; hands the ASTC textures to the GPU).
- `gl4es`: `gl4es.aarch64/libGL.so.1`, upstream [gl4es](https://github.com/ptitSeb/gl4es) commit `a744af14` with `gl4es-ports.patch`, built without X11 or EGL linking (glxsdl creates the context through SDL2 and starts gl4es). The patch fixes gl4es bugs found while porting: reused shader program ids (a crash in the intro), 16-bit-per-channel uploads, ARB shader parser overflows, row-length uploads and a packed depth-stencil buffer for Mali.
- `unity4convert`: `tools/unity4convert`, rewrites Unity 4.x game data to Unity 4.7.2's format for the Windows, Mac and Steam builds, which run on `donor.7z` (a Unity 4.7.2 Linux x86_64 player with its Mono runtime and a placeholder game made for PortMaster ports; licenses in `licenses/LICENSE.donor.txt`).
- `innoextract`: `tools/innoextract`, [innoextract](https://constexpr.org/innoextract/) 1.9 with Boost, liblzma, zlib and bzip2 linked in (licenses in `licenses/LICENSE.innoextract.txt`), for the GOG Windows installer.

1. The chroot, once:

```
sudo apt install debootstrap qemu-user-static
sudo debootstrap --arch=arm64 bullseye ~/chroot-bullseye http://deb.debian.org/debian
sudo chroot ~/chroot-bullseye apt-get install -y build-essential cmake git libx11-dev libxcursor-dev libgl-dev \
  libboost-iostreams-dev libboost-filesystem-dev libboost-date-time-dev libboost-system-dev \
  libboost-program-options-dev liblzma-dev zlib1g-dev libbz2-dev
sudo chroot ~/chroot-bullseye git clone --depth 1 --branch 5.3.0 https://github.com/ARM-software/astc-encoder.git /root/astc-encoder
sudo mkdir -p ~/chroot-bullseye/work
```

2. Each tool, from the folder that holds `ittledew/` (gl4es and innoextract clone their sources, so the chroot needs network):

```
for T in unity4shrink xstub gl4es unity4convert innoextract; do
  sudo mount --bind "ittledew/tools/src/$T" ~/chroot-bullseye/work
  sudo chroot ~/chroot-bullseye /bin/bash -c 'cd /work && HOME=/root bash build'
  sudo umount ~/chroot-bullseye/work
done
```

The results land in each tool's folder: `out/unity4shrink`, `out/libX11.so.6` / `out/libXcursor.so.1` / `out/libGLU.so.1` / `out/libglxsdl.so`, `libGL.so.1` (gl4es), `out/unity4convert` and `out/innoextract`.

## Game data patches

Nothing to build: the first-launch setup (`tools/patchscript`) applies small xdelta3 patches (`tools/patch/`) that fit only these GOG and Steam builds. They raise the player's assumed VRAM so large portraits are not striped, fix the d-pad bindings (Windows axis numbers), render the world at the screen's size, move the room tiles' texture coordinates 1 pixel inside their edges (otherwise PowerVR GPUs show thin lines between tiles), and on Steam switch the saves to files and the donor player's joystick reading back on. GOG only: the world's light effect drawn through a render texture instead of a per-frame screen copy.
