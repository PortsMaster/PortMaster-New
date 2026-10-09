#!/bin/bash
# Build libs.aarch64: libX11.so.6 (xstub.c), libXcursor.so.1 and libGLU.so.1 (stubs.c), libglxsdl.so (glxsdl.c with
# the decoder half of ARM's astc-encoder 5.3.0, Apache-2.0, for GPUs without ASTC; the clone from unity4shrink's build).
# Run it in a Debian bullseye arm64 chroot (GCC 10; libc, libstdc++ and libgcc stay dynamic, PortMaster never bundles
# core libraries). Chroot needs: build-essential libx11-dev libxcursor-dev libgl-dev. On an x86_64 PC it only compiles
# the sources as a check.
set -e
cd "$(dirname "$0")"
CF="-O2 -fPIC -shared -Wall -Wno-unused-parameter -Wno-unused-result"
if [ "$(uname -m)" != aarch64 ]; then
  for f in xstub stubs glxsdl; do gcc $CF -fsyntax-only $f.c; done; echo "sources compile"; exit 0
fi
A=${ASTCENC:-$HOME/astc-encoder}/Source
mkdir -p out obj
CF="$CF -march=armv8-a"
gcc $CF -Wl,-soname,libX11.so.6 -o out/libX11.so.6 xstub.c -lpthread
gcc $CF -Wl,-soname,libXcursor.so.1 -o out/libXcursor.so.1 stubs.c
gcc $CF -Wl,-soname,libGLU.so.1 -o out/libGLU.so.1 stubs.c
objs=""
for f in $A/astcenc_*.cpp astc_dec.cpp; do
  o=obj/$(basename $f .cpp).o; objs="$objs $o"
  g++ -O2 -fPIC -std=c++14 -fno-exceptions -fno-rtti -march=armv8-a -I$A -ffunction-sections -fdata-sections -DASTCENC_DECOMPRESS_ONLY \
      -DASTCENC_NEON=1 -DASTCENC_SVE=0 -DASTCENC_SSE=0 -DASTCENC_AVX=0 -DASTCENC_POPCNT=0 -DASTCENC_F16C=0 -c $f -o $o
done
g++ $CF -Wl,-soname,libglxsdl.so -Wl,--as-needed -Wl,--gc-sections -o out/libglxsdl.so -x c glxsdl.c -x none $objs -ldl
for f in out/libX11.so.6 out/libXcursor.so.1 out/libGLU.so.1 out/libglxsdl.so; do
  strip $f
  echo "$f: $(stat -c %s $f) bytes, needs $(objdump -T $f | grep -o 'GLIBC_[0-9.]*' | sort -V -u | tail -1)" \
       "$(objdump -T $f | grep -o 'GLIBCXX_[0-9.]*' | sort -V -u | tail -1)"
done
