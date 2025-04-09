## Notes
Thanks to the [David K. McAllister and the Armagetron Advanced development team](https://www.armagetronad.org/) for creating this game and making it available for free!
 
## Controls

| Button | Action |
|--|--| 
|DPAD| Player 1 Controls|
|ABXY| Player 2 Controls|


## Compile

```shell
wget https://launchpad.net/armagetronad/0.2.9/0.2.9.2.3/+download/armagetronad-0.2.9.2.3.tbz
./bootstrap.sh
./configure --enable-main --enable-music --disable-uninstall --disable-etc --enable-binreloc
In Makefile switch dataroot and prefixes to .
make
```