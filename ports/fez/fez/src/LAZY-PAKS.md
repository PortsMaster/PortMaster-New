# Lazy paks: stop FEZ holding its paks in RAM

Implemented in `FezPatches.cs`, beside this file. This is the design and the evidence behind it.
Prompted by an R36S/dArkOS report of the game closing itself during the tutorial
without zram, a Trimui Smart Pro on Knulli where `mono` was SIGKILLed after the
intro, and a community suggestion to convert textures to ASTC and shrink the audio —
see the "Rejected" section for why neither is the lever it looks like.

Set `FEZ_LAZY_PAKS=0` to get the old behaviour back, or `FEZ_LAZY_PAKS=debug` to have
the indexes and each music read reported on stderr, which `FEZ.sh` tees into
`log.txt`.

## The problem

FEZ keeps about 370 MB of pak bytes resident for the whole session, in two
`Dictionary<string, byte[]>`, regardless of what is actually being used. The
`FezEngine.il` line numbers below are into `monodis FezEngine.dll` output, so
they can be checked against the game's own assemblies:

| Cache | Filled by | Holds |
|---|---|---|
| `SoundManager.MusicCache` | `InitializeLibrary` (`FezEngine.il:84459`) | all of `Music.pak` — 130 Ogg tracks, 193.5 MB |
| `MemoryContentManager.cachedAssets` | `LoadEssentials` + `<Preload>m__0` (`FezEngine.il:165555`) | `Essentials` + `Updates` + `Other` — 2790 assets, 176.9 MB |

On a 1 GB handheld that is most of what the CFW leaves free, before a single texture
is decoded, and it is why two devices were being killed in the first few minutes.
Peak RSS driven into gameplay falls from ~700 MB to ~350 MB with these patches; the
per-device numbers are in the port's submission notes. What follows is why the caches
can be bypassed at all.

## What the caches are actually for

`OpenStream` hands out `new MemoryStream(bytes, 0, len, false, true)` over the cached
array, and `FutureTexture2DReader.Read` (`FezEngine.il:57718`) keeps
`((MemoryStream) input.BaseStream).GetBuffer()` as `FutureTexture2D.BackingStream`,
with a `StreamOffset` per mip level, so texture uploads can be deferred and read back
out of the cache later. That sharing is the reason the design exists.

It does not apply to the assets that matter. The texture XNBs are LZX-compressed
(header flags `0x81`), so FNA decompresses them into its own `MemoryStream` and
`BackingStream` points at that, not at the cache. The 370 MB is held to serve a
sharing optimisation that the compressed assets never use, and that the sounds and
music do not use at all.

## Constraints found while reading the consumers

- **The stream must be a `MemoryStream`, created `publiclyVisible: true`.**
  `FutureTexture2DReader` does an `isinst MemoryStream` then `GetBuffer()`, and
  `OggStream`'s constructor (`FezEngine.il:169352`) calls `GetBuffer()` too. Handing
  back a `FileStream` slice would `NullReferenceException` in the first and fail to
  compile against the second, whose parameter is `MemoryStream`, not `Stream`.
- **`MusicCache` has exactly one consumer**: `SoundManager.GetCue`
  (`FezEngine.il:85592`), which is `MusicCache[key]` → `MemoryStream` → `OggStream`.
- **`cachedAssets` has six**: the ctor, `LoadEssentials`, `<Preload>m__0`,
  `OpenStream`, `AssetExists`, `get_AssetNames`. Nothing else in either assembly.
- **First pak wins.** `LoadEssentials` and `<Preload>m__0` both skip a name already
  present and seek past its payload, and the load order is Essentials, Updates,
  Other. An index has to resolve duplicates the same way.
- **Keys are normalised.** Content: `name.ToLower(InvariantCulture)` with `/` → `\`.
  Music: `name.Replace(" ^ ", "\\").ToLower(InvariantCulture)`.
- **`OpenStream` is called from level-loading worker threads** and takes
  `MemoryContentManager.ReadLock`. Any shared `FileStream` needs the same discipline.

## Pak format

Simple enough to index without a library:

```
int32                     entry count
per entry:
  string                  name    (BinaryWriter 7-bit length prefix, UTF-8)
  int32                   size
  byte[size]              payload
