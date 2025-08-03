# JVGS

## Description

JVGS is a retro-styled 2D puzzle platform game created as an experiment with vector graphics in games. The game features:

- Vector-based graphics and animations
- Puzzle-platform gameplay mechanics
- Retro aesthetic with modern design
- Lua scripting for game logic

## Notes

Thanks to Jasper Van der Jeugt for creating this unique vector-based platformer!

## Controls

| Button | Action |
|--------|--------|
| D-pad/Left Analog | Movement |
| A/B | Jump |
| X/Y | Action/Interact |
| Start/Select | Quit |
| L1 | Action (alternative) |
| R1 | Jump (alternative) |

## Source

Original game by Jasper Van der Jeugt: https://github.com/jaspervdj/JVGS

## Build Information

This port includes the compiled JVGS binary built from source using the Docker build system in `jvgs/src/`.

To rebuild:
```bash
cd jvgs/src
./docker-setup.txt jvgs-build
# Inside container: ./build.txt
# Extract: ./retrieve-products.txt /container/path /path/to/jvgs/port
```

## Port Credits

Ported by: bmd