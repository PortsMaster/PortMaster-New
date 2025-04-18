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

##### Getting other dependencies that could be useful 

sudo apt install \
libasound2-dev libao-dev libpulse-dev libjack-jackd2-dev libsndfile1-dev \
libmp3lame-dev libvorbis-dev libopus-dev libwavpack-dev libflac-dev \
libsamplerate0-dev libmodplug-dev libmad0-dev libid3tag0-dev \
libnfs-dev libcurl4-openssl-dev libavformat-dev libavcodec-dev \
libfaad-dev libmpdclient-dev libsidplay2-dev libshout3-dev \
libsoxr-dev libupnp-dev libwildmidi-dev libyajl-dev \
libzzip-dev libgme-dev libchromaprint-dev libcdio-paranoia-dev \
libsqlite3-dev libinotifytools0-dev

##### Now compiling MPD ( version 0-23.17 )

wget https://www.musicpd.org/download/mpd/0.23/mpd-0.23.17.tar.xz
bsdtar -xf mpd-0.23.17.tar.xz
cd mpd-0.23.17
mkdir build
meson setup build
cd build
ninja
```
