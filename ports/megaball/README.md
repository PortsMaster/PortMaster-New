## Notes

Thanks [helpcomputer](https://helpcomputer.itch.io) (Adam) for creating this fantastic game and releasing it under an MIT license.


## Controls

| Button | Action        |
| -------| ------------- |
| D-PAD  | Movement      |
| START  | Menu          |
| A      | Self-destruct |


## Compile

```shell
apt update
apt install wget git python3-venv   # python >=3.8 is required

# Setup pyxel virtual env
python3 -m venv pyxel-venv
source pyxel-venv/bin/activate
pip install pyxel

# Test the game
git clone https://github.com/PortsMaster/PortMaster-New.git
cd ports/megaball
pyxel run megaball/gamedata/main.py
```
