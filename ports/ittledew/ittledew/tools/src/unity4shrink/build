#!/bin/bash
# Build unity4shrink with ARM's astc-encoder 5.3.0 (Apache-2.0, library sources only) compiled in:
#   git clone --depth 1 --branch 5.3.0 https://github.com/ARM-software/astc-encoder.git ~/astc-encoder
# In a Debian bullseye arm64 chroot: out/unity4shrink for the devices (GCC 10; glibc, libstdc++ and libgcc stay
# dynamic, PortMaster never bundles core libraries). On an x86_64 PC: out/unity4shrink-host for PC tests.
set -e
cd "$(dirname "$0")"
A=${ASTCENC:-$HOME/astc-encoder}/Source
mkdir -p out
if [ "$(uname -m)" = aarch64 ]; then
  T=a64 BIN=out/unity4shrink ARCH="-march=armv8-a" SIMD="-DASTCENC_NEON=1 -DASTCENC_SSE=0 -DASTCENC_POPCNT=0" LINK="-s"
else
  T=x86 BIN=out/unity4shrink-host ARCH="-msse4.1 -mpopcnt" SIMD="-DASTCENC_NEON=0 -DASTCENC_SSE=41 -DASTCENC_POPCNT=1" LINK=
fi
CXXF="-O2 -std=c++14 -fno-exceptions -fno-rtti -ffunction-sections -fdata-sections -I$A $ARCH $SIMD -DASTCENC_SVE=0 -DASTCENC_AVX=0 -DASTCENC_F16C=0"
objs=""
for f in $A/astcenc_*.cpp astc_glue.cpp; do o=out/$(basename $f .cpp).$T.o; g++ $CXXF -c $f -o $o; objs="$objs $o"; done
gcc -O2 -Wall -Wno-unused-function -ffp-contract=off -ffunction-sections -fdata-sections $ARCH -c unity4shrink.c -o out/unity4shrink.$T.o
g++ $LINK -Wl,--as-needed -Wl,--gc-sections -o $BIN out/unity4shrink.$T.o $objs -lpthread
echo "$BIN: $(stat -c %s $BIN) bytes, needs $(objdump -T $BIN | grep -o 'GLIBC_[0-9.]*' | sort -V -u | tail -1)" \
     "$(objdump -T $BIN | grep -o 'GLIBCXX_[0-9.]*' | sort -V -u | tail -1)"
