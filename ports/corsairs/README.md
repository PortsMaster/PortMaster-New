## Notes

Place the original Corsairs JAR as `corsairs.jar` into `ports/corsairs/`. The game JAR can be found in J2ME game archives online. Internet connection is required on first launch to download the JDK 11 runtime.

Includes a full English translation — the original game was Russian only.

Thanks to **Akella** for the original game.

## Controls

| Button | Action |
|--|--|
| D-pad / Left analog | Move / Navigate menus |
| A | Right soft key |
| B / X | OK |
| Y | Left soft key (menu) |
| L1 / R1 | Star (*) / Pound (#) |

## How It Works

The original J2ME bytecode runs unmodified on a compatibility shim that implements the MIDP 2.0 / CLDC 1.1 APIs using Java AWT in headless mode. The game renders to a `BufferedImage` (208x208), which is sent to the screen via a small C JNI library that uses SDL2.

This port uses the SDL2 library, licensed under the zlib license. Source code is available at https://github.com/libsdl-org/SDL
