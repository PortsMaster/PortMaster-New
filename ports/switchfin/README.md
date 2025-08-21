## Notes

Special thanks to [dragonflylee](https://github.com/dragonflylee) for making Switchfin and helping getting it compiled!

Thanks to BinaryCounter for Westonpack!

## Other Servers / File paths

If you have your Media files in a folder you cant access then go into the config.json and edit the
```"url": "file://../../../" ```

If you want to connect to any other kind of Server ( WebDav, Apache, nginx or FTP/SFTP ) then edit the remote section of the config.json, here are some examples 
```
{
  "remotes": [
    {
      "name": "xiaoya",
      "passwd": "guest_Api789",
      "url": "webdav://192.168.1.5:5678/dav",
      "user": "guest"
    },
    {
      "name": "rpi",
      "url": "sftp//pi:raspberry@192.168.1.5/media"
    },
    {
      "name": "rclone",
      "url": "http://192.168.1.5:8000"
    }
  ]
}
```
## Controls

| Button | Action |
|--|--| 
|Dpad|Movement|
|A|OK|


## Compile

```shell
# FFMPEG 4.4.1
wget -qO- https://ffmpeg.org/releases/ffmpeg-4.4.1.tar.xz | tar Jxf - -C ffmpeg-4.4.1
cd ffmpeg-4.4.1
./configure -disable-programs --disable-debug --disable-avdevice \
		--enable-nonfree --enable-openssl --disable-doc --enable-libass --enable-zlib \
		--enable-libdrm  --enable-libudev  \
		--disable-protocols --enable-protocol=file,http,tcp,udp,hls,https,tls,httpproxy \
		--disable-muxers --disable-encoders --enable-encoder=png
make 
# MPV
wget -qO- https://github.com/mpv-player/mpv/archive/v0.36.0.tar.gz | tar zxf - -C mpv
cd mpv
meson setup build  \
		--default-library=shared -Dlibmpv=true -Dcplayer=false -Dtests=false \
		-Dlua=disabled -Dlibarchive=disabled -Dsdl2=enabled
cd build && ninja && ninja install

# Switchfin
git clone https://github.com/dragonflylee/switchfin.git --recurse-submodules --shallow-submodules
mkdir build && cd build
cmake .. \
		-DCMAKE_BUILD_TYPE=Release \
		-DPLATFORM_DESKTOP=ON \
		-DUSE_GLFW=ON \ # Set that to -DUSE_SDL2=ON if you want to compile for Rocknix
		-DUSE_GL2=ON

make -j24
```
