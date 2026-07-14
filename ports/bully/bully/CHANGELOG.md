# Bully package changelog

## Final (2026-07-14)

- Confirmed PortMaster autoinstall compatibility against the ArkOS
  HarbourMaster parser and the same root layout used by working official
  packages. The immutable manifest now excludes only the launcher and
  `port.json`, which HarbourMaster legitimately signs/updates during install.
- Reworked the PortMaster-visible metadata: the public card no longer carries
  release/build version numbers and now explains legal data setup, first-run
  extraction and preservation of user data during updates.
- Connected the packaged artwork to the schema-v4 cover, screenshot-card and
  thumbnail metadata. The current ArkOS PortMaster build ignores local image
  metadata and still needs `bully.screenshot.png` in its source catalog; the
  ZIP does not modify PortMaster's private cache.
- Replaced the inherited cover with the dedicated 4:3 Bully artwork selected
  for publication; the gameplay screenshot remains available as the secondary
  preview.
- Contained the face-button heuristic: the tested ArkOS `R36T/K36S`
  device-tree profile swaps both pairs, while other reported R36S/GO-Super
  profiles preserve the CFW mapping. Trustworthy evdev semantics still convert
  label-style mappings to position, so the Ark fix is not applied globally.
- Added the proven GTA ordinal normalizer behind a contained signature: matching
  VID/PID, external USB/Bluetooth bus, BTN_GAMEPAD and BTN_C/BTN_Z. Modern,
  selection is signature-based and never selected by kernel version.
- Corrected the Android input contract for L3/R3 (IDs 12/13). L2/R2 now travel
  only through the native trigger axes used by the engine for previous/next
  item.
- Added `weapon_switch=native|touch`. Native is the default and emits no touch,
  preventing the touchscreen HUD from appearing; touch keeps the legacy
  coordinate fallback.
- Updated GPTokeyb to editable V3 with neutral face slots, native trigger axes
  and safe migration of only stock older maps. Customized V2 maps survive; the
  stock detector also works with the older BusyBox/mawk shipped by CFWs.
- Confirmed that the Rockstar logo and Jimmy/car/city opening sequence still
  exist in the original engine flow. Playback remains disabled until a Linux
  H.264/AAC movie/JNI backend is implemented; proprietary videos are not in the
  package.

## V12 RC (2026-07-12)

- Made the existing `use_gptk=on/off` switch a complete fallback: `off` keeps
  native SDL, while `on` starts PortMaster gptokeyb and routes every editable
  face/shoulder/trigger/D-pad/analog mapping through `bully.gptk` without a
  second native face remap. User maps now survive ZIP updates through a shipped
  `bully.gptk.default` template.
- Added a one-time, marker-based migration for legacy gptokey maps. An unmarked
  v1 file is preserved as `bully.gptk.v1-backup` before the correct editable-v2
  default is activated; existing v2 user remaps remain untouched.
- Corrected native DarkOS/ArkOS label detection to swap both A/B and X/Y while
  leaving shoulders and triggers unchanged.
- Replaced fixed-delta `SDL_Delay(16)` pacing with measured monotonic delta and
  absolute 60 Hz pacing for a stable host heartbeat.
- Fixed the opening in-engine cutscene skipping most of the car arrival and
  leaving speech behind the animation on slower storage/devices. Early
  multi-second clock hops are absorbed into a persistent visual-clock offset;
  normal frame deltas, gameplay and later cutscenes remain unchanged.
- Restored muOS portability in first-run setup: standalone GNU `stat` is no
  longer required. File sizes use a validated GNU, BusyBox, BSD, Python or
  `wc` backend, and the chosen path is recorded in `setup.log`.
- Corrected `port.json` from unsupported schema 5 to the current PortMaster
  schema 4, restoring offline/autoinstall parsing on muOS and other CFWs.
- Confirmed that a complete V11.2 installation upgrades in place without a
  fresh install or another APK; the old failure happened before migration.
- Added a tracked, reproducible PortMaster package source with a strict file
  allowlist, fixed timestamps, internal payload hashes and final archive checks.
