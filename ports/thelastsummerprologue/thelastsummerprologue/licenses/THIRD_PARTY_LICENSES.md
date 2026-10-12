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
| BoutiqueBitmap9x9 (Luke Liu, fancy type foundry) | 1.93 | Chinese and Japanese glyphs in `assets/fonts/body.png` (drawn from `tools/sprite_forge/fonts_cjk/` by `font_cjk.py`) | SIL Open Font License 1.1 (`tools/sprite_forge/fonts_cjk/OFL-BoutiqueBitmap9x9.txt`) |
| Cubic 11 (ACh-K) | 1.500 | Chinese and Japanese glyphs in `assets/fonts/reading.png` (the same way) | SIL Open Font License 1.1 (`tools/sprite_forge/fonts_cjk/OFL-Cubic11.txt`) |

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

### BoutiqueBitmap9x9 (SIL Open Font License 1.1)

```
[BoutiqueBitmap9x9]
Copyright © 2026 字言字型 版權所有。
Copyright © 2026 fancy type foundry. All rights reserved.
2020-2026《字言字語》Cen-cyun, Liu. Luke Liu.
https://fontspeech.blogspot.com/
These fonts are free software.
Unlimited permission is granted to use, copy, and distribute them, with or without modification, either commercially or noncommercially.
THESE FONTS ARE PROVIDED "AS IS" WITHOUT WARRANTY.
此字型是免費的。
無論您是否進行對本字型進行商業或非商業性修改，均可無限制地使用，複製和分發它們。
本字型的衍生品之授權必須與此字型相同，且不作任何擔保。
此字体是免费的。
无论您是否进行对本字型进行商业或非商业性修改，均可无限制地使用，复制和分发它们。
本字型的衍生品之授权必须与此字型相同，且不作任何担保。
[M+ BITMAP FONTS]
Copyright (C) 2002-2004 COZ
These fonts are free software.
Unlimited permission is granted to use, copy, and distribute it, with or without modification, either commercially and noncommercially.
THESE FONTS ARE PROVIDED "AS IS" WITHOUT WARRANTY.
これらのフォントはフリー（自由な）ソフトウエアです。
あらゆる改変の有無に関わらず、また商業的な利用であっても、自由にご利用、複製、再配布することができますが、全て無保証とさせていただきます。
[ベストテン（BestTen-DOT）]
フリーフォントのベストテンは無料でダウンロードできるドットフォント。商用・非商用問わず使用可能なので、安心してダウンロードしてください。
作成した印刷物およびデジタル・コンテンツにつき、その商用・非商用にかかわらず印刷、放送、通信、各種記録メディアなどの媒体の形式も問わず、使用をすることができます。プログラムへの埋め込みが可能です。
このフォントのライセンスは、
M+のライセンスに準じます。
M+ FONT LICENSEについては、配布物に含まれる
mplus_bitmap_fonts をご覧ください。
[Fusion Pixel]
Copyright (c) 2022, TakWolf (https://takwolf.com), with Reserved Font Name 'Fusion Pixel'.

This Font Software is licensed under the SIL Open Font License, Version 1.1.
This license is copied below, and is also available with a FAQ at:
https://scripts.sil.org/OFL


-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font creation
efforts of academic and linguistic communities, and to provide a free and
open framework in which fonts may be shared and improved in partnership
with others.

The OFL allows the licensed fonts to be used, studied, modified and
redistributed freely as long as they are not sold by themselves. The
fonts, including any derivative works, can be bundled, embedded, 
redistributed and/or sold with any software provided that any reserved
names are not used by derivative works. The fonts and derivatives,
however, cannot be released under any other type of license. The
requirement for fonts to remain under this license does not apply
to any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright
Holder(s) under this license and clearly marked as such. This may
include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the
copyright statement(s).

"Original Version" refers to the collection of Font Software components as
distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to, deleting,
or substituting -- in part or in whole -- any of the components of the
Original Version, by changing formats or by porting the Font Software to a
new environment.

"Author" refers to any designer, engineer, programmer, technical
writer or other person who contributed to the Font Software.

PERMISSION & CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font
Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components,
in Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled,
redistributed and/or sold with any software, provided that each copy
contains the above copyright notice and this license. These can be
included either as stand-alone text files, human-readable headers or
in the appropriate machine-readable metadata fields within text or
binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font
Name(s) unless explicit written permission is granted by the corresponding
Copyright Holder. This restriction only applies to the primary font name as
presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font
Software shall not be used to promote, endorse or advertise any
Modified Version, except to acknowledge the contribution(s) of the
Copyright Holder(s) and the Author(s) or with their explicit written
permission.

5) The Font Software, modified or unmodified, in part or in whole,
must be distributed entirely under this license, and must not be
distributed under any other license. The requirement for fonts to
remain under this license does not apply to any document created
using the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are
not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.
```

