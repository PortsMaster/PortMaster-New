## Notes

Thanks to [artchad and moldybits](https://codeberg.org/EverChange000/rl-dmomd) for DMOMD, a Common Lisp roguelike built on raylib that pairs procedurally generated dungeons with turn-based, spell-driven battles.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Analog | Move / Navigate menus |
| A | Confirm / Attack |
| Select | Back / Settings menu |
| Y | Inventory |
| L1 | Player information (hold) |
| Start | Settings menu |

## Compile

### 1. raylib 6.0 (SDL2, OpenGL ES 2.0)

miniaudio's PulseAudio backend is disabled so audio goes straight to ALSA (PipeWire's pulse shim fails on some CFWs).

```bash
git clone --branch 6.0 --depth 1 https://github.com/raysan5/raylib.git
cd raylib
sed -i 's/^#define MA_NO_JACK$/#define MA_NO_JACK\n#define MA_NO_PULSEAUDIO/' src/raudio.c
mkdir build && cd build
cmake .. -DPLATFORM=SDL -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_EXAMPLES=OFF -DOPENGL_VERSION="ES 2.0"
make -j"$(nproc)"
mkdir -p ../../libs && cp -L raylib/libraylib.so ../../libs/libraylib.so
cd ../..
```

### 2. SBCL and Quicklisp (pinned to the 2022-11-07 dist)

```bash
apt install sbcl libffi-dev
curl -O https://beta.quicklisp.org/quicklisp.lisp
sbcl --non-interactive --load quicklisp.lisp \
  --eval '(quicklisp-quickstart:install)' \
  --eval '(ql-dist:install-dist "http://beta.quicklisp.org/dist/quicklisp/2022-11-07/distinfo.txt" :replace t :prompt nil)'
```

### 3. Game

The port patches (raylib 6.0 `AudioStream` layout in cl-raylib, runtime asset path, fullscreen scaled output, `build-port.lisp`) are applied on top of the upstream source.

```bash
git clone --recurse-submodules https://codeberg.org/EverChange000/rl-dmomd.git
cd rl-dmomd
git apply ../dmomd-portmaster.patch
(cd third-party/cl-raylib && git apply ../../../cl-raylib-portmaster.patch)
LD_LIBRARY_PATH=../libs sbcl --dynamic-space-size 512MB --non-interactive --load build-port.lisp
```

This produces `dmomd.aarch64`, a standalone SBCL executable that expects `assets/` next to it.
