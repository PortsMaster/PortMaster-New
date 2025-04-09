## Notes
Thanks to [Dennis Payne](https://gitlab.com/dulsi/mojotron) for creating MOJOTRON: ROBOT WARS and making it available for free! 
 
## Controls

| Button | Action |
|--|--| 
|Left Analogue| Move|
|Right Analogue| Aim|
|R1/L1| Use Item|


## Compile

```shell
git clone --no-checkout https://gitlab.com/dulsi/mojotron.git
cd mojotron
git checkout 1170ce158fa5d7352d5ad53a9241d47603e8bf3f
```
modify makefile add 
```
CXXFLAGS = -Wall -O3 -std=c++17 `pkg-config --cflags sdl2 SDL2_image SDL2_mixer expat` -I/usr/include/SDL2
make
```