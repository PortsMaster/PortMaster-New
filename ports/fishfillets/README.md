# Thanks
Thanks to the [Fish Fillets Team](https://fillets.sourceforge.net/) for making this game and making it available for free.

## Controls

| Button | Action |
|--|--| 
|DPAD| Move Fish|
|Analogue Sticks| Mouse Movement| 
|Y| Switch CharactersMouse Left|
|A/B| Mouse Left / Mouse Right|
|X| Slow Down Mouse (hold) 

## Building

```
dget -u http://deb.debian.org/debian/pool/main/f/fillets-ng/fillets-ng_1.0.1-5.dsc
cd fillets-ng-1.0.1
CPPFLAGS="-I/usr/include/lua5.1" ./configure --build=aarch64-unknown-linux-gnu --with-lua=/usr LUA_CFLAGS="-I/usr/include/lua5.1" LUA_LIBS="-llua5.1"
patch -p3 < cursor.patch
make
```