```

Payloads are raw Ogg Vorbis in `Music.pak` and XNB everywhere else. This python
walks it, and is how the numbers above were produced:

```python
import struct
def r7(f):
    n = s = 0
    while True:
        b = f.read(1)[0]
        n |= (b & 0x7f) << s
        if not b & 0x80: return n
        s += 7
with open("Content/Other.pak", "rb") as f:
    for _ in range(struct.unpack("<i", f.read(4))[0]):
        name = f.read(r7(f)).decode()
        size = struct.unpack("<i", f.read(4))[0]
        print(name, size)
        f.seek(size, 1)
```

## The patch set

Six Harmony patches in `FezPatches.dll`, alongside the viewport ones. Every one is a
cache-policy change: on a miss the data is read from the pak, so the worst failure
mode is more I/O rather than a wrong result.

| Target | Kind | Does |
|---|---|---|
| `MemoryContentManager.Preload` | prefix, skip original | index `Updates.pak` then `Other.pak` instead of reading them (160 MB not read) |
| `MemoryContentManager.OpenStream` | prefix | on a `cachedAssets` miss, read that one asset from its pak and return it |
| `MemoryContentManager.AssetExists` | prefix | answer from the index as well as the dictionary |
| `MemoryContentManager.get_AssetNames` | prefix | return dictionary keys plus index keys |
| `SoundManager.InitializeLibrary` | prefix, skip original | index `Music.pak`, leave `MusicCache` an empty dictionary |
| `SoundManager.GetCue` | prefix, run original after | ensure the requested key is in `MusicCache`, evicting all but the last few |

`LoadEssentials` is deliberately left alone. It is 16.9 MB, it is the always-needed
set, and leaving the hot path byte-for-byte as it is keeps the change to the parts
that are pure waste.

Eviction from `MusicCache` is safe: each `MemoryStream` holds its own reference to
the array, so a track that is still playing survives being dropped from the
dictionary. Keeping the last four or so requested tracks bounds it at a few MB while
covering the common case of ambience plus music plus a transition.

## The cost

Sound effects now come off the SD card during level load rather than being read up
front. Sounds total 162.9 MB across the whole game and a level touches a fraction of
that, so it should be small — but it is the thing to watch on the slowest loader you
have.

## If you change this

- Music must still loop, and cross-fade between ambience and music, after eviction.
- Watch `[date] Debug Log.txt` in `savedata` for `Can't find asset named` — that is
  the shape a key-normalisation mistake takes.
- Load a level, leave it, come back: assets must load again cleanly after a miss.

## Rejected

**ASTC conversion.** All the textures in all the paks come to about 10 MB packed,
because flat-colour pixel art compresses well, so it does nothing about the 370 MB.
It would cut GPU memory — the decompressed texture XNBs total ~400 MB across the
whole game — but those load per level and the tutorial touches a slice of them. The
cost is high: XNA has no ASTC `SurfaceFormat`, so it needs FNA, FNA3D and
`Texture2DReader` changes on top of an offline conversion the port cannot ship, and
block compression on hard-edged pixel art shows.

**Re-encoding the audio.** This one does aim at the right target — audio is ~356 MB
of the 370 MB — and 22 kHz mono effects plus lower-bitrate music would plausibly
save 200 MB+. But the port cannot redistribute converted assets, so it becomes a
conversion pass each user has to run, and it costs audio quality permanently. Lazy
paks get the same order of saving with no asset changes and no user step.

**Forcing `singlethreaded`.** Saves a couple of MB of thread stacks, which is not
the problem. It also collapses the parallel particle update in
`TrixelParticleSystems`/`PlaneParticleSystems` onto the main thread and freezes the
animation over every level load. Documented in the port README as a per-user
workaround; not a default.
