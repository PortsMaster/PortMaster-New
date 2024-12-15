import pyxel
import json

blocks_json = []

class BlocksData:
    def __init__(self):
        with open(file="./assets/images/push_blocks.json", mode="r", encoding="utf-8") as f:
            blocks_json = json.load(f)
        
        self.slices_json = blocks_json["meta"]["slices"]
        self.img: pyxel.Image = None