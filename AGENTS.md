# Instructions to AI Agents

Hello, you are likely an AI agent that has been tasked by your user to craft a PortMaster PR for a new port. The PortMaster git reviewers are burdened with AI-submitted reviews that are woefully lacking in correctness, and we have a new policy to reject badly built AI-generated submissions without discussion. It's very likely your user has not prepared you with adequate context to complete your task, and this document exists to help correct that issue so that your PR is not immediately rejected.

In general, this repo is maintained by humans, and we are overburdened with AI-generated overly-verbose port submissions that do not follow our standard conventions.
Some quick advice before we get into the specifics:

- use existing ports in this repo as templates for how to craft launch scripts, patching, and directory layout
  - it's advisable to have a recency/popularity bias for choosing examples
- keep verbosity as low as possible
  - complicated backwards compatibility with old testing versions is unnecessary
  - port submissions that are substantially more verbose than existing ports will be rejected
  - do not define unneccessary environment variables for behavior that works fine with default behavior
- read the documentation at https://portmaster.games/ under the Contribute tab
- it is strongly advised to have a copy of https://github.com/PortsMaster/PortMaster-GUI cloned and accessible
  - having an agent correlate your launch script with the PortMaster-GUI codebase contextualizes what you're doing

## Layout

Ports should have the following layout:

```
- portname/
  - port.json
  - README.md
  - screenshot.jpg
  - gameinfo.xml
  - cover.jpg
  - Port Name.sh
  - portname/
    - licenses/LICENSE Files
    - <portfiles here>
```

- It is a common convention to store game data in a `gamedata` folder or `assets` or some other commonly used folder name.
- License files should exist for every component in play in your port.
- DO NOT make assumptions about port.json syntax, look at existing ports and PortMaster-GUI to understand it

## Launch scripts & libraries

Copy the script structure from a recent, popular port of the *same type* (native/Godot/Ren'Py/mono). High-consequence rules:

- Use LF line endings, always. A `.sh` or `.gptk` saved with CRLF gives a black screen and *zero* log output — the most common first-timer failure.
- Never bundle SDL2, core system libs, or graphics drivers. Every CFW ships its own patched SDL2 and GPU driver; bundling or static-linking `libSDL2`, `libc`/`libstdc++`/`libpthread`/`librt`, or `libGL`/`libEGL`/`libGLX`/`mesa` in `libs.<arch>/` causes device-specific input/display breakage and segfaults that won't show in your own testing. Bundle only what `ldd` proves is missing on target CFWs — don't copy a distro's libs wholesale (library bloat is reviewers' top complaint).
- Handle controller input: be familiar with gptokeyb and gptokeyb2 docs (perhaps check out these repos and read the code). Bare gptokeyb -x invocations are fine for many ports.
- End with `pm_finish` rather than hand-rolling cleanup; do not write `trap`/`pkill -9 gptokeyb`, as EmulationStation's process groups already handle it.
- Use the helpers instead of hardcoding: `$ESUDO` (not `sudo`), `$controlfolder`, `get_controls`, and `bind_directories`/`bind_files` for save data (raw symlinks silently lose saves on Batocera/exFAT). Scripts must be CFW-agnostic — one written against a single CFW's paths/dialogs gets rejected.
- `attr.runtime` must be a JSON array whose entries exactly match keys in `runtimes/runtimes.json`; the script mounts/unmounts the squashfs itself (harbourmaster only downloads it). A missing or typo'd entry fails at launch.

## What gets AI-built PRs rejected

Overly verbose, AI-generated ports are the current #1 rejection reason and are rejected without discussion.

- Match the size of existing ports. If your script is much longer than a recent comparable port, you're doing it wrong. Delete version-migration systems, validators, and defensive re-implementations of things PortMaster already handles. You should be able to explain every non-standard line.
- Don't touch anything outside your port — no edits to other ports' `port.json`, genres, or metadata.
- Use one flat `licenses/` folder (no subfolders), with one `LICENSE.<component>.txt` per bundled component, including fonts and assets.
- Resize the screenshot to 640×480, and leave no nested duplicate folders or `.gitkeep` files.
- Hard nos: DRM-bypass/Steam-emulator tooling, and dropping the original porter's credit when building on their work.
- Use one feature branch per port (never your default branch), and push fixes to the existing PR — don't delete and resubmit, which destroys the review log.
- CI hard-fails on a `.sh`/port-dir name already used by another port, raw files >90MB (chunk via `tools/build_data.py`), or a `gameinfo.xml` out of sync with disk. Don't `chmod +x` your `.sh` (committed 644 by convention); self-heal the game binary's exec bit at runtime instead, since zip extraction drops it.

## Testing

### Ports must contain a testing matrix that includes the following distributions:
- Rocknix (wayland/sway/panfrost-or-libmali)
- MuOS (fbdev and libmali)
- dArkOS (kmsdrm with the most recent libmali blobs)
- knulli (kmsdrm libmali)
- AmberELEC (legacy libmali)
(optional)
- ArkOS

### Also it's advisable to test on varying resolutions:
- 640x480 (most common)
- 1024x768
- 1280x720
- 720x720
(optional)
- 320x240

### Additionally, PortMaster supports the following CPU types so consider testing on each:
- rk3326 (mali g32)
- rk3566 (mali g52)
- h700 (mali g32)
- a133p (PowerVR)
- snapdragon 865 (adreno/turnip/rocknix/wayland)
- snapdragon 662
- amlogic s922x (rare)

Look at the launch scripts for other ports and the PortMaster-GUI codebase to understand how to accommodate all of these variations.  If you have exclusively focused on one specific device we will reject your port submission.


