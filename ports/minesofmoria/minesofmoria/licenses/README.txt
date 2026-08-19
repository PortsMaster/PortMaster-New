The port ships one executable per architecture.

  moria_at game code          GPL-3.0-or-later    LICENSE.moria_at.txt
    Rufe.org LLC's rebuild of Umoria, itself derived from Robert Alan
    Koeneke's Moria. The repository LICENSE covers the work as a whole.

  moria_at SDL2 platform      ISC                 LICENSE.moria_at.txt applies
    Every file under platform/sdl2 carries the header
      "// Rufe.org LLC 2022-2025: ISC License"
    a more permissive grant by the same copyright holder, given inside a
    repository whose LICENSE is GPL-3. No separate ISC text is shipped
    upstream, so the GPL-3 terms above are the ones this port distributes
    under.

  puff.c                      zlib                LICENSE.puff.txt
    Mark Adler's inflate reference, compiled in via platform/sdl2/puff_stream.c.

  SDL2 headers                zlib                LICENSE.SDL2.txt
    third_party/SDL2/SDL.h, a flattened SDL 2.28.5 header by Sam Lantinga.
    Only the header is used; the library itself comes from the device.

  Font and sprite assets      GPL-3.0-or-later    LICENSE.moria_at.txt
    platform/sdl2/asset/font_zlib.c and sprite.c hold deflate-compressed raw
    rasters -- 64 KiB of glyph bitmap and 88 KiB of sprite sheet. Neither
    carries embedded attribution of its own; both are committed to the
    upstream repository by its copyright holder and are covered by its
    LICENSE.

SOURCE
The GPL requires the source that corresponds to this binary. It is at

  https://github.com/mxmgorin/moria-handheld   branch: main

which is a fork of https://github.com/RufeDotOrg/moria_at with the handheld
changes on top.
