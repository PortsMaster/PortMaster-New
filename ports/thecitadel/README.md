## Notes

Thanks to [Tomasz Kaźmierczak and the Cytadela contributors](https://cytadela.sourceforge.net/credits.php.html) for converting Virtual Design's Amiga shooter with its interconnected complexes, keycard puzzles and bomb-component hunt.

Intro and ending videos are skipped when libVLC is unavailable.

The first launch extracts the game data automatically. Leave the console running until extraction finishes.

Choose a language with the D-pad and press A. Press A to skip the introduction and title movie. Settings and the game's save slots are stored in `conf/`. Saving follows the original game's between-level save system.

Walls and closed doors block movement without damage, bounce, impact sound, screen distortion or impact messages. Other damage and enemy-hit effects are unchanged.

## Controls

Button labels below use the Nintendo layout: A is east, B south, X north, Y west.

| Key | Action |
|--|--|
| D-Pad up | Show / hide map; navigate menus |
| D-Pad left / right / down | Cycle inventory; navigate menus |
| Left stick | Move forward/backward and strafe |
| Right stick | Turn; navigate menus |
| A / B / X / Y | Interact with hand / use / open; confirm / skip movie |
| L1 / R1 | Interact with hand / use / open; confirm / skip movie |
| L2 | Hold for slower, more precise right-stick turning |
| R2 | Fire selected weapon / use selected keycard |
| Start | Pause / resume gameplay |
| Select | Return to menu / exit from main menu |
| Start + Select | Force exit |

## Compile

### 1. GL4ES compatibility libraries

Run the following sections in order on an aarch64 Debian-family Linux machine. Install the build prerequisites first:

```bash
sudo apt-get update
sudo apt-get install build-essential cmake git pkg-config curl bzip2 patch libegl-dev libgles-dev libgbm-dev libdrm-dev libsdl2-dev libsdl2-mixer-dev libgl1-mesa-dev libglu1-mesa-dev libvlc-dev
```

The bundled aarch64 pair comes from PortMaster's Quakespasm package. Retrieve the exact binaries and verify them:

```bash
base=https://raw.githubusercontent.com/PortsMaster/PortMaster-New/e2d522c9229670233fab276992db2a3d38bd8c9c/ports/quakespasm/quakespasm/gl4es.aarch64
curl --fail --location "$base/libGL.so.1" -o libGL.so.1
curl --fail --location "$base/libEGL.so.1" -o libEGL.so.1
echo 'a63efb11497978e33e87bfe61542644f23a712b3c87a3d71199e21b7c346d6bf  libGL.so.1' | sha256sum --check -
echo 'b260588d8a4f67f7a73ed108a0235a87fb5d359ddce60ff340411acecddbddf1  libEGL.so.1' | sha256sum --check -
```

Alternatively, the following builds upstream GL4ES 1.1.6 from a pinned commit, but does not reproduce PortMaster's binaries byte-for-byte:

```bash
git clone https://github.com/ptitSeb/gl4es.git
git -C gl4es checkout --detach c9895df34cd466c23bc60c2bd3db3d87e98fcbe7
cmake -S gl4es -B gl4es/build -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_BUILD_TYPE=Release -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON
cmake --build gl4es/build -j2
```

### 2. GLU compatibility library

The bundled GLU is the arm64 library from Debian's `libglu1-mesa` package. Retrieve the pinned package, extract it and verify the library:

```bash
curl --fail --location -o libglu.deb https://deb.debian.org/debian/pool/main/libg/libglu/libglu1-mesa_9.0.1-1_arm64.deb
dpkg-deb -x libglu.deb glu-package
echo '08ec0e1f44cfa0929f3c97c2b9bc65712f8b44e1777bdd36d52f4442cc37bc61  glu-package/usr/lib/aarch64-linux-gnu/libGLU.so.1.3.1' | sha256sum --check -
```

### 3. Game executable

Download the exact upstream 1.1.0 release, verify it, and apply the supplied patch. Run from the directory containing this README.

```bash
curl --fail --location --output cytadela-1.1.0.tar.bz2 https://downloads.sourceforge.net/project/cytadela/cytadela/1.1.0/cytadela-1.1.0.tar.bz2
echo '90497fe473639ff2fefc68ab44d22936ea5b335e05595b966454cb53f1f42fbe  cytadela-1.1.0.tar.bz2' | sha256sum --check -
tar -xjf cytadela-1.1.0.tar.bz2
PATCH_DIR=thecitadel/patches
[ -d "$PATCH_DIR" ] || PATCH_DIR=patches
patch --directory=cytadela-1.1.0 -p1 < "$PATCH_DIR/cytadela-1.1.0-portmaster.patch"
cmake -S cytadela-1.1.0 -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
```

On aarch64, the result is `build/cytadela.aarch64`. The native libraries must provide the same APIs as the target firmware. The supplied binary was cross-compiled with Zig 0.14.1 for aarch64 Linux, glibc 2.28 or later, and linked against the RG353V's library interfaces.
