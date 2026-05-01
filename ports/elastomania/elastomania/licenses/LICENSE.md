# Elasto Mania PortMaster Port - Source Attributions

## Game engine binary (`elma`, `layout_select`)

Compiled from [elma-miyoo](https://github.com/neri-rnd/elma-miyoo) by neri-rnd, an
SDL2 reimplementation of the original Elasto Mania engine for ARM Linux handhelds.
elma-miyoo itself is based on:

[elma-classic](https://github.com/elastomania/elma-classic) — official open-source
release of the original Elasto Mania (2000) C++ source code by the Elasto Mania
Team. License terms: see the LICENSE file in the elma-classic repository.
For uses beyond what is permitted, contact info@elastomania.com.

The original Elasto Mania game and its trademarks remain Copyright © 2000
Balazs Rozsa.

## Bundled level files (`lev/`)

Curated community-made level packs sourced from
[Moposite](https://moposite.com/downloads_levels.php), including:

- **Top10 packs** (top10pack26 – top10pack76) — 10 hand-picked best levels per
  official empack, curated by Abula, psy and dz.
- **Reviewed showcase levels** (MOPSI001 – MOPSI007) — community-reviewed levels.
- **Full official empacks** (selected packs from empack26 – empack76) — complete
  official monthly level packs released by the Moposite crew (curated by Csaba)
  between 2000 and 2002.

Authorship of individual levels remains with their respective creators.

## Bundled LGR graphics packs (`lgr/`)

Community-made LGR graphics packs sourced from
[Moposite LGR downloads](https://moposite.com/downloads_lgrs.php):
across, carma (Carmageddon), cemetery, choco, clown, frotzy, horror, kraazeh,
nightdri (Nightdriver), q3arena, retro, simpsons, style, sumo, trinity, ugly,
vertical. Authorship remains with their respective creators.

`default.lgr` and `Elma.res` are NOT distributed with this port. Users must
provide them from their own legitimate copy of Elasto Mania (Classic 2000,
Steam Remastered or GOG Remastered).

## Embedded font

The 8x8 bitmap font used by `layout_select` is a public-domain CP437 / IBM-PC
"tinyfont" subset.

## Port packaging

Port scripts, layout selector binary and Makefile portmaster target by
the port maintainer. Inspired by the PortMaster packaging conventions.
