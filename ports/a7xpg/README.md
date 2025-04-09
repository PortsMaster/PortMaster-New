## Notes
Thanks to the [Kenta Cho](https://www.asahi-net.or.jp/~cs8k-cyu/windows/a7xpg_e.html) for creating this game and making it available for free!
 
## Controls

| Button | Action |
|--|--| 
|DPAD| Move|
|A/B/Y| Boost|
|X| Pause|
|Y| Space |
 

## Compile

```shell
dget -U http://deb.debian.org/debian/pool/main/a/a7xpg/a7xpg_0.11.dfsg1-11.dsc
# change hardcoded paths in 
src/abagames/util/sdl/Sound.d
src/abagames/util/sdl/Texture.d
# comment out joystick initialization in 
# src/abagames/util/sdl/Input.d
  public void openJoystick() {
  }
 
```