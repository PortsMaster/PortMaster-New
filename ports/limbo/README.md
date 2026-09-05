# Limbo - PortMaster

Play Store version is **NOT** supported!

## Controls

| Button | Action |
|--|--|
| D-pad / L-stick | Move |
| A | Interact |
| X | Grab |
| Start | Pause Menu |
| Touchscreen | Touch in menu |

## Details

| Detail | Value |
|---|---|
| Ready to Run | No |
| Engine/Framework | Playdead's in-house engine |
| Architectures | 64 Bit |
| Aspect ratio | Adaptive 4:3 or 16:9 |
| Rumble support | No |
| Tested versions | 1.20 Epic Games Mobile |
| Controls | Native |
| Joysticks required | None |

## Folder Structure

```
ports/
  - Limbo.sh
  - limbo/
    - limboloader
    - limbo.toml
    - assets/ *(from the APK)*
      - data/shaders/gles/
      - data/audio/android/
      - dexopt/
      - limbo_android_boot.pkg
      - limbo_android_runtime.pkg
      - settings.txt
    - lib/ *(from the APK)*
      - arm64-v8a/
        - libLimbo.so
        - libc++_shared.so
```

## Patched-in Features

- Fullscreen at the panel's native resolution (patches out the engine's hardcoded 1024px backbuffer-width cap)

## Thanks to

* [Playdead](https://playdead.com/) for creating this stunning game! Check out the game's Epic Games Store page [here](https://store.epicgames.com/p/limbo-mobile-android-300111?lang=en-US).
* binarycounter for [Bogodroid](https://github.com/binarycounter/Bogodroid), the Android loader this port is built on.
* JanTrueno for porting: Limbo.
