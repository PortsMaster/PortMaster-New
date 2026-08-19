## Notes

Thanks to [Johan Peitz](http://allegator.sourceforge.net/) for Alex the Allegator 4, the most
polished entry in the "Allegro Speedhack" jam series, with a proper story, scripted intro/outro,
and ten hand-built levels.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move / menu navigate |
| A | Jump |
| X | Fire |
| Back | Pause (in-game) / back (menus) |
| Start | Confirm (menu) |

## Bonus community level packs

This port bundles 23 fan-made custom level packs, sourced from the game's own official
community map page (allegator.sourceforge.net/a4maps) and its predecessor fan site
(alex4.webz.cz, via the Wayback Machine). The startup picker offers a choice between the
original campaign (launched with no arguments, so its real intro/outro cutscenes play exactly as
shipped) and a combined marathon of all 23 packs' levels back-to-back, in one continuous
playthrough (`custom_maps/all_packs.a4`).

## Compile

git clone https://github.com/Cebion/alex4.git
apt-get install -y liballegro4-dev libaldmb1-dev libdumb1-dev
cd alex4/src
gcc -fcommon -c actor.c bullet.c control.c edit.c hisc.c main.c map.c options.c particle.c player.c script.c scroller.c shooter.c timer.c token.c
gcc -s -o alex4.aarch64 actor.o bullet.o control.o edit.o hisc.o main.o map.o options.o particle.o player.o script.o scroller.o shooter.o timer.o token.o $(allegro-config --libs) -laldmb -ldumb -ldl

The resulting binary needs the `data/` folder's `.dat` files two directories up from `src/`
(`../data/data.dat`, `../data/maps.dat`, `../data/sfx_22.dat`) and `alex4.ini` alongside it at
runtime.
