## Notes
Thanks to [The Pingus Team](https://pingus.seul.org/download.html) for making this game and making it available for free.

## Controls

| Button | Action |
|--|--| 
|DPAD| Move Screen|
|A/B | Mouse Left/Right Click|
|X| Slow Mouse (hold) |
|Y| Fast Forward|
|L1| Toggle Fullscreen|
|L2| Armageddon|
|Start| Pause|


## Compile

```shell
dget -u http://deb.debian.org/debian/pool/main/p/pingus/pingus_0.7.6-6.dsc
cd pingus-0.7.6/
edit dataprefix in Makefile to .
make
```