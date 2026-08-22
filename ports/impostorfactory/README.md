## Notes

Thanks to [Ancurio](https://github.com/Ancurio/mkxp-freebird) for mkxp-freebird, the open-source RGSS reimplementation this port runs on — Impostor Factory continues Freebird Games' To the Moon series and its reputation for emotionally driven storytelling.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move |
| A | Confirm |
| B | Cancel |
| X | Dash |
| Start | Confirm |

## Compile

### 1. Ruby 2.1.5 (with static zlib support)

mkxp-freebird's MRI binding needs Ruby 2.1 built with zlib statically initialized, or save files come out as 0 bytes (RGSS's save format is Marshal + Zlib::Deflate).

```
wget https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz
tar xf ruby-2.1.5.tar.gz
cd ruby-2.1.5
patch -p1 < ../mkxp-freebird/patches/ruby/static_zlib.patch
./configure --prefix=/opt/ruby-2.1.5-mkxp --enable-shared --disable-install-doc --with-out-ext=openssl,tk,tk/tkutil
make -j$(nproc)
make install
```

`--with-out-ext=openssl,tk,tk/tkutil` skips extensions this port doesn't need and that fail to build against modern OpenSSL 3.x headers.

### 2. SDL_sound (Ancurio fork)

mkxp-freebird links against the legacy `SDL_sound` API (`libSDL_sound-1.0.so.1`), not the modern SDL2_sound rewrite. Built with the MOD/S3M/XM tracker decoders disabled.

```
git clone https://github.com/Ancurio/SDL_sound.git
cd SDL_sound
./bootstrap
./configure --prefix=/usr/local --disable-mikmod --disable-modplug
make -j$(nproc)
make install
```

### 3. mkxp-freebird

Built for native GLES2 (`DEFINES+=GLES2_HEADER` in the project's own `.pro` file) rather than through gl4es, so no OpenGL translation layer is bundled.

```
git clone https://github.com/Cebion/mkxp-freebird.git
cd mkxp-freebird
mkdir build && cd build
PKG_CONFIG_PATH="/opt/ruby-2.1.5-mkxp/lib/pkgconfig:$PKG_CONFIG_PATH" \
cmake .. \
  -DBINDING=MRI \
  -DMRIVERSION=2.1 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-DGLES2_HEADER" \
  -DCMAKE_C_FLAGS="-DGLES2_HEADER" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make -j$(nproc)
```

Two source patches are applied on top of the `Cebion/mkxp-freebird` fork before building:
- `src/eventthread.cpp` — both `SDL_JoystickOpen` call sites removed, so gptokeyb2 is the only input path (the engine otherwise reads the low-level SDL joystick API directly, which double-inputs alongside gptokeyb2).
- `src/main.cpp` — adds `SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES)` (plus GL version 2.0) before `SDL_CreateWindow`, guarded by `#ifdef GLES2_HEADER`, since the engine never requests an ES context on its own even when built with GLES2 headers.
