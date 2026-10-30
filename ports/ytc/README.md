## Notes

**YTC (Your Tube Client)** is a native, controller-driven YouTube client for
Linux handhelds. It talks to YouTube through its own anonymous Innertube client.

Features: search, Home / channel feeds, Community posts, playlists, Shorts,
comments with replies, favorites, watch-later, history, SponsorBlock,
quality / speed / volume controls, offline downloads, and casting to a linked
device or Chromecast.

Ready to run: no game files or extra data need to be copied in. Requires a network connection.

Source: https://github.com/christopher-roelofs/ytc

## Controls

### Browsing

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move / navigate |
| A | Play / open |
| B | Back |
| X | Sort (comments) / clear text (search) |
| Y | Search |
| Select | Options menu (favorite, watch later, download, cast, …) |
| Start | Main menu (Settings, Downloads, Watch Later, History, …) |
| L1 / R1 | Switch tabs (All / Videos / Shorts / Posts / Playlists) |

### Playback

| Button | Action |
|--|--|
| A | Play / pause |
| Left / Right | Seek 10s (hold to scrub, accelerates) |
| Up / Down | Volume |
| Select | Player options (quality, speed, captions, stats) |
| Start | Menu |
| B | Stop / back |

## Compile

```sh
git clone https://github.com/christopher-roelofs/ytc && cd ytc
./build_tls_deps.sh      # static curl + mbedTLS, baked into the binary
./build_portmaster.sh    # produces build-port/yt_ui
aarch64-linux-gnu-strip -o ytc.aarch64 build-port/yt_ui
```

libmpv is built render-API-only (`-Dlibmpv=true -Dvideo-output-drivers=[]`, LGPL, software decode) against FFmpeg 6.1, and both are bundled in `libs.aarch64` since several CFWs ship no libmpv.