- Synchronized the setup version, PortMaster metadata and user documentation to
  `V12 RC` while retaining the stable `bully.zip` package identifier.
- Corrected Play Store split instructions: users must copy every APK returned by
  the package manager, including all `split_data_*` files.
- Removed the unverified claim that the legacy OBB layout is a supported V12
  source. Complete merged APKs, complete split sets and complete bundles remain
  the documented paths.
- Documented in-place V11 updates and the exact recovery required when an older
  install contains assets but is missing the arm64 game libraries.
- Added the whitelisted `bully.conf` template, including
  `stream_distance=auto|50|60|70|75|80|100`; numeric choices map to
  `BULLY2_STREAM_DISTANCE_PCT`, while `auto` leaves the override unset.
- Ship configuration as `bully.conf.default`; the launcher creates
  `bully.conf` only when absent, so installing a later ZIP cannot overwrite the
  user's tested settings.
- Added the data-integrity validator to the package contract so a release cannot
  be built without the V12 BuildID/index validation helper.
- Reworked first setup as a staged transaction. Libraries must come from one
  arm64 source, every ZIP/IDX pair stays together, failed validation preserves
  the user's source files, and an atomic marker enables upgrades without an APK.
- Made menu-patch generation mandatory and report missing Python or incompatible
  data as a setup failure instead of silently continuing.
- Reworked first-run feedback so the setup screen opens before the full APK CRC
  pass and shows separate validation and extraction bars with real byte-level
  progress. The old two-line protocol remains accepted.
- Made the setup renderer strictly optional: accelerated SDL falls back to its
  software renderer, and failed or unresponsive UI processes are bounded and
  cannot stop the headless extractor or its log.
- Fixed `pipefail`/`SIGPIPE` false rejections when reading correct ZIP metadata,
  and gave every staging, rollback and progress transaction a unique identity
  so PID reuse cannot skip recovery data.
- Made ZIP-entry detection verify parsed names instead of relying on Info-ZIP's
  `-Z` extension or exit codes, preserving correct behavior with BusyBox unzip.
- Updated the setup renderer for `V12 RC` and small 320x240 displays.
- Replaced the ineffective zero-GUID controller fallback with SDL's `default`
  mapping and added opt-in raw/logical input diagnostics.
- Corrected the real source of the sharp-HUD/blurry-world problem: the mobile
  performance profile forced a 0.5 internal 3D scale on Mali-400/450/470 and
  several Mali-T/G families regardless of RAM. Nominal 2 GB devices now select
  native 1.0 scale automatically; the low-memory tier preserves the original
  profile.
- Unified the nominal 2 GB boundary at 1700 MB of Linux `MemTotal`. That tier
  selects High source textures, native streaming distance and ES3 renderer when
  a real ES3 context is available. ES3 creation still has a complete ES2
  fallback ladder.
- Carried the Low/Medium texture memory path to RendererES3 without shrinking
  one-level render targets. Fixed ATC interpolated-alpha uploads, preserved
  compressed mip chains and enabled safe NPOT mip generation on GLES3.
- Preserved native cubemap faces/mips in RendererES2 and restricted mip
  replacement to 2D textures that were actually reduced.
- Made `trilinear=on` meaningful in High as well as Low/Medium: complete safe
  mip chains use trilinear filtering. `off` forces bilinear; incomplete,
  cutout and render-target textures remain protected from black/incomplete
  sampling.
- Removed ineffective periodic low-memory calls and redundant transition
  cleanup from the high-memory tier while retaining the V11.2 safeguards below
  the nominal 2 GB boundary.
- Added patch revisions, payload-size markers, two-phase data commits and
  reboot/SIGKILL recovery for orphan staging/backup directories.
- Added complete Apache-2.0, MIT and LGPL notices for all code and libraries
  shipped in the compatibility package.
- Package gates now reject APKs, bundles, OBBs, extracted game libraries and
  `assets/data_*` payloads before release creation.

The 2 GB automatic graphics tier remains release-candidate behavior until the
private device matrix is complete; every decision can be isolated through
`bully.conf` without replacing the binary.
