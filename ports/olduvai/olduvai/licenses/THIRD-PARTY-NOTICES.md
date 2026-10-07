# Third-party notices

Olduvai is GPL-3.0-or-later (see [LICENSE](LICENSE)). It vendors, bundles, or
optionally loads the third-party components below. Release binaries carry this
file plus the referenced license texts in a `licenses/` directory.

**Corresponding source:** the complete source for every release is available
from the same release page (the *Source code* archive GitHub attaches to each
release) and from the repository itself.

| Component | Upstream | License | How it ships |
|---|---|---|---|
| Nuked-OPL3 | [nukeykt/Nuked-OPL3](https://github.com/nukeykt/Nuked-OPL3) | LGPL-2.1-or-later | **Compiled into every binary** (`third_party/nuked_opl3/`). Conveyed as part of the GPL-3.0 work under LGPL-2.1 §3 (conversion to GPL). Full text: `third_party/nuked_opl3/LICENSE`. |
| xBRZ | [xBRZ by Zenju](https://sourceforge.net/projects/xbrz/) | GPL-3.0 (version 3; the file headers do not grant "or later") | **Compiled into every binary** (`third_party/xbrz/`, release 1.9, trimmed to its unbuffered ARGB scaler; provenance, changes and checks: `third_party/xbrz/OLDUVAI-VENDORING.md`). Because it is GPL-3.0 only, the compiled binary is conveyed under GPL-3.0; Olduvai's own files stay GPL-3.0-or-later. The licence text is [LICENSE](LICENSE). |
| SDL2 | [libsdl.org](https://libsdl.org) | zlib | Bundled shared library (Linux AppImage, macOS app bundle, Windows MSVC zip — `SDL2.dll`). |
| FluidSynth | [fluidsynth.org](https://www.fluidsynth.org) | LGPL-2.1-or-later | **Compiled into every binary** (`third_party/fluidsynth/`, upstream release `v2.5.7`, tarball sha256 `ce27840221ab00dd59bf27e85ecbba480c6c2a7c9fbec4243658f68f59c07f4a` — the corresponding source), built with `osal=embedded` and every driver off, so it depends on nothing but the C and C++ runtimes. Conveyed as part of the GPL-3.0 work under LGPL-2.1 §3 (conversion to GPL), same as libmt32emu. Full text: `third_party/fluidsynth/LICENSE`; provenance and re-sync steps: `third_party/fluidsynth/OLDUVAI-VENDORING.md`. GM output additionally needs a SoundFont, which is not distributed. Building with `-DOLDUVAI_WITH_FLUIDSYNTH=OFF` omits it and loads the system library at run time (`dlopen`). |
| gcem | [kthohr/gcem](https://github.com/kthohr/gcem) | Apache-2.0 | Header-only constexpr maths FluidSynth builds with; compiled in with it (`third_party/fluidsynth/gcem/`, FluidSynth's pinned revision). Full text and notice: `gcem/LICENSE`, `gcem/NOTICE.txt`. |
| libmt32emu (munt) | [munt/munt](https://github.com/munt/munt) | LGPL-2.1-or-later | **Compiled into every binary** (`third_party/mt32emu/`, upstream tag `libmt32emu_2_8_3`, commit `3b05ec276f9e605af86b0eaef7f5eda43477a31f` — the corresponding source). Conveyed as part of the GPL-3.0 work under LGPL-2.1 §3 (conversion to GPL), same as Nuked-OPL3. Full text: `third_party/mt32emu/COPYING.LESSER.txt`; provenance and re-sync steps: `third_party/mt32emu/OLDUVAI-VENDORING.md`. MT-32 output additionally needs the user's own Roland ROMs, which are not distributed. Building with `-DOLDUVAI_WITH_MT32EMU=OFF` omits it and restores the previous runtime-`dlopen` behaviour for distributions that prefer to link the system library. |
| RtMidi | [thestk/rtmidi](https://github.com/thestk/rtmidi) | RtMidi license (MIT-style) | Compiled in when host-MIDI support is built (`third_party/rtmidi/`). Full text: `third_party/rtmidi/LICENSE`. |
| stb (`stb_image`, `stb_image_write`, `stb_truetype`) | [nothings/stb](https://github.com/nothings/stb) | MIT / public domain (dual) | Compiled in (`third_party/stb/`; license text embedded in each header). |
| Freckle Face | Google Fonts | SIL OFL 1.1 | Bundled font file; license ships with it (`fonts/FreckleFace-LICENSE.txt`; in the handheld bundles `licenses/LICENSE.FreckleFace.txt`). |
| Noto Sans | Google Fonts | SIL OFL 1.1 | Bundled font file; license ships with it (`fonts/NotoSans-LICENSE.txt`; in the handheld bundles `licenses/LICENSE.NotoSans.txt`). |
| doctest | [doctest/doctest](https://github.com/doctest/doctest) | MIT ([license text](third_party/doctest/LICENSE.txt)) | Test framework only — **not part of any release binary**. |
| AppImage runtime | [AppImage project](https://github.com/AppImage/type2-runtime) | MIT | Embedded in the `.AppImage` file by `appimagetool` at packaging time. |

The Linux AppImage additionally bundles the shared libraries the above depend
on (resolved by `linuxdeploy` from the build host); each retains its own
upstream license — see the respective projects.

Olduvai contains no code, art, audio, or data from the original game; see the
README **Legal** section.
