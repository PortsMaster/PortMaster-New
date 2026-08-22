## Notes
<br/>

**Runner Protocol** is an original game by [ShellPayant](https://github.com/ShellPayant/runner-protocol)
(author and porter are the same person): your real Claude Code usage limits,
played as an extraction game. Code, artwork and sounds are the author's own,
MIT licensed - see `licenses/`. The display typeface is Maratype by
imago? / metamorphosiis, released freely by its designer (attribution in
`licenses/NOTICE.md`).

### How it plays

Every 5-hour usage window is a RUN. Salvage accrues while you work, a
multiplier peaks in the 60-85% productive band, and you must EXTRACT (A) to
bank it before the window hits 95% or a rate limit - a BLACKOUT that burns
everything unbanked.

Live data arrives from an **optional companion pusher on your PC** (see the
[project page](https://github.com/ShellPayant/runner-protocol) - the device
runs a small HTTP listener on port 8788 for it, and nothing else uses the
network). **Without a PC the port still works out of the box**: press Y on
the NO SIGNAL screen and the PROTOCOL DRILL plays a full synthetic run -
cold, the band, critical, blackout, reset - clearly badged SYNTHETIC.

### Controls

| Button | Action |
|--|--|
| L1 / R1 / D-pad | previous / next tab |
| A | EXTRACT - bank the salvage |
| B | back to the RUN tab |
| Y | PROTOCOL DRILL on / off |
| SELECT + START | exit |

### Compatibility

Written for a **640x480 panel at 32bpp**, drawing straight to `/dev/fb0`
with pure stdlib Python (no SDL, no packages; needs the firmware's
`python3`). Tested on ArkOS-family firmware on RK3326 devices (R36S-class).
Other resolutions and DRM-only firmware are not supported.
<br/>
