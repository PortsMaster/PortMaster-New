## Notes
Thanks to [Kostas Michalopoulos](https://github.com/jbradish/nikwi) for creating this game and making it available for free!

## Controls

| Button | Action |
|--|--| 
|DPAD| Move|
|A | Jump|


## Compile

```shell
dget -u http://deb.debian.org/debian/pool/main/n/nikwi/nikwi_0.0.20120213-6.dsc
cd nikwi-0.0.20120213
replace src/nikwi/gfx.cpp with the one in src/
./make-linux-release.sh
```

