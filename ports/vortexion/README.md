## Notes

Thank to [Adam](https://github.com/helpcomputer) for making this awesome game.

## Controls

| Button | Action |
|--|--| 
|Dpad/Left stick|Movement|
|A|OK/Pause|
|B|Fire|

## Build instructions

```shell
apt update
apt install wget git python3-venv   # python >=3.8 is required

# Setup pyxel virtual env
python3 -m venv pyxel-venv
source pyxel-venv/bin/activate
pip install --upgrade pip
wget "https://github.com/kitao/pyxel/raw/refs/heads/main/python/requirements.txt"
pip install -r requirements.txt
pip install pyxel

# Pack the game
git clone https://github.com/cdeletre/vortexion.git
cd vortexion
mv src vortexion
pyxel package vortexion vortexion/main.py

# Test the game package
pyxel play vortexion.pyxapp
```