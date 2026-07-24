## Notes

Thanks to [CodeEngine](https://github.com/codengine/DasErbe2) for the original C#/.NET reimplementation of *Das Schmutzige Erbe* (*Das Erbe 2*).

## Controls

| Button | Action |
|--|--|
| Left stick / D-pad | Move mouse cursor |
| A | Left click |
| X (hold) | Slow/precise cursor movement |
| Back | Escape |

## Build

This port packages the reimplementation as a self-contained Native AOT build (`linux-arm64`), with a custom-built raylib (`PLATFORM_DESKTOP_SDL` against the system SDL2, `GRAPHICS_API_OPENGL_ES2` so it talks to the device's GLES2 driver directly, no OpenGL-to-GLES translation layer needed) bundled as `libraylib.so`. Everything below runs inside the aarch64 PortMaster compile chroot (`/root/compile`); this is a native build, not a cross-compile, since the chroot itself is aarch64. All runtime verification (does it launch, does gptokeyb work, does audio play) happens on a real device; the chroot cannot run the built binary.

### 1. Install the .NET 10 SDK

```shell
curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --channel 10.0 --install-dir /root/dotnet
export DOTNET_ROOT=/root/dotnet
export PATH="/root/dotnet:$PATH"
```

`dotnet --list-sdks` should show `10.0.x`; `dotnet --info` should report RID `linux-arm64`.

### 2. Build raylib

Raylib-cs 8.0.0 (the binding this game uses) does not ship a native library for `linux-arm64`, and binds against the official raylib 6.0 release.

```shell
cd /root/compile
git clone --branch 6.0 --depth 1 https://github.com/raysan5/raylib.git
cd raylib
mkdir build && cd build
cmake .. -DPLATFORM=SDL -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_EXAMPLES=OFF -DOPENGL_VERSION="ES 2.0"
make -j"$(nproc)"
```

Produces `raylib/libraylib.so.6.0.0`, dynamically linked against the system `libSDL2-2.0.so.0` (not bundled; provided by the CFW at runtime). SDL2 itself resolves the device's real GLES/EGL libraries at runtime; nothing else needs bundling for graphics.

### 3. Publish the game

```shell
cd /root/compile/DasErbe2
dotnet publish src/Erbe2/Erbe2.csproj \
  --configuration Release \
  --runtime linux-arm64 \
  --self-contained true \
  --output .artifacts/publish/Erbe2-linux-arm64 \
  -p:PublishReadyToRun=false \
  -p:TieredCompilation=false \
  -p:PublishAot=true
```
