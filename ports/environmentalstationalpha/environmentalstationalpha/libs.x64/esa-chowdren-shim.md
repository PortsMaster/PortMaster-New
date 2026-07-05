# Chowdren / Xwayland technical handoff

## Purpose

This document is a technical handoff for the Environmental Station Alpha `Chowdren` launch bug under Sway/Xwayland, how that bug was identified, and how a preload shim was developed to solve it.

It is intended to give a future person or agent enough context to:

- understand the failure mode
- understand which hypotheses were tested and discarded
- understand how the shim works
- understand which parts of the shim were later extended beyond the original focus fix

## Repository and runtime context

This repository is a packaged handheld port, not the original game source tree.

Important runtime facts:

- the launcher is `Environmental Station Alpha.sh`
- `Chowdren` is the shipped x86_64 Linux game binary
- on aarch64 handhelds, `Chowdren` is run through `box64`
- the shim binary is `esa-chowdren-shim.so`
- the launcher preloads the shim using `box64`'s `BOX64_LD_PRELOAD`

## Problem statement

Under Sway/Xwayland, Environmental Station Alpha could start and create an X11 window, but it would never become a normal visible, managed Xwayland game window.

Observed user-facing symptom:

- running the game appeared to do nothing visually
- the process stayed alive
- sometimes repeated `xdotool windowfocus --sync` against the nascent X window could eventually kick it into life, but unreliably

This same problem reproduced natively on Fedora Sway Spin and on handheld Sway/Xwayland environments.

## What was observed during investigation

### 1. The game did create a real X11 window

This was an important early finding, because the problem was not simply “window creation failed”.

The game window could be seen with X11-facing tools such as:

- `xwininfo`
- `xprop`
- `xdotool`

But Sway did not create a normal `xwayland` container for the game in `swaymsg -t get_tree`.

So the failure was somewhere after initial X11 window creation, not before it.

### 2. The problem was specific to ESA/Chowdren, not all Xwayland apps

Other Xwayland applications such as `xeyes` and `glxgears` behaved normally in the same environment.

That ruled out a generic Xwayland or compositor failure.

### 3. Xephyr behaved normally

The same `Chowdren` binary was tested under a nested X server (`Xephyr`), where it behaved normally:

- it created a visible 160x128 game window
- it rendered normally
- it behaved like a regular X11 application

This narrowed the problem specifically to the Sway/Xwayland path rather than generic X11 or generic GLX rendering.

## How the problem was identified technically

### Startup tracing strategy

Because `Chowdren` is a stripped binary, the investigation relied on a mix of:

- X11/GLX breakpoints under GDB, including:
  - `XCreateWindow`
  - `glXCreateContext`
  - `glXMakeCurrent`
- shim-based logging
- dynamic symbol interception
- comparison between Sway/Xwayland and Xephyr

### Observed startup sequence

Tracing showed that the game performed a startup sequence roughly like this:

1. create a temporary helper window around 32x32
2. create a GLX context for that helper window
3. make that helper context current
4. destroy the helper window/context
5. create/map the real 160x128 game window
6. make GLX current on the real game drawable

Several candidate code regions were investigated in the stripped binary during this phase, including addresses around:

- `0x182b175`
- `0x182b453`
- `0x182b7c7`
- `0x182b80d`
- `0x182c101`
- `0x18308a8`

These were useful investigation landmarks, but they did not become the final fix point.

### The key comparative finding

The most important finding was this:

- under **Sway/Xwayland**, the game reached `glXMakeCurrent` on the real game window but did **not** proceed into the expected `glXSwapBuffers` loop
- under **Xephyr**, the same game *did* proceed into continuous `glXSwapBuffers`

That changed the understanding of the bug completely.

The problem was no longer “the game cannot create a window”.

It became:

> the game creates its X11 window and sets up GLX, but under Sway/Xwayland it stalls before entering its real render/present loop

### Focus-related experiments

Once the render stall was identified, the investigation pivoted toward the idea that the game was implicitly waiting for some startup/focus-related state.

Two especially important experiments:

1. **Trying `XSetInputFocus`**
   - This produced `BadMatch`.
   - That matched the unreliable/bad behavior already seen from `xdotool windowfocus --sync`.
   - Conclusion: direct input-focus forcing was **not** the right fix.

2. **Sending a synthetic `FocusIn` event**
   - This caused ESA under Sway/Xwayland to begin `glXSwapBuffers`.
   - Once that happened, Sway created and managed the expected Xwayland surface.
   - The game became visible and behaved normally.

This was the decisive technical result.

## Technical root-cause summary

The best-supported explanation from the investigation is:

- `Chowdren` creates its X11 window and GLX context successfully under Sway/Xwayland
- but it does not begin its steady-state buffer-swapping/render loop until it sees the right early focus/event condition
- under Xephyr, that condition happens naturally
- under Sway/Xwayland, it does not happen reliably
- repeatedly poking the window with `xdotool` sometimes reproduced that condition by accident
- a synthetic `FocusIn` delivered at the right time reliably reproduces the needed startup state

So the actual bug is not “Xwayland cannot display Chowdren”.

It is closer to:

> Chowdren stalls in a focus-gated startup state under Sway/Xwayland and never begins swapping frames unless it receives the right early focus/event nudge.

## The implemented solution

## Files

- shim source: `esa-chowdren-shim.c`
- shim binary: `esa-chowdren-shim.so`.
- shim doc: `esa-chowdren-shim.md`

### Build

The shim is built with:
```shell
$ gcc -shared -fPIC -O2 -Wall -Wextra -o esa-chowdren-shim.so esa-chowdren-shim.c -ldl -lX11 -lpthread
```

### Launcher integration

