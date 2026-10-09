## Notes

GlitchScope is a music player with real-time MilkDrop visualizations, tracker
and chip music playback, Internet radio, and Modland/ModArchive browsing.

Thanks to [dendec](https://github.com/dendec/glitchscope) for creating GlitchScope,
the projectM and MilkDrop preset creators for the visualizations, and the
SoLoud, FFmpeg and tracker/chip decoder
contributors for the audio engines. Thanks to the PortMaster community for
handheld integration and testing.

Copy your music to `glitchscope/music/`. No demo tracks are bundled. Wi-Fi is
needed for Internet radio and downloading tracks from online catalogs; local
music and previously downloaded tracks can be played offline. Download optional
preset collections from the Presets menu. Installed collections
are stored as archives in `glitchscope/presets/`; no collections are bundled.

## Runtime requirements

Requires 64-bit ARM firmware with the glibc version listed in `port.json` or newer,
SDL2, OpenGL ES 2, ALSA, libstdc++ with GLIBCXX_3.4.30 and libgcc_s. System libraries and graphics
drivers are provided by the firmware; codec libraries are in
`glitchscope/libs.aarch64/`. See `glitchscope/runtime-requirements.txt`.

## Controls

Use the button labels shown in the menu footer; face-button labels can vary
with the device/controller layout.

| Button | Action |
| --- | --- |
| Start | Open/close menu |
| Select | Toggle information overlay |
| D-pad | Navigate menu |
| Confirm / Back (see footer) | Open selection / go back |
| L1 / R1 | Previous / next preset |
| Start + Select | Exit through PortMaster |

Help in the menu documents playback, seeking, favorites and context controls.
Settings includes language, frame rate and adaptive resolution. Turn the
visualizer off to reduce power use while listening.

## Compile

```sh
git clone --recursive https://github.com/dendec/glitchscope.git
cd glitchscope
make dist-portmaster
```

Requires Docker, Make, Python 3 and binutils on the build host. Output:
`dist/glitchscope.zip`; submission tree:
`dist/portmaster-submit/ports/glitchscope/`.

## Licenses

GlitchScope is GPL-2.0-or-later. Dependency notices are in `glitchscope/licenses/`.
Sources and build recipes: https://github.com/dendec/glitchscope

## Testing status

Device/firmware testing is still pending.

| Firmware | Device / resolution | Result |
| --- | --- | --- |
| ROCKNIX | Pending | Not tested |
| muOS | Pending | Not tested |
| dArkOS | Pending | Not tested |
| Knulli | Pending | Not tested |
| AmberELEC | Pending | Not tested |
| ArkOS | Pending | Not tested |

Device checks must cover startup, controls, playback, radio, visualization and
exit, at 640x480, 1024x768, 1280x720 and 720x720. Codec library requirements
on target firmware have not yet been confirmed.
