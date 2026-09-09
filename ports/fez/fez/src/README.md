# Source for the DLLs this port ships

`dlls/FNA.dll` and `dlls/FezPatches.dll` are not upstream builds — they are built
from what is in this folder, and this is everything needed to reproduce them. FEZ's
own assemblies are never patched or rebuilt: both DLLs sit beside the game and are
picked up at launch. The launch script does delete the 2016 Mono and FNA
redistributables FEZ ships with, since these supersede them.

Building either needs Mono's C# compiler. Debian's `mono-devel` is enough.

## FNA.dll — FNA 22.03 with three FEZ-specific changes

FEZ 1.12 predates FNA3D and does not run on a current FNA, so the port carries its
own build of the last release that suits it.

```bash
git clone --depth 1 --branch 22.03 --recurse-submodules --shallow-submodules \
    https://github.com/FNA-XNA/FNA.git fna-22.03
cd fna-22.03
git apply ../fna/fna-22.03-fez.patch
cp -r ../fna/added/. .
python3 ../fna/build-rsp.py
mkdir -p bin/Release && mcs @build.rsp
```

**`lib/Vorbisfile-CS/Vorbisfile.cs`** (added) — FNA dropped its global `Vorbisfile`
class when Song playback moved to stb_vorbis, but FEZ's `OggStream` calls it directly
for all music. This is Vorbisfile-CS at commit `844fbd1a`, the revision FNA pinned at
tag 17.01. It has to be that revision: current master declares `vorbis_info.rate` as
`IntPtr` and `ov_read` returning `IntPtr`, while FEZ's IL demands `long` for both, so
a newer copy throws `MissingFieldException` at the first music cue.

**`src/Graphics/IGLDevice.cs`** (added) and the `GraphicsDevice.GLDevice` field type —
FEZ reflects into that private field and reads `SupportsHardwareInstancing` and
`MaxMultiSampleCount` off it through an `IGLDevice` interface that FNA3D removed.
The field becomes a small class wrapping the FNA3D handle, with implicit conversions
so the rest of FNA is untouched.

**`src/Game.cs`** — adds `ModEntryPointAttribute` and, just after the graphics device
is created and before `Initialize`, loads the assembly named by `FNA_PATCH` and calls
`Main` on every type carrying that attribute. This is how `FezPatches.dll` gets in;
the convention matches JohnnyonFlame's FNAHacks, so patch assemblies are
interchangeable. After `CreateDevice` is what lets those patches read graphics state,
and before `Initialize` is what lets them patch `SettingsManager.InitializeResolutions`
in time.

## FezPatches.dll — the runtime patches, loaded through FNA_PATCH

From this directory again, with the FNA build above in `fna-22.03/`:

```bash
mcs -target:library -out:../dlls/FezPatches.dll -optimize+ -sdk:4.5 \
    -r:fna-22.03/bin/Release/FNA.dll -r:../dlls/0Harmony.dll FezPatches.cs
```

Ten Harmony patches, all reasoned about in the comments in `FezPatches.cs`:

- **View scale.** FEZ composes for 1280x720 and floors its view scale at 1.0, so below
  720p it crops its own composition instead of scaling it down. Recomputing the scale
  without the floor letterboxes the whole picture into a native-sized backbuffer.
- **Panel resolution.** FEZ keeps only display modes of at least 1280x720, so on a
  handheld the list is empty and its video menu, which indexes that list unguarded,
  throws on the first input. The patch offers the panel's own width at 16:9 instead.
- **Intro splashes.** Blitted at one texel per pixel with only a 1440p asset variant,
  so below 720p they run off the screen. The textures are shrunk once, at load.
- **Intro teardown.** Applying video settings during the intro leaves a
  `TileTransition` alive, polling a predicate that reads `Intro.IntroPanDown` — a
  field the intro nulls as it finishes, so the game dies with a
  `NullReferenceException` a frame after "Intro is done and game is go!".
  `TileTransition.Draw` treats a null predicate as "proceed", so the guard answers
  the same way once the intro has gone.
- **Lazy paks** (six patches). FEZ reads `Music.pak`, `Updates.pak` and `Other.pak`
  into memory whole and holds ~370 MB for the session, which is more than a 1 GB
  device can spare. These index the paks and read each asset when it is asked for.
  `FEZ_LAZY_PAKS=0` restores the original behaviour, `FEZ_LAZY_PAKS=debug` traces
  what is indexed and read.

## Seeded settings

`../conf/Settings` ships pre-written, because FEZ's own defaults assume a desktop.
The game rewrites the file the moment anything is applied in its menus, so these are
starting points rather than enforcement:

- `scaleMode "FullAspect"` — the picture lands on the panel pixel for pixel. The
  alternative, Supersampled, is the only mode that escapes FEZ's view-scale floor
  without patching, and it does it by drawing at 1280 wide and scaling down: two to
  four times the work, and measurably choppy on rk3326.
- `width` / `height` are a placeholder. `UsePanelResolution` overwrites them from the
  display at every launch, so the seeded pair only matters if that patch fails.
- `lighting false` — `LightingPostProcess` is a fullscreen pass, so it is the largest
  per-frame cost left once the render size is right, and testers on low-end hardware
  report a clear gain without it. It is one toggle in FEZ's Video menu for anyone who
  wants the intended look back.
- `hardwareInstancing true` — deliberately left on. It selects which shader FEZ loads,
  `HwInstancedAnimatedPlaneEffect` against `InstancedAnimatedPlaneEffect`, so it
  changes how instance data reaches the GPU rather than how many fragments are shaded;
  the non-hardware path passes instances as shader constants and splits a batch across
  more draw calls. `InitializeCapabilities` already forces it off where the driver
  cannot do it, so turning it off by hand only affects devices where it works.
- `disableSteamworks true` — there is no Steam client on these devices.

## Bundled libraries

`../libs/` carries `libFAudio.so.0` and `libFNA3D.so.0`, as every FNA port does, plus
three that no other FNA port here ships: `libvorbisfile.so.3`, `libvorbis.so.0` and
`libogg.so.0`. They are not a wholesale copy of a distro's libs.

FEZ 1.12 decodes its music by calling Vorbisfile directly from `OggStream` —
`FNA.dll.config` maps `libvorbisfile.dll` to `libvorbisfile.so.3` — which is why the
FNA build restores the `Vorbisfile` binding described above. Modern FNA decodes Ogg
with stb_vorbis and needs no vorbis shared library at all, so celeste, chasm, owlboy
and the rest legitimately ship none. `libvorbis.so.0` and `libogg.so.0` are there
because `libvorbisfile.so.3` links against them (`readelf -d`), not on their own
account.

Some firmware provides these already — Rocknix has `libvorbisfile.so.3` and
`libogg.so.0` in `/usr/lib` — and `FEZ.sh` puts `libs/` first on `LD_LIBRARY_PATH`,
so the bundled copies win where they are present. They are 267 KB together, against a
hard failure at the first music cue on any CFW in the matrix that lacks them, which is
why they ship rather than being assumed.

`libtheorafile.so`, which the other FNA ports do carry, is deliberately absent:
Theorafile is reachable only through `VideoPlayer` and `Video`, and FEZ touches
neither.

## Licences

`../licenses/` carries one file per bundled component. `LICENSE.fezpatches.txt`
covers `FezPatches.cs` (MIT); FNA and the libraries compiled into it keep their own.
