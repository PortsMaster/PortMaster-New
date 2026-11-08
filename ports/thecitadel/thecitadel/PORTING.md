# Port changes

The Citadel contains an AI-assisted adaptation of Cytadela 1.1.0, originally released on 18 January 2013. The original authors and license are preserved in `licenses/AUTHORS-thecitadel.txt` and `licenses/LICENSE-thecitadel.txt`.

Changes made for this port:

- Uses The Citadel as the PortMaster package, launcher and frontend display name only. The game's own title text, source identifiers, configuration names and media retain their original names and artwork.

- Replaced SDL 1.2 window, surface, input and buffer-swap APIs with SDL2.
- Uses the firmware's SDL2, SDL2_mixer and VLC. Bundles the pinned PortMaster aarch64 GL4ES/EGL-wrapper pair and the confirmed missing GLU library for the GLES fallback, never a replacement SDL2 or device EGL driver.
- Preserves one SDL GL context across software menus, videos and gameplay when GL4ES is selected. Presents software surfaces through a textured quad using the existing GL backend. The native ROCKNIX window/surface path is unchanged.
- Explicitly selects fixed-function drawing and initializes its masks and client-array state at gameplay entry. Captured AmberELEC state showed SDL menu shader program 19 still selected at the first level draw.
- Uses gptokeyb2 instead of the original raw joystick mapping.
- Converts held-key checks to SDL2 scancodes and accumulates relative mouse events per frame.
- Replaces accumulation-buffer fades with texture-based blending.
- Adds Q/E and PageUp/PageDown weapon and keycard cycling for D-pad inventory selection without affecting movement.
- R2 fires or uses the selected keycard, L2 provides precision turning, and A/B/X/Y and L1/R1 interact or confirm. Both sticks control movement/turning. D-pad up opens the map; left/right/down cycle inventory. Select returns to the menu, Start pauses, and stick clicks are unbound. Every firmware uses the same `thecitadel.ini` mapping.
- Keeps settings and save slots in the port's `conf/` directory.
- Removes wall/closed-door collision damage and associated bounce, impact messages, sound and distortion. Enemy damage and enemy-hit effects are unchanged.
- Makes game stdout line-buffered so diagnostic messages are retained promptly.
- Handles quit/window-close events in input, queue clearing, animations, fades and delays. Video shutdown stops VLC callbacks before releasing their surfaces and mutex.
- Runs the game in the foreground and delegates mapper cleanup to `pm_finish` after the game returns, following the standard native launcher pattern.
- Adds a CMake build and ships every source change in `patches/cytadela-1.1.0-portmaster.patch`, tested against the checksummed upstream release.
- Uses a 12000 stick-to-key deadzone while retaining the existing right-stick mouse curve and all button bindings.
- Ships bulk assets in a zero-owned, dereferenced `gamedata.tar.gz`; extraction preserves the original `data/` paths and does not touch `conf/`.

The launcher uses the current standard header. Read-only inspection found that both installed PortMaster `control.txt` files already import the device/helper files and define `GPTOKEYB2`; redundant imports and the manual mapper command were removed. No firmware files are modified.

The source retains its original GL rendering backend. PortMaster's per-CFW libgl helper selects native OpenGL on ROCKNIX/Panfrost or the bundled GL4ES fallback on GLES-only firmware. Explicit SDL GL/EGL paths and persistent-context handling are enabled only when the helper selected GL4ES. No alternate renderer or modified GL4ES library is shipped.

The unchanged executable was tested at 640x480 on RG353V with AmberELEC prerelease-20261019_1835 and RG353VS with ROCKNIX 20261001/Mesa 26.2.2. Actual gameplay framebuffer captures were verified on both devices. The subsequent reference audit changes only packaging, launcher conventions, documentation and deadzones; those changes are checked locally, not deployed or launched on either console. A console reboot occurred during the initial device testing; no previous-boot journal or kernel crash record survived, so its cause is undetermined. Final device verification used EmulationStation's normal launch API, not concurrent standalone rendering or frontend-service stops.

AI-generated changes require human review before a PortMaster upstream authorship attestation can be made. This package is not an upstream PortMaster submission.
