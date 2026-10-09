# Third-Party Licenses

This file contains license information for all third-party libraries used in glitchscope.

## SoLoud
**License:** zlib/libpng  
**Source:** https://github.com/jarikomppa/soloud

## projectM
**License:** LGPL-2.1  
**Source:** https://github.com/projectM-visualizer/projectm

## FFmpeg
**License:** LGPL-2.1 (built audio-only without GPL/nonfree components)  
**Source:** https://ffmpeg.org/

## libxmp
**License:** MIT
**Source:** https://github.com/libxmp/libxmp

## libopenmpt
**License:** BSD-3-Clause
**Source:** https://github.com/OpenMPT/openmpt

## Game Music Emu (libgme)
**License:** LGPL-2.1 (GPL-2.0+ if using MAME YM2612 emulator)  
**Source:** https://github.com/libgme/game-music-emu

## libayumi
**License:** MIT
**Source:** https://github.com/true-grue/ayumi

## pt3player
**License:** MIT
**Source:** https://github.com/Volutar/pt3player

## libstsound
**License:** BSD-2-Clause  
**Source:** https://github.com/cpcsdk/libstsound

## cRSID
**License:** WTFPL-style permission; attribution requested  
**Source:** Rockbox project (https://www.rockbox.org/)

## HivelyTracker replayer
**License:** MIT
**Source:** https://github.com/tildearrow/foo-input-hvl

## Go-SDL2 and SDL2
**License:** BSD-3-Clause (binding), zlib (SDL2)
**Source:** https://github.com/veandco/go-sdl2 and https://libsdl.org/

## gptokeyb (PortMaster)
**License:** GPL-2.0
**Source:** https://github.com/PortsMaster/gptokeyb
Provided by PortMaster for the exit hotkey; the PortMaster package includes
`LICENSE.gptokeyb.txt`.

## golang.org/x/image and golang.org/x/text
**License:** BSD-3-Clause
**Source:** https://pkg.go.dev/golang.org/x/image and https://pkg.go.dev/golang.org/x/text

## libogg, libvorbis and libFLAC
**License:** BSD-3-Clause
**Source:** https://xiph.org/

## mpg123
**License:** LGPL-2.1
**Source:** https://www.mpg123.de/

## zlib
**License:** zlib
**Source:** https://zlib.net/

## GNU Unifont
**License:** GPL-2.0+ with the font embedding exception
**Source:** https://unifoundry.com/unifont/

## PortsMaster Device-Info detection rules
**License:** MIT
**Source:** https://github.com/PortsMaster/Device-Info

## Pixelarticons
**License:** MIT
**Source:** https://github.com/halfmage/pixelarticons
**Used for:** rasterized 1-bit UI source icons

---

## Distribution notices

PortMaster bundles only Vorbis, Ogg, mpg123 and zlib shared libraries. FLAC and
the C/C++ system runtimes and their notices are excluded from that package;
desktop releases retain their own runtime libraries and notices. PortMaster
uses SDL2 and GPU drivers supplied by the firmware.

GlitchScope code is GPL-2.0-or-later; see the root LICENSE. Dependencies retain
their own licenses and copyright notices. The Linux builder collects source
notices, Go module licenses and copyright files for bundled shared libraries
into the release `licenses/` directory. Each component has one
`LICENSE.<component>.txt` containing its notices and any referenced full license
texts. System library notices and unrelated distro license texts are excluded. GNU Unifont's upstream license (including the font
embedding exception), font copyright metadata and Device-Info's MIT notice are
included separately.

Optional MilkDrop preset collections are not included in GlitchScope release
archives. From the in-app Presets page, users may choose to download these ZIPs
directly from the author's Patreon files:
- Cream of the Crop: https://www.patreon.com/file?h=91682111&i=16310421
- Isosceles Mashups 2020: https://www.patreon.com/file?h=91682111&i=16310422
- Isosceles Mashups 2024: https://www.patreon.com/file?h=115453098&m=375145864

The author authorized GlitchScope to offer these downloads. The archives remain
the author's and contributors' works; this permission does not transfer
intellectual-property rights or change the terms applying to their contents.
GlitchScope does not sell the collections. No third-party demo tracks are bundled.

The Presets page also offers optional downloads from the projectM repositories:
- En D: https://github.com/projectM-visualizer/presets-en-d
- MilkDrop Original: https://github.com/projectM-visualizer/presets-milkdrop-original
- projectM Classic: https://github.com/projectM-visualizer/presets-projectm-classic
- Textures for these collections: https://github.com/projectM-visualizer/presets-milkdrop-texture-pack

These assets retain their authors' rights and upstream terms; they are not
licensed as part of GlitchScope. Installation retains upstream README and license
notices under Sources/ in the combined ZIP. The Isosceles permission above applies
to the Patreon collections only.

MilkDrop2077 is an optional download from
https://github.com/milkdrop2077/milkdrop2077 . Its PRESETS.RES text payloads are
preserved without modification in the installed ZIP, alongside the projectM
MilkDrop texture pack and a source/license link under Sources/Presets/.
Upstream license: https://github.com/milkdrop2077/milkdrop2077/blob/main/LICENSE .
These downloaded assets are excluded from GlitchScope release archives.

Upstream notice sources retrieved for this release preparation:
- GNU Unifont: https://unifoundry.com/LICENSE.txt
- Device-Info: https://github.com/PortsMaster/Device-Info/blob/main/LICENSE

Butterchurn is an optional user download from
https://github.com/jberg/butterchurn-presets . Installation retains the original
`presets/milkdrop/` files and upstream README/license notices, and adds the
MilkDrop texture pack as above. The upstream repository uses the MIT license:
https://github.com/jberg/butterchurn-presets/blob/master/LICENSE .
The collection is not bundled in release packages.
