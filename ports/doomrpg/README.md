## Notes
Thanks to [Erick Vásquez García](https://github.com/Erick194/DoomRPG-RE/tree/main) for making this awesome reverse engineering engine!
Special thanks to kotzebuedog for helping me out and Szilard Biro for rewriting bartozip for linux.

## Controls

| Button | Action |
|--|--| 
|DPAD| Look Around|
|A| Interact/Shoot/Talk|
|B| Skip Turn|
|Y| AutoMap|
|L1/R1 | Strafe|
|L2/R2| Switch Weapons|
|Select| Menu|


## Compile

```shell
git clone https://github.com/Cebion/DoomRPG-RE_PM
cd DoomRPG-RE
mkdir build && cd build
cmake ..
make

// bartozip
wget https://github.com/BSzili/DoomRPG-RE/blob/amiga/amiga/bartozip.c
gcc bartozip.c -lz -o bartozip

// celp13k
git clone https://github.com/BSzili/celp13k.git
cd celp13k 
// remove $(TTY_DIR)/tty_glob.o from code/makefile
make
```

