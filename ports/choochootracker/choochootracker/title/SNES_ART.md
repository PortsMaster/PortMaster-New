# SNES title art contract

The title scene is authored at NTSC 256x224 and is enlarged to a 4:3 display
with nearest-neighbour sampling. Scrolling planes wrap at their native widths.
The renderer restores cropped planes to their original canvas origins: scene
at y=112, viaduct at y=152, foreground at y=136, and logo at (52,24).

`snes_sky.bmp` includes the far mountains; `snes_scene.bmp` is an independent
intermediate plane between those mountains and the viaduct. It and
`snes_foreground.bmp` scroll independently. The foreground scrolls faster
than the viaduct to preserve depth.
`snes_viaduct.bmp` is drawn in front of the train, placing its fence and arches
in the foreground.
Magenta (`#ff00ff`) is the transparent entry.

Magenta-only padding is removed from the packaged planes; magenta remains the
transparent entry inside their visible bounds. The title deliberately does not
impose total OAM, per-scanline sprite, tile, or pixel budgets. Run
`python scripts/validate_snes_title.py` with the bundled Emscripten Python to
check the exported assets.

## Optional night title

Graphics → Boot screen selects Original (default) or Night on the next title
screen. Night retains the original assets' dimensions, silhouettes, seams and
scroll speeds. No generated landscape transitions are used. The palette
compresses bright highlights and dark shadows into muted blue-gray tones;
`night_mountains.bmp` removes only the old sky above the mountain silhouette.
Regenerate these variants with `node scripts/prepare_night_title.mjs`.

The sky is generated entirely from seeded, layered noise and 1,100 stars in
`title_night_sky.h`, with ordered pixel dithering, subtle twinkles and localized
lavender highlights. Three slow depth orbits and evolving gas wisps repeat
exactly after four minutes. There is no static sky texture or generated seam.
The 256×224 galaxy targets 10 Hz through one reusable image upload. Pixel
generation is spread across draws, with only finished images uploaded, avoiding
a full galaxy calculation on any one animation frame; scenery
and fourteen brief shooting stars per four-minute cycle retain the original
title drawing cadence. `night_meteor.bmp` supplies the eight-color trail palette.
All sky buffers are allocated when Night opens and released when leaving for
the tracker. The original scenery and train keep their independent loops;
only the existing one-time startup fade is used. Incomplete night packages
fall back to Original without changing the saved preference.
