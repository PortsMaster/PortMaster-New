## Notes

Thanks to [Dominic Szablewski](https://github.com/phoboslab/) for creating this awesome game.

## Controls

| Button | Action |
|--|--| 
|DPAD|Move|
|A|Shoot|
|B|Jump|


## Compile

```shell
git clone https://github.com/scemino/z_biolab.git
zig build run -Dtarget=aarch64-linux-gnu.2.17.0 -Dplatform=sdl_soft -Doptimize=ReleaseFast
```
