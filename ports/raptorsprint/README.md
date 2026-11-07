## Notes

Thanks to [omerkot](https://github.com/omerkot/raptor-sprint) for creating Raptor Sprint, a first-person velociraptor race through a prehistoric forest.

Settings has a Detail option and a frame rate counter. Lower Detail if the game runs slowly on your device. Saves, best times and settings are kept in `ports/raptorsprint`.

On a two-screen device this version plays on one screen.

## Controls

| Button | Action |
|--|--|
| D-pad / Left stick | Steer, move in menus |
| A | Jump, choose |
| B | Duck, back |
| R | Sprint |
| Down | Brake |
| Start | Pause |

If A and B come out the wrong way round on your device, turn on Swap A and B in Settings.

## Compile

raylib and the SDL2 headers are in the repository, so only a compiler is needed.

```bash
apt-get install g++-aarch64-linux-gnu
git clone --branch v1.1.3 --depth 1 https://github.com/omerkot/raptor-sprint.git
cd raptor-sprint
CROSS=aarch64-linux-gnu- scripts/build.sh device
```
