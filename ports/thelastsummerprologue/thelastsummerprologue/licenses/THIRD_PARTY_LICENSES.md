# Third-party components

Everything in this repository is original work except the components listed here.
No RollerCoaster Tycoon / RCT2 data (graphics, sounds, music, scenarios, objects) and no
OpenRCT2 asset packs (`objects`, `OpenMusic`, `OpenSoundEffects`) are used or distributed.

## Shipped with the game

| Component | Version | Where | Licence |
|---|---|---|---|
| SDL2 | 2.0.10 or newer (built and tested with 2.30) | linked dynamically (system or bundled library) | zlib |
| nlohmann/json | 3.11.3 | `third_party/nlohmann/json.hpp` | MIT |
| stb_image, stb_image_write, stb_vorbis | 2.30 / 1.16 / 1.22 | `third_party/stb/` | MIT or public domain (Unlicense), at your choice |
| MinGW-w64 runtime (start-up code and C helpers) | from llvm-mingw 20260908 | linked into the Windows executable | ZPL 2.1 / BSD / MIT notices, shipped as `MinGW-w64-runtime-LICENSE.txt` in the Windows package |
| LLVM libc++, libc++abi, libunwind, compiler-rt | 23.1.1 (llvm-mingw) | linked into the Windows executable | Apache-2.0 WITH LLVM-exception (embedded object code needs no notice) |
| GCC libstdc++, libgcc | 14 | linked into the Linux executables | GPL-3.0 with the GCC Runtime Library Exception (no notice needed) |

## Sampled instruments in the music

The score (`assets/music/*.ogg`) is original music, rendered offline by `tools/music/` through
recorded instrument samples. The samples themselves are not shipped; only the rendered
music is.

| Samples | Used for | Source | Licence |
|---|---|---|---|
| Versilian Studios Chamber Orchestra 2, Community Edition (VSCO 2 CE) 1.1.0: Upright Piano (sampled by Simon Dalzell, Ivy Audio), Harp, Violin/Viola/Cello sections (sustain, pizzicato), Solo Violin (arco, spiccato), Solo Contrabass, Flute, Clarinet, Oboe, French Horn, Glockenspiel; triangle, shaker and bass drum from its VSCO 1 percussion folder | piano, harp, strings, woodwinds, horn, glockenspiel, light percussion | <https://github.com/sgossner/VSCO-2-CE> (fetched by `tools/music/fetch_samples.py`) | CC0 1.0 Universal (public domain dedication, the repository's `LICENSE`). Its readme asks that the samples not be sold as samples and encourages credit to Versilian Studios / Sam Gossner and Ivy Audio / Simon Dalzell; the game credits them (`data/credits.json`) |

The nylon guitar, the accordion-like reeds and the celesta are synthesised by
`tools/music/engine.py` (no samples).

## Research only (nothing included)

OpenRCT2 — <https://github.com/OpenRCT2/OpenRCT2> (GPL-3.0) — was studied during
pre-production to learn how an isometric game engine is organised. No OpenRCT2 source
files, code, data or assets are included in The Last Summer; the engine is an independent
implementation. See `LICENSES.md` (Provenance).

## Build-time tools (not distributed with the game)

The asset generators in `tools/` use Python 3 (PSF licence), NumPy (BSD-3-Clause),
SciPy (BSD-3-Clause), Pillow (MIT-CMU) and FFmpeg with libvorbis (LGPL-2.1+ / BSD-3-Clause)
to encode OGG files. None of their code ends up in the generated assets.

---

## Licence texts

### SDL2 (zlib licence)

```
Copyright (C) 1997-2025 Sam Lantinga <slouken@libsdl.org>
  
This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:
  
1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required. 
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
```

### nlohmann/json (MIT)

```
MIT License 

Copyright (c) 2013-2022 Niels Lohmann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### stb (MIT or public domain)

```
This software is available under 2 licenses -- choose whichever you prefer.
------------------------------------------------------------------------------
ALTERNATIVE A - MIT License
Copyright (c) 2017 Sean Barrett
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------
ALTERNATIVE B - Public Domain (www.unlicense.org)
This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.
In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

