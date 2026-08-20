## Notes

Thanks to [Johan Peitz](http://allegator.sourceforge.net/) for Alex the Allegator 3: Radioactive Racers, a top-down racing game made for the 2002 "Allegro Speedhack" jam - race AI opponents around a single track across 5 laps, throttling, braking and steering to place first.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Steer / menu navigate |
| A / B | Throttle |
| Down | Brake |
| Start | Confirm (menu) |


## Compile

git clone https://github.com/Cebion/alex3.git
apt-get install -y liballegro4-dev
cd alex3/src
gcc -fcommon -c control.c demo.c edit.c intro.c main.c map.c menu.c options.c player.c scroller.c timer.c token.c vehicle.c
gcc -s -o alex3.aarch64 control.o demo.o edit.o intro.o main.o map.o menu.o options.o player.o scroller.o timer.o token.o vehicle.o $(allegro-config --libs) -ldl

The repo's own commit history documents every Windows/MSVC6-to-Linux fix (see the second
commit's message). The resulting binary needs `data/alex3.dat`, `data/def.dat`,
`data/intro.dat`, `maps/test.map`, and `scripts/intro.scr` alongside it at runtime, plus
`alex3.cfg` (created automatically on first run if missing).