### Cubic 11 (SIL Open Font License 1.1)

```
[Cubic 11]
These fonts are free software.
Unlimited permission is granted to use, copy, and distribute them, with or without modification, either commercially or noncommercially.
THESE FONTS ARE PROVIDED "AS IS" WITHOUT WARRANTY.
此字型是免費的。
無論您是否進行對本字型進行商業或非商業性修改，均可無限制地使用，複製和分發它們。
本字型的衍生品之授權必須與此字型相同，且不作任何擔保。
[JF Dot M+H 12]
Copyright(c) 2005 M+ FONTS PROJECT
[M+ BITMAP FONTS]
Copyright (C) 2002-2004 COZ
These fonts are free software.
Unlimited permission is granted to use, copy, and distribute it, with or without modification, either commercially and noncommercially.
THESE FONTS ARE PROVIDED "AS IS" WITHOUT WARRANTY.
これらのフォントはフリー（自由な）ソフトウエアです。
あらゆる改変の有無に関わらず、また商業的な利用であっても、自由にご利用、複製、再配布することができますが、全て無保証とさせていただきます。

This Font Software is licensed under the SIL Open Font License, Version 1.1.
This license is copied below, and is also available with a FAQ at:
https://scripts.sil.org/OFL


-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font creation
efforts of academic and linguistic communities, and to provide a free and
open framework in which fonts may be shared and improved in partnership
with others.

The OFL allows the licensed fonts to be used, studied, modified and
redistributed freely as long as they are not sold by themselves. The
fonts, including any derivative works, can be bundled, embedded, 
redistributed and/or sold with any software provided that any reserved
names are not used by derivative works. The fonts and derivatives,
however, cannot be released under any other type of license. The
requirement for fonts to remain under this license does not apply
to any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright
Holder(s) under this license and clearly marked as such. This may
include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the
copyright statement(s).

"Original Version" refers to the collection of Font Software components as
distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to, deleting,
or substituting -- in part or in whole -- any of the components of the
Original Version, by changing formats or by porting the Font Software to a
new environment.

"Author" refers to any designer, engineer, programmer, technical
writer or other person who contributed to the Font Software.

PERMISSION & CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font
Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components,
in Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled,
redistributed and/or sold with any software, provided that each copy
contains the above copyright notice and this license. These can be
included either as stand-alone text files, human-readable headers or
in the appropriate machine-readable metadata fields within text or
binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font
Name(s) unless explicit written permission is granted by the corresponding
Copyright Holder. This restriction only applies to the primary font name as
presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font
Software shall not be used to promote, endorse or advertise any
Modified Version, except to acknowledge the contribution(s) of the
Copyright Holder(s) and the Author(s) or with their explicit written
permission.

5) The Font Software, modified or unmodified, in part or in whole,
must be distributed entirely under this license, and must not be
distributed under any other license. The requirement for fonts to
remain under this license does not apply to any document created
using the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are
not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.
```
