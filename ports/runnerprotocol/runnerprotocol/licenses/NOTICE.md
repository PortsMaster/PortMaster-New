# Third-party material

RUNNER PROTOCOL itself is MIT licensed, see [LICENSE](LICENSE). One part of it
isn't mine.

## The typeface

The display face is **Maratype** by **imago? / metamorphosiis**
([Behance](https://www.behance.net/gallery/227048755/MARATYPE-custom-display-font),
mirrored on [Fontesk](https://fontesk.com/maratype-font/)), released freely by
its designer: no commercial restrictions, redistribution allowed, attribution
encouraged rather than required.

* The original font is bundled at [`tools/Maratype.otf`](tools/Maratype.otf).
* `device/art/maratype.fnt` is **derived from it**, rendered to bitmap spans
  by [`tools/bake_font.py`](tools/bake_font.py), because the console draws
  rectangles, not outlines. The baker also synthesizes the glyphs the face
  doesn't carry (`%`, `<`, `>`) and redraws `X`/`V`/`K`, which don't survive
  small sizes — [docs/DESIGN.md](docs/DESIGN.md) §3 has the full story.

**If you fork this and keep the font, keep the attribution with it.**

## What's mine

Everything else: the game model, the renderer, the baked artwork in
`device/art/`, the sound effects (synthesised from arithmetic by
[`tools/bake_sfx.py`](tools/bake_sfx.py) — no samples), the pushers, the
installer, and this document.

## Not affiliated

Not affiliated with, endorsed by, or connected to Anthropic. "Claude" is
theirs. This reads your own usage numbers, with your own login, and makes a
game about it.
