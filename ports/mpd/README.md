## Notes

To use this Program put your songs into the mpdui/music folder, if you want to use playlists too put them into mpdui/playlists

If you want to control mpd on a external device with something like M. A. L. P. on a Phone then enter the IP of the Device and make sure you set the Port to 6970

## Controls

| Button | Action |
|--|--| 
|A|Pause/Resume|
|B|Add to Song Queue|
|X|Force Play Song|
|Y|Clear Song Queue|
|R|Show Playlists|


## Compile

```shell
##### Compiling pipewire for MuOS, Rocknix and Knulli
git clone https://gitlab.freedesktop.org/pipewire/pipewire.git
cd pipewire
./meson -C build -Dsession-managers=none # Use -Dsession-managers=none because wireplumber with lua is currently borked
cd build
make


##### Now compiling MPD ( version 0-23.17 )

wget https://www.musicpd.org/download/mpd/0.23/mpd-0.23.17.tar.xz
bsdtar -xf mpd-0.23.17.tar.xz
cd mpd-0.23.17
mkdir build
meson setup build   -Djack=disabled   -Dshout=disabled   -Diso9660=disabled   -Dcdio_paranoia=disabled   -Dmad=disabled   -Dmpg123=disabled   -Dvorbis=disabled   -Dopus=disabled   -Dflac=disabled   -Dwavpack=disabled   -Dffmpeg=enabled   -Dsidplay=disabled   -Dmodplug=disabled   -Dwildmidi=disabled   -Dfluidsynth=disabled   -Dmikmod=disabled   -Dlibsamplerate=disabled   -Dsndfile=disabled   -Dsoxr=disabled   -Dsqlite=disabled   -Ddbus=disabled   -Dzeroconf=disabled   -Dwebdav=disabled   -Dnfs=disabled   -Dupnp=disabled   -Dnfs=disabled    -Dsndio=disabled   -Dpulse=disabled -Dopenal=disabled
cd build
ninja
```
