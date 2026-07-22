## Notes

Thanks to [CodeEngine](https://github.com/codengine/DasErbe) for the original C#/.NET reimplementation of *Das Erbe*.

## Controls

| Button | Action |
|--|--|
| Left stick | Move mouse cursor |
| A | Left click |
| B | Right click |
| X (hold) | Slow/precise cursor movement |
| Y | **Highlight hotspots** |
| Start | Enter / confirm |
| Back | Escape |

## Build

This port packages the reimplementation as a self-contained Native AOT build (`linux-arm64`) with [gl4es](https://github.com/ptitSeb/gl4es) bundled for OpenGL-to-GLES translation, no Westonpack and no bundled SDL2 (provided by the CFW). Everything below runs inside the aarch64 PortMaster compile chroot (`/root/compile`); this is a native build, not a cross-compile, since the chroot itself is aarch64.

### 1. Install the .NET 10 SDK

```shell
curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --channel 10.0 --install-dir /root/dotnet
export DOTNET_ROOT=/root/dotnet
export PATH="/root/dotnet:$PATH"
```

`dotnet --list-sdks` should show `10.0.x`; `dotnet --info` should report RID `linux-arm64`.

### 2. Build gl4es

```shell
cd /root/compile
git clone --depth 1 https://github.com/ptitSeb/gl4es.git
cd gl4es
mkdir build && cd build
cmake .. -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON
make -j"$(nproc)"
```

Produces `lib/libGL.so.1` and `lib/libEGL.so.1`.

### 3. Publish the game

```shell
cd /root/compile/DasErbe_pm
dotnet publish src/Game.Desktop/Game.Desktop.csproj \
  --configuration Release \
  --runtime linux-arm64 \
  --self-contained true \
  --output artifacts/publish/linux-arm64 \
  -p:PublishReadyToRun=false \
  -p:TieredCompilation=false \
  -p:EnableNativeAot=true
```
