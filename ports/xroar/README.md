## Notes
<br/>
Color computer and Dragon32 emulator XRoar
The compatible rom files need to be included in the ports/xroar/bios folder for example: bas13.rom 

Place color computer game files in the appropriate ports/xroar/roms subfolder.

An open source Snake game is included

Note: if screen looks green with text ending in ok, or green @ symbols with orange you must add the appropriate system bios files.
![missing bios](https://www.6809.org.uk/xroar/doc/trouble-no-basic.png)

## Compile
Download xroar-1.8.2.tar.gz from https://www.6809.org.uk/xroar/ and extract the contents
```shell
gzip -dc xroar-1.8.2.tar.gz | tar xvf -
cd xroar-1.8.2
./configure --enable-dragon --enable-coco3 --enable-mc10 --without-gtk2 --without-gtk3       --without-gtkgl --without-cocoa --without-oss --without-pulse        --without-coreaudio --without-x
make
sudo make install
```
## Thanks to 
[Ciaran Anscomb](https://www.6809.org.uk/xroar/) for XRoar the open-source color computer emulator which makes this possible.  
Slayer366 for building an entire front end to allow game and machine selection for the roms  
[Fabrizio Caruso](https://github.com/Fabrizio-Caruso/CROSS-LIB/blob/master/docs/GAMES.md#snake) for Snake 
<br/>
