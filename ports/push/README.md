## Notes

Thanks [yuta](https://helpcomputer.itch.io) (HZ3 Software) for creating this fantastic game, which you can download free at [https://yyuta342.itch.io/push](https://yyuta342.itch.io/push)


## Controls

| Button | Action   |
| D-PAD  | Movement |
| A      | Select   |
| Y      | Menu     |


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
cd ports/push
pyxel run megaball/gamedata/main.py
```
