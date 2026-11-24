## Notes

Thanks to [Nexile](https://nexile.se/) for creating Jump King, a one-button precision platformer where every charged jump and every landing has to be earned.

Download and copy the GOG DRM free version 1.06 of the game into the ports gamedata folder

Steam copies are **not** supported: only the DRM-free GOG build is supported.

**Use a spare copy of your GOG folder.** The first launch converts the textures in `Content/` to ASTC in place, so point the port at a copy rather than your only copy of the game.

The port's own scripts, patches and stubs are covered by `licenses/LICENSE-port.txt`; bundled third-party components keep their own licenses in `licenses/`.

## Controls

| Key | Action |
|--|--|
| D-Pad / Left Stick | Move |
| A | Jump |
| Start | Pause |

## Compile

The game itself is proprietary and is not included. The port expects a clean GOG Jump King 1.06 install. Run the commands below from the port checkout root.

### MonoGame DesktopGL 3.8.0.1641

Source: the `MonoGame.Framework.DesktopGL` 3.8.0.1641 NuGet package at <https://www.nuget.org/packages/MonoGame.Framework.DesktopGL/3.8.0.1641>. Copy `lib/netstandard2.0/MonoGame.Framework.dll` from it to `dlls/`.

```bash
curl -L -o monogame.nupkg \
  https://www.nuget.org/api/v2/package/MonoGame.Framework.DesktopGL/3.8.0.1641
unzip -q monogame.nupkg 'lib/netstandard2.0/MonoGame.Framework.dll'
cp lib/netstandard2.0/MonoGame.Framework.dll dlls/
```

### gl4es with ASTC texture support

Source: <https://github.com/ptitSeb/gl4es> at commit `5ed70214ae6f163926f0d8416fc3d855a313c9fa`, patched with this port's `patches/gl4es-astc.patch`. Copy the built `libGL.so.1` and `libEGL.so.1` into `gl4es.aarch64/`.

```bash
git clone https://github.com/ptitSeb/gl4es.git
cd gl4es
git checkout 5ed70214ae6f163926f0d8416fc3d855a313c9fa
patch -p1 < ../patches/gl4es-astc.patch
mkdir build && cd build
cmake .. -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON \
  -DCMAKE_BUILD_TYPE=Release
make -j"$(nproc)"
```

### ASTC texture helper

Source: this port's `patches/jk_astc_patch.c` (and `tools/astcenc`, built from astc-encoder 3.3 below). Copy the compiled helper into `tools/`.

```bash
aarch64-linux-gnu-gcc -O2 -o jk_astc_patch patches/jk_astc_patch.c
cp jk_astc_patch tools/
```

The helper uses an `astcenc` 3.3.0 binary built from the ARM astc-encoder release at <https://github.com/ARM-software/astc-encoder> (tag `3.3`). Copy the built `astcenc` into `tools/`.

```bash
git clone https://github.com/ARM-software/astc-encoder.git
cd astc-encoder
git checkout 3.3
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
  -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++
cmake --build build --target astcenc -j"$(nproc)"
```

### Shader

Source: this port's `patches/Mask.fx`, an OpenGL-compatible replacement for the game's `Mask` effect. Compile it and copy the result to `tools/Mask.xnb`:

```bash
dotnet tool install --global dotnet-mgcb --version 3.8.0.1641
mgcb /platform:DesktopGL /outputDir:artifacts /intermediateDir:obj patches/Mask.fx
cp "$(find artifacts -name Mask.xnb | head -n 1)" tools/Mask.xnb
```

First-launch setup copies `tools/Mask.xnb` into the player's `Content/shaders/` folder and the port's DLLs from `dlls/` into `gamedata/`.

### Executable patch

Source: this port's `patches/JumpKing.mm.cs` and `patches/JumpKing.mm.csproj`. The executable patch is a MonoMod patch assembly, `patches/JumpKing.mm.dll`. It adds the entity lookup cache, throttles the ambience scan, and disables the optional GOG Galaxy integration (achievements and stats), so the Galaxy DLLs are never loaded.

On first launch the port weaves the patch into a copy of the player's own `JumpKing.exe` with the bundled `monomod/MonoMod.exe` (run on the PortMaster Mono runtime) and checks the copy for the `MonoModAdded` marker. It then converts the textures, and only after both succeed replaces `JumpKing.exe` with the patched copy. A failed setup never modifies the original executable. Only the patch assembly is shipped; the game executable is always built from the user's own GOG files.

To rebuild the patch assembly, put a clean GOG `JumpKing.exe` in `gamedata/`, then run from the port checkout root:

```bash
dotnet build patches/JumpKing.mm.csproj -c Release
cp patches/bin/Release/JumpKing.mm.dll patches/JumpKing.mm.dll
```

The `monomod/` folder contains unmodified MonoMod 22.5.1.1 release binaries with their Mono.Cecil 0.11.4 and 0Harmony 1.2.0.1 dependencies, all MIT licensed; see `licenses/LICENSE-MonoMod.txt`, `licenses/LICENSE-Mono.Cecil.txt` and `licenses/LICENSE-Harmony.txt`.

### Stub DLLs

`dlls/SlimDX.dll` and `dlls/System.Windows.Forms.dll` are small headless stubs written for this port. Their sources are `patches/SlimDX.stub.cs` and `patches/System.Windows.Forms.stub.cs`: DirectInput reports no devices, and message boxes are logged to stderr instead of opening a window. `patches/slimdx.pub.snk` and `patches/ms.pub.snk` contain only the public keys of the shipped assemblies, so a rebuild keeps the same strong-name identity (delay signing only; no private key is needed).

With a .NET SDK and Mono 4.5 reference assemblies (for example the PortMaster Mono runtime mounted at `~/mono`), run from the port checkout root:

```bash
chmod +x patches/build-stubs.sh
MONODIR="$HOME/mono" patches/build-stubs.sh
```

`MONOREF`, `CSCDLL` and `DOTNET` can be set if your Mono references or Roslyn compiler are elsewhere.

## Saves

Saves are kept in `gamedata/Content/Saves` and `gamedata/Content/SavesPerma`. Back them up before replacing or reinstalling the game files.
