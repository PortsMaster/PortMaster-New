## Notes

| Detail      |   Value             |
| ------------------ | --------------- |
| Ready to Run       | Yes             |
| Engine/Framework   | C#/Foster  |
| Architectures      | 64 Bit          |
| Aspect ratio       | 16:9 Forced        |
| Rumble support     | No              |
| Tested versions    | Custom fork, see below |
| Controls           | Native          |
| Joysticks required | Double            |

## Known issues
On some versions of MuOS, the audio configuration isnt compatible with FMOD. You will experience no audio on this port. You can upgrade to a newer version.

Performance on low end devices can fluctuate. Performance sliders can be lowered in the settings. Using the 30 fps limiter is recommended for a more consistent experience. 


## Thanks
A huge thank you to Extremely OK Games (EXOK) for creating and open-sourcing Celeste 64.

Thanks to JanTrueno for forking the project, developing the modifications and optimizations, and porting Celeste 64 to additional platforms and hardware.

This PortMaster version builds upon their work with further platform-specific optimizations and performance options.

## Controls

| Button | Action |
|--|--| 
|D-Pad/L-Stick|Move|
|R-Stick|Camera|
|A/B|Jump|
|X/Y|Dash|
|L1|Wallgrab|
|Start|Menu|


## Compile
Crosscompilation setup on Linux X86_64:
```shell
git clone https://github.com/JanTrueno/Celeste64.git
cd Celeste64
sudo dpkg --add-architecture arm64
sudo tee /etc/apt/sources.list.d/arm64-ports.list <<'EOF'
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble-security main restricted universe multiverse
EOF
sudo apt update
sudo apt install cmake gcc-aarch64-linux-gnu libsdl2-dev:arm64
./build-arm64.sh
```
