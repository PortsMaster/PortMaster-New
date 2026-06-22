# Building the Mina the Hollower port payload

This port runs the Apple-Silicon macOS build of *Mina the Hollower* via
**machismo**, replacing the Metal renderer with native GLES. The build sources
live in the `machismo-ports` workspace (`~/darling`): the loader is the
`machismo` submodule, the shim is `ports/gothic/`.

## Phase 1 (this tree): Asahi-built smoke-test payload

This payload is built with **host Asahi (Fedora aarch64)** artifacts, for the
modern-firmware test fleet. It is NOT the broad-compatibility build — that
requires the Bullseye chroot (glibc 2.31) and is a later step. Do not ship this
tree to arbitrary firmwares.

### Bundled artifacts (`mina/`)

| File | Source (in ~/darling) | Notes |
|---|---|---|
| `bin/machismo` | `machismo/build/machismo` | In-process Mach-O loader (incl. KMSDRM SDL_WINDOW_OPENGL fix in sdl_window_shim) |
| `libs/libgothic_patches.so` | `build/libgothic_patches.so` | objc/Metal shim + GLES RHI backend + engine detours |
| `libs/libsystem_shim.so` | `machismo/build/libsystem_shim.so` | libSystem.B replacement |
| `libs/libc++.so.1` | `machismo/build-libcxx/lib/libc++.so.1` | Apple-ABI libc++ (alternate SSO) |
| `libs/libc++abi.so.1` | `machismo/build-libcxx/lib/libc++abi.so.1` | dep of libc++ |
| `libs/libatomic.so.1` | `/lib64/libatomic.so.1` | dep of libc++ |
| `tools/ycd_extract` | `build/ycd_extract` | YCD shader-pak → .metallib (pure C, no deps) |
| `tools/airlift` | `~/airlift/build-rel/airlift` (Release, `-static-libstdc++ -static-libgcc`, stripped) | metallib → SPIR-V → GLSL ES 3.10 + Mali markers |
| `conf/machismo.conf` | derived from `ports/gothic/configs/machismo.conf` | libs/ relative paths, CWD=GAMEDIR |
| `conf/dylib_map.conf` | derived from `ports/gothic/configs/dylib_map.conf` | libs/ relative paths |

There is **no bundled shader corpus**: `patch/patch.bash` (run by the
PortMaster patcher UI on first launch, gated on `patch/corpus.version` vs
`gamedata/.shaders_ready`) regenerates it from the user's own
`shaders.pak.yc` into `gamedata/shaders_gles/`. Host oracle for any tool
change: extract + build against your own game copy must reproduce
`~/darling/ports/gothic/shaders_gles` byte-for-byte
(114 `.glsl` + 114 `.refl.json`, 14 clip-via-scissor + 8 composite-over +
18 font-coverage-over markers).

### Deliberately NOT bundled (use device system libs)

- **libSDL2-2.0.so.0** — the game statically links SDL2 and trampolines `_SDL_*`
  to the device's native libSDL2, which has the device-tuned KMSDRM + Mali GLES
  backend. Bundling our own would fight the device's GPU/display config.
- **libEGL / libGLESv2 / libGLdispatch** — Mali userspace drivers from the device.

### Rebuilding the bundled artifacts (host)

```bash
cd ~/darling/machismo && cmake -S . -B build && cmake --build build
cd ~/darling && cmake -S . -B build && cmake --build build   # gothic_patches + ycd_extract
cmake -S ~/airlift -B ~/airlift/build-rel -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc"
cmake --build ~/airlift/build-rel && strip ~/airlift/build-rel/airlift
```
Then re-copy the table above into `mina/{bin,libs,tools}/`.

## gamedata (user-supplied, never committed)

`gamedata/` holds only `.gitkeep` in the repo. The player drops their owned
`Mina the Hollower.app` there. For local fleet testing the bundle is copied in
by hand and left unstaged.

## TODO (cosmetic / later)

- `cover.png`, `screenshot.png` at the port root (PortMaster GUI art) — not yet added.
- Optional `splash.png` + `tools/splash` loading splash (see shotgunking).
- Release: Bullseye-chroot rebuild of all bundled binaries (incl. `airlift`,
  which needs a static LLVM 20 built in the chroot) for broad firmware support
  — the Asahi-built `tools/airlift` has a glibc 2.38 floor, so first-run shader
  generation won't run on ArkOS-class firmware until then.
