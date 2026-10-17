# Third-party notices

| file | covers | licence |
|---|---|---|
| `LICENSE.port.txt` | the port's own files: `Lost Flame.sh`, `lostflame.gptk`, `steamstub.jar`, `tools/`, `patch/patchscript`, `patch/whole/` | MIT |
| `LICENSE.steamworks4j.txt` | `steamstub.jar` shadows one class of [steamworks4j](https://github.com/code-disaster/steamworks4j) | MIT |
| `LICENSE.jamepad.txt` | `jamepad-natives-2.30.0.0.jar`: the two `.so` from [libgdx/Jamepad](https://github.com/libgdx/Jamepad) 2.30.0.0, taken unmodified from `com.badlogicgames.jamepad:jamepad:2.30.0.0` on Maven Central | Apache-2.0 |
| `LICENSE.jamepad.txt` | **modified files**: `patch/deltas/com/badlogic/gdx/controllers/desktop/support/JamepadController*` change [libgdx/gdx-controllers](https://github.com/libgdx/gdx-controllers)' desktop backend, as shaded into the game's jar, so `getAxis()` taps the trigger axes for the port's pad log | Apache-2.0 |
| `LICENSE.SDL2.txt` | the SDL 2.30 statically linked inside those natives | zlib |

Neither upstream artifact ships a NOTICE file, so there is none to carry.

To reproduce `jamepad-natives-2.30.0.0.jar`: download the Maven jar, extract
`libjamepadarm64.so` and `libjamepad64.so`, zip them at the root of a fresh jar.

Everything under `patch/deltas/` is an xdelta3 delta against Lost Flame's own
class files, and `targets.md5` pins the result; they rebuild nothing without a
legitimate copy of `LostFlame.jar`. The game's code stays its author's; the MIT
above covers the port's files only.
