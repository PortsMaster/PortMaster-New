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
- Removes the mid-frame GPU finish, reuses stencil references for door clipping, and avoids redundant texture-unit switching.
- Batches only adjacent same-material solid submissions while preserving triangle order. Skips framebuffer blending only for solid materials with a proven RGB alpha witness; transparent objects, blood/decal interpolation and effects retain their rendering behavior. No clock-policy overrides are installed.
- Adds Q/E and PageUp/PageDown weapon and keycard cycling for D-pad inventory selection without affecting movement.
- R1/R2 fire or use the selected keycard, L1/L2 provide precision turning, and A/B/X/Y interact or confirm. Both sticks control movement/turning. D-pad up opens the map; left/right/down cycle inventory. Start and Select share a paused quit prompt: A returns to the menu, another input resumes. A uses a distinct Home mapping so B/X/Y cannot confirm quitting. Precision turning is halved in the game while Left Ctrl (L1/L2) is held, allowing those buttons to cancel the prompt as well. Stick clicks emit otherwise-unused F11/F12 only to cancel the prompt. Every firmware uses the same `thecitadel.ini` mapping.
- Keeps settings and save slots in the port's `conf/` directory.
- Removes wall/closed-door collision damage and associated bounce, impact messages, sound and distortion. Enemy damage and enemy-hit effects are unchanged.
- Makes game stdout line-buffered so diagnostic messages are retained promptly.
- Handles quit/window-close events in input, queue clearing, animations, fades and delays. Video shutdown stops VLC callbacks before releasing their surfaces and mutex.
- Runs the game in the foreground and delegates mapper cleanup to `pm_finish`. No custom supervision functions or signal traps are used.
- Clears the inherited `SDL_VIDEODRIVER` override for the game only, leaving SDL to select its backend. On RG353VS, the firmware forced Wayland on a two-seat compositor and mapped keyboard events did not reach the game. With automatic selection, SDL used XWayland; A confirmed the language menu and D-pad down reached SDL as Page Down. The mapper and audio retain their firmware environment. No backend name or firmware name is hardcoded in the launcher.
- Adds a CMake build and ships every source change in `patches/cytadela-1.1.0-portmaster.patch`, tested against the checksummed upstream release.
- Uses a 12000 stick-to-key deadzone while retaining the existing right-stick mouse curve.
- Fills the gameplay drawable on square and widescreen displays by expanding the field of view rather than stretching or cropping the fitted view. The HUD retains its fitted pixel size and stays bottom-centered; software menus and movies retain their original aspect fitting.
- Ships bulk assets in a zero-owned, dereferenced `gamedata.tar.gz`; extraction preserves the original `data/` paths and does not touch `conf/`.

The launcher uses the current standard header. Read-only inspection found that both installed PortMaster `control.txt` files already import the device/helper files and define `GPTOKEYB2`; redundant imports and the manual mapper command were removed. No firmware files are modified.

The source retains its original GL rendering backend. PortMaster's per-CFW libgl helper selects native OpenGL on ROCKNIX/Panfrost or the bundled GL4ES fallback on GLES-only firmware. Explicit SDL GL/EGL paths and persistent-context handling are enabled only when the helper selected GL4ES. No alternate renderer or modified GL4ES library is shipped.

Earlier executables were tested at 640x480 on RG353V with AmberELEC prerelease-20261019_1835 and RG353VS with ROCKNIX 20261001/Mesa 26.2.2. An earlier renderer-only release was tested on RG Cube XX with Knulli 42 at 720x720 through the normal frontend launcher. Historical instrumented tests cover the forward/turn route, map, pause, door opening/closing, re-entry and exit; an earlier stripped release passed launch/input smoke, renderer re-entry and normal exit. These results do not certify the latest executable. The latest adaptive-viewport/pause-quit build and mapping were deployed and checksum-verified on RG353V and RG Cube XX, preserving saves and launcher settings, but current-build gameplay interaction has not been verified. Native tests cover square/widescreen layouts, fixed HUD scale, A-only quit confirmation and cancellation inputs. Occasional approximately 33 ms door frames occurred in prior measurements; current performance, audio, all-level/full-map and live teleportation coverage are not claimed. No clock policy changes are installed. A console reboot occurred during initial historical testing; no previous-boot crash record survived, so its cause is undetermined.

AI-generated changes require human review before a PortMaster upstream authorship attestation can be made. This package is not an upstream PortMaster submission.
