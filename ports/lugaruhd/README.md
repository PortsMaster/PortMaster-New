## Notes

Thanks to:
* [WolfireGames](https://www.wolfire.com/) for creating this awesome game and opensourcing it. Check out the [source](https://github.com/WolfireGames/lugaru) here.
* JanTrueno for porting the game.
* Athruz for suggesting Lugaru.
* PortMaster testers for refining the control scheme.

## Details and Information  

| Detail             | Info                 |
|-------------------|----------------------|
| Ready to Run      | Yes                  |
| Engine/Framework  | C+SDL+GL4ES          |
| Architectures     | 64bit                |
| Aspect Ratio      | Native all aspects   |
| Rumble Support    | No                   |
| Tested Versions   | RTR                  |
| Controls         | GPTK                 |
| Joysticks Required | Dual                |

## Controls

| Button             | Action                 |
|-------------------|----------------------|
| Start         | Menu Action (Enter)         |
| Back          | Menu Back (Escape)          |
| A            | Primary Action (Attack)      |
| B            | Jump                         |
| X            | Equip/Pickup Weapon          |
| Y            | Crouch/Sneak/Roll            |
| Up (D-pad)   | Move Forward (Up)           |
| Down (D-pad) | Move Backward (Down)        |
| Left (D-pad) | Move Left                   |
| Right (D-pad)| Move Right                  |
| Left Analog  | Move (Up/Down/Left/Right)   |
| Right Analog | Camera (Up/Down/Left/Right) |

## Compile

```shell
- sudo apt update
- sudo apt install -y cmake libsdl2-dev libglu1-mesa-dev libjpeg-dev libpng-dev libopenal-dev libogg-dev libvorbis-dev
- git clone https://github.com/WolfireGames/lugaru/tree/master
- cd lugaru
- mkdir build && cd build
- cmake ..
- make -j12
```
