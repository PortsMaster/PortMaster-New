## Notes
Thanks to the [Roy E & RaMMicHaeL](https://github.com/royeldar/icytower) for remaking this game in Allegro 5 and making it available for free!

## Controls

| Button | Action |
|--|--| 
|DPAD| Move|
|A/B| Jump|
|X| Pause|

## Compile

```shell

// Requirements compile Allegro 5 with SDL2 build

OpenGL: ES 2.0
Primitives addon: yes
Image addon: yes
FreeImage: yes
libpng: yes
libjpeg: yes
libwebp: yes
Font addon: yes
Audio addon: yes
OpenAL: yes
OpenSL: NO
Acodec addon: yes
FLAC: yes
DUMB: yes
Ogg/Vorbis: yes
Opus: NO
MP3: NO
TTF addon: yes
Color addon: yes
Memfile addon: yes
PhysFS addon: yes
Native Dialog addon: NO

git clone https://github.com/Cebion/icytower
cd icytower
make
```