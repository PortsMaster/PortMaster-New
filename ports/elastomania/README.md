# Elasto Mania

Elasto Mania is a physics-based motorbike game where you ride through levels, collect apples, and reach the flower to complete each stage. Originally released in 2000 by Balazs Rozsa.

This port is based on elma-miyoo by neri-rnd, an SDL2 reimplementation of the original engine, cross-compiled for aarch64.

## INSTALLATION

Copy the .sh and elastomania folder from the zip to `/roms/ports/`.

Copy required game files into `elastomania/gamefiles/`:

- **Classic (2000):** `Elma.res` and `Default.lgr` from your installation.
- **Remastered (Steam/GOG):** `Elma.res` and `Default.lgr` from the install dir. The hi-res `Default.lgr` (~7.2 MB, LGR13) is auto-prescaled to classic dimensions.
- **Optional:** For classic look on Remastered, use `orig.lgr` from `Lgr/` and rename to `Default.lgr`.

## WHERE TO BUY

This port requires game files from Elasto Mania.

- https://store.steampowered.com/app/1290220/Elasto_Mania_Remastered/
- https://www.gog.com/de/game/elasto_mania

## CONTROLS

On first launch a layout selector appears. Pick one of three presets (Original, NotYerAvgPorter, Bukakepeter) or build your own with the Custom Layout wizard. Navigate with D-Pad, confirm with A.

From the second launch on, **START** lets you keep the layout you chose on the first launch, **SELECT** locks in the current layout and hides the launcher on all next launches of the game. Delete `elastomania/layout.conf.lock` to re-enable it.

Each preset's mapping is shown on the layout screen. Custom is saved to `elastomania/layouts/custom.gptk`.

## EDITOR

In-game editor needs mouse + keyboard. Not recommended on handhelds. USB/Bluetooth mouse may work but is untested.

## BUNDLED LEVELS

This port already ships with **4768 community-curated fan-made levels**, organised into folders for easy navigation:

- **Tutorials/** — original Elma tutorial levels
- **Reviewed/** — Moposite-rated showcase levels (76–91 pts)
- **Top10/** — the 10 best-rated levels of every official empack (Pack26 – Pack76)
- **FullPacks/** — selected complete official empacks spanning 2000-2002

It also ships with **17 matching community LGR graphics packs** (cemetery, style, horror, frotzy, q3arena, trinity, simpsons, carma, across, kraazeh, clown, ugly, sumo, retro, vertical, choco, nightdri) so most levels render with their intended visuals out of the box.

All levels and LGRs are sourced from [moposite.com](https://moposite.com/downloads_levels.php).

## ADDITIONAL LEVELS

Even more fan-made levels are available online (for example at https://moposite.com/downloads_levels.php). Drop additional `.lev` files into the `lev/` folder (sub-folders are supported).

## CREDITS & THANKS

**Engine port (this build is based on):**
elma-miyoo by neri-rnd — SDL2 reimplementation of the original engine, originally targeting Miyoo Mini. Without this port, Elasto Mania on PortMaster would not exist.
https://github.com/neri-rnd/elma-miyoo

**Original source release:**
elma-classic by the Elasto Mania Team
https://github.com/elastomania/elma-classic

**Original game:**
Elasto Mania (2000) by Balazs Rozsa.

**Thanks:**
- **tabreturn** — packaging cleanup, `lev.7z` first-run extract trick, AmberELEC testing
- **NotYerAvgPorter** — RG40XX H / RG34XX SP testing, layout 2 namesake
- **ArnoldSmith86** — KNULLI testing
- **manster_** — ArkOS glibc compat report
- **Dia2809** — PR review (port.json v3, gameinfo, .sh)
- Testers & devs from the PortMaster Discord

**Bundled level packs and LGR graphics:**
Curated by the Moposite crew (Csaba, Abula, psy, dz and many others); individual levels and LGRs remain authored by their respective creators.
https://moposite.com/
