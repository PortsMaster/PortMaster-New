## EAT GIRL

This is a port of EAT GIRL to Linux handhelds.

EAT GIRL is a surreal top-down action game by tesselode about moving quickly and efficiently through tight corridors while eating dots. Explore an interconnected world of more than 30 levels, meet creatures who may or may not be docile, and take in an atmosphere that is by turns meditative and unsettling, with every level scored by its own blend of ambient music.

## Controls

| Button            | Action          |
| ----------------- | --------------- |
| D-Pad / Left stick| Move            |
| A                 | Confirm         |
| B                 | Cancel / Back   |
| Start             | Pause           |
| Start + Select    | Exit game       |

## How To Install

Buy EAT GIRL on itch -> https://tesselode.itch.io/eatgirl

Copy `eatgirl.love` from the download into `ports/eatgirl`.

## Notes

The game runs on the `love_11.5` runtime. On the first run the game is patched:

- **Shaders.** shaders relied on desktop-only implicit int-to-float conversion and on default initializers for uniforms.
- **Performance.** The parallax backgrounds, world-map entities and the barrier band are now camera-culled, and collision uses a uniform-grid broadphase.

## Thanks

A huge thank you to [tesselode](https://tesselode.itch.io/) for making EAT GIRL.
