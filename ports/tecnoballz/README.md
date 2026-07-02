## Notes
Thanks to the [TLK Games Team](https://linux.tlk.fr/games/TecnoballZ/) for creating this game and making it available for free!  
Thanks to Cebion for the original porting work for this game.

Source: [Slayer366](https://github.com/Slayer366/tecnoballz-pm)

The above source is comprised of the following sources with various fixes:  
[brunonymous](https://github.com/brunonymous/tecnoballz)  
[dmitrysmagin](https://github.com/dmitrysmagin/tecnoballz/tree/gcw0)  
[JORGETECH](https://github.com/JORGETECH/tecnoballz)  
[retrofirmware](https://github.com/retrofirmware/tecnoballz)


## Controls (Dual thumbsticks)

| Button | Action |
|--|--| 
|D-Pad/Left analog|Move|
|Right analog|Mouse|
|A|Space/Make selection|
|B/Select|Esc/Cancel|
|L1/L2|Right mouse button|
|R1/R2|Left mouse button|


## Controls (Less than 2 sticks)

| Button | Action |
|--|--| 
|D-Pad|Move|
|Left analog|Mouse|
|A|Space/Make selection|
|B/Select|Esc/Cancel|
|L1/L2|Right mouse button|
|R1/R2|Left mouse button|


## Compile

```shell
git clone https://github.com/Slayer366/tecnoballz-pm
cd tecnoballz-pm
./bootstrap
./configure --enable-portmaster
make -j$(nproc)
```