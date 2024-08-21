## Notes
Thanks to the [Netsurf Team](https://www.netsurf-browser.org/) for creating this browser.
Special thanks to [Snow](https://github.com/tailtwo) 
For making necessary changes and initial workand the keymap to make it run on these devices!


## Controls

The following instructions are for a right-facing character. 

| Button | Action |
|--|--| 
|Left Analogue Stick | Move Mouse|
|A| Left Mouse |
|B| Slow Mouse |
| HK + X| Refresh (F5)|
| L2 | Home| 
| DPAD | Arrow Keys | 

## Compile ## 

```bash
git clone https://github.com/tailtwo/netsurf.git
cd netsurf/
git checkout fixes
# Modify device specfic cflags in Makefiles
wget https://git.netsurf-browser.org/netsurf.git/plain/docs/env.sh
unset HOST
source env.sh
ns-clone
ns-pull-install
make TARGET=framebuffer -j12
strip nsfb
```