The launcher (`Environmental Station Alpha.sh`) preloads the shim using `box64`'s `BOX64_LD_PRELOAD`

## How the focus fix is implemented in code

### 1. Symbol interposition

The shim interposes a narrow set of directly linked and dynamically resolved symbols.

Primary hook surface:

- X11 startup/focus path:
  - `XCreateWindow`
  - `dlsym`
- savedata remap path:
  - `access`
  - `fopen`
  - `fopen64`
  - `freopen`
  - `mkdir`
  - `open`
  - `opendir`
  - `__xstat`
  - `remove`
  - `rmdir`
  - `scandir`

The `dlsym` interception is important because Chowdren resolves some X11 entry points dynamically. The focus fix only needs to redirect dynamic lookups of `XCreateWindow`.

### 2. Tracking the real game window

The shim does **not** blindly act on the first X window it sees.

The function `maybe_track_window(...)` filters candidate windows by checking:

- the window must be a toplevel window (`XQueryTree`)
- it must be `InputOutput`
- it must not be `override_redirect`
- it must be large enough to look like the real game window

The size check is especially important:

- tiny startup/helper windows under 64x64 are ignored
- the actual ESA game window is around 160x128 and is tracked

When the real window is accepted, the shim stores:

- `tracked_display`
- `tracked_window`
- `tracked_colormap`

### 3. Focus/nudge thread

Once the real game window is tracked, the shim starts a detached thread:

- function: `focus_window_thread(...)`
- duration: `120` iterations
- sleep: `50 ms` between iterations
- total window: about `6 seconds`

Each loop iteration does the following:

1. `XInstallColormap(...)` if a colormap was captured
2. `XSetTransientForHint(...)`
3. `XRaiseWindow(...)`
4. send `_NET_ACTIVE_WINDOW` client message
5. send `Expose`
6. send `VisibilityNotify`
7. send synthetic `FocusIn`
8. `XFlush(...)`

The decisive piece is the synthetic `FocusIn`, but the rest of the nudges were retained as part of the startup loop because they were part of the converged working behavior.

### 4. Synthetic `FocusIn`

The actual event is built in `send_focus_event(...)`:

- `type = FocusIn`
- `mode = NotifyNormal`
- `detail = NotifyNonlinear`
- sent with `XSendEvent(..., FocusChangeMask, ...)`

This is the event that was shown during investigation to kick Chowdren out of its startup stall under Sway/Xwayland.

### 5. Constructor logging

The shim constructor:

- initializes focus-side symbols only when `ESA_SHIM_FOCUS=1`
- calls `XInitThreads()` only in focus mode
- emits a short unconditional startup line

Shim startup line format:

```text
[esa-chowdren-shim] initialized (focus=0|1 savedata=0|1)
```

## Shim feature set

The shim is a runtime-focused “Chowdren fixes” shim with two user-controlled behaviors:

### `ESA_SHIM_FOCUS=1`

Enables the Xwayland startup workaround described above.

### `ESA_SHIM_SAVEDATA=1`

Redirects `~/MMFApplications` file activity to `./savedata` beside the launched `Chowdren` binary and prints shim-authored `savedata remap:` lines for each remapped operation, showing the remapped destination path being used.

## Savedata remap implementation

This was added later, after the Xwayland fix was already working.

### Goal

Chowdren normally uses `~/MMFApplications` for settings/save files. The goal was to redirect that activity into `./savedata` next to the deployed game binary.

### Why a shim was needed

Binary inspection found fixed `MMFApplications` path strings inside `Chowdren`, including:

- `/MMFApplications`
- `/ESA_Settings.txt`
- `\MMFApplications\ESA_save.lar`
- `\MMFApplications\temp.arr`
- `\MMFApplications\temp2.arr`
- `\MMFApplications\Map`
- `\MMFApplications\LMap`

Changing `HOME` did not redirect this behavior in practice, and no obvious built-in command-line or environment override was identified.

### Implementation details

The savedata feature is intentionally narrow.

It wraps these libc file APIs:

- `access`
- `fopen`
- `fopen64`
- `freopen`
- `mkdir`
- `open`
- `opendir`
- `__xstat`
- `remove`
- `rmdir`
- `scandir`

Path rewriting logic:

- locate `MMFApplications` as a real path segment
- keep only the suffix after that segment
- rewrite the prefix to `<invoked-binary-dir>/savedata`
- normalize backslashes to forward slashes

Binary-directory resolution:

- prefer parsing `/proc/self/cmdline`
- choose the first argument after `argv[0]` that exists on disk
- fall back to `argv[0]`
- fall back again to `/proc/self/exe` if needed

Directory creation:

- `ensure_directory_recursive(...)`
- `ensure_parent_directory(...)`

This allows remapped writes such as `ESA_Settings.txt` to succeed even if `savedata/` does not already exist.

## Important false leads and discarded ideas

These were investigated and did **not** turn out to be the core fix:

- `SDL_VIDEO_X11_NODIRECTCOLOR=1`
- `SDL_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR=0`
- `SDL_VIDEO_X11_FORCE_EGL=1`
- preserving the helper window
- sanitizing WM hints
- forcing direct focus with `XSetInputFocus`

Some of these changed surface properties or altered startup behavior, but none solved the real issue on their own.

## Status

The current documented state is:

- the Xwayland focus fix works
- the savedata remap works

The most important file for future work is:

- `esa-chowdren-shim.c`

If a future person or agent needs to resume investigation, the most important conceptual takeaway is:

> the bug was identified by proving that Chowdren reached real-window `glXMakeCurrent` but failed to enter `glXSwapBuffers` under Sway/Xwayland, and the working fix was to make the game receive the early focus/event nudge it was apparently waiting for, specifically via a synthetic `FocusIn` delivered by a preload shim at the right point in startup.
