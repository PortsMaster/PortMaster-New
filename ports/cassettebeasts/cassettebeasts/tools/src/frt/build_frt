#!/bin/bash
# Cross-compile frt (FRT 2.1.0 platform) + Godot 3.5.2 for aarch64 with clang, using the Debian bullseye
# arm64 chroot as sysroot (glibc 2.31, SDL2 2.0.14 headers; the binary loads GLES through SDL like
# PortMaster's frt_3.5.2).
#   build_frt.sh [target=release|release_debug] [extra scons args]    (NOSTRIP=1: keep symbols, same code)
#   EXTRA_CCFLAGS="-mtune=cortex-a35", EXTRA_LINKFLAGS: more flags (the default build is plain -march=armv8-a -O2)
#   WORK=<dir> holding godot/ (3.5.2-stable + the patches) and frt/ (efornara/frt; its 2.1.0 worktree is
#   linked as godot/platform/frt), SYSROOT=<Debian bullseye arm64 root>. From Cassette Beasts. License: 0BSD.
set -e
W=$(realpath "${WORK:?WORK=<dir with godot/ and frt/>}")
R=$(realpath "${SYSROOT:?SYSROOT=<Debian bullseye arm64 root>}")
TARGET=${1:-release}; shift || true
cd "$W"
# frt 2.1.0 as the platform
if [ ! -d frt-2.1.0 ]; then
	git -C frt worktree add -f "$W/frt-2.1.0" 2.1.0
fi
[ -e godot/platform/frt ] || ln -s "$W/frt-2.1.0" godot/platform/frt
# pkg-config for the sysroot (frt_cross=auto asks for aarch64-linux-gnu-pkg-config)
mkdir -p bin
cat > bin/aarch64-linux-gnu-pkg-config <<EOF
#!/bin/sh
export PKG_CONFIG_SYSROOT_DIR=$R
export PKG_CONFIG_LIBDIR=$R/usr/lib/aarch64-linux-gnu/pkgconfig:$R/usr/share/pkgconfig
exec pkg-config "\$@"
EOF
chmod +x bin/aarch64-linux-gnu-pkg-config
export PATH="$W/bin:$PATH"
STRIP=-s; [ -n "$NOSTRIP" ] && STRIP=
cd godot
scons platform=frt tools=no target=$TARGET use_llvm=yes frt_arch=arm64v8 frt_cross=auto \
	warnings=no progress=no -j"$(nproc)" \
	CCFLAGS="--sysroot=$R $EXTRA_CCFLAGS" LINKFLAGS="--sysroot=$R -fuse-ld=lld $STRIP $EXTRA_LINKFLAGS" "$@"
ls -la bin/
