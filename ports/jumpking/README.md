## Notes

Thanks to [Nexile](https://nexile.se/) for creating Jump King, a one-button precision platformer where every charged jump and every landing has to be earned.

Download and copy the GOG DRM free version of the game into the ports gamedata folder

Steam copies are **not** supported: only the DRM-free GOG build is supported. 

## Controls

| Key | Action |
|--|--|
| D-Pad / Left Stick | Move |
| A | Jump |
| Start | Pause |

## Compile

The game itself is proprietary and is not included. The port expects a clean GOG Jump King 1.06 install. Run the commands below from the port checkout root.

### MonoGame DesktopGL 3.8.0.1641

```bash
curl -L -o monogame.nupkg \
  https://www.nuget.org/api/v2/package/MonoGame.Framework.DesktopGL/3.8.0.1641
unzip -q monogame.nupkg 'lib/netstandard2.0/MonoGame.Framework.dll'
```

### gl4es with ASTC texture support

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

```bash
aarch64-linux-gnu-gcc -O2 -o jk_astc_patch patches/jk_astc_patch.c
```

The helper uses an `astcenc` 3.3.0 binary built from the ARM astc-encoder release.

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

```bash
dotnet tool install --global dotnet-mgcb --version 3.8.0.1641
mgcb /platform:DesktopGL /outputDir:artifacts /intermediateDir:obj patches/Mask.fx
```

### Executable patch

The executable patch is a MonoMod patch assembly, `patches/JumpKing.mm.dll`, built from `patches/JumpKing.mm.cs`. It adds the entity lookup cache, throttles the ambience scan, and disables the optional GOG Galaxy integration (achievements and stats), so the Galaxy DLLs are never loaded.

On first launch the port weaves the patch into a copy of the player's own `JumpKing.exe` with the bundled `monomod/MonoMod.exe` (run on the PortMaster Mono runtime) and checks the copy for the `MonoModAdded` marker. It then converts the textures, and only after both succeed replaces `JumpKing.exe` with the patched copy. A failed setup never modifies the original executable. Only the patch assembly is shipped; the game executable is always built from the user's own GOG files.

To rebuild the patch assembly, put a clean GOG `JumpKing.exe` in `gamedata/`, then run from the port checkout root:

```bash
dotnet build patches/JumpKing.mm.csproj -c Release
cp patches/bin/Release/JumpKing.mm.dll patches/JumpKing.mm.dll
```

The `monomod/` folder contains unmodified MonoMod 22.5.1.1 release binaries with their Mono.Cecil 0.11.4 and 0Harmony 1.2.0.1 dependencies, all MIT licensed; see `licenses/LICENSE-MonoMod.txt`, `licenses/LICENSE-Mono.Cecil.txt` and `licenses/LICENSE-Harmony.txt`.

## Saves

Saves are kept in `gamedata/Content/Saves` and `gamedata/Content/SavesPerma`. Back them up before replacing or reinstalling the game files.
