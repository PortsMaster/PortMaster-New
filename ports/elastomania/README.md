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

## ADDITIONAL LEVELS

Due to the large fan base the game had and still has, there are lot of fan made levels available online (for example: https://moposite.com/downloads_levels.php). Move these level files into the `Lev` folder.

## CREDITS

elma-miyoo by neri-rnd (SDL2 engine port)
https://github.com/neri-rnd/elma-miyoo

elma-classic by Elasto Mania Team (original source release)
https://github.com/elastomania/elma-classic
