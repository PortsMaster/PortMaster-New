import os
import random
import pyxel
from pathlib import Path

# Define all possible games
ALL_GAMES = [
    ("bg1", "Baldur's Gate"),
    ("bg2", "Baldur's Gate II"),
    ("bg2ee", "Baldur's Gate II EE"),
    ("demo", "GemRB Demo"),
    ("iwd", "Icewind Dale"),
    ("how", "Icewind Dale - HoW or ToTL"),
    ("iwd2", "Icewind Dale II"),
    ("pst", "Planescape: Torment"),
]

BASE_DIR = Path(__file__).resolve().parent

def game_folder_valid(script_path: Path) -> bool:
    folder_name = script_path.stem.rsplit('-', 1)[-1]
    folder_path = BASE_DIR / "games" / folder_name
    if not folder_path.is_dir():
        return False
    return any(f.name.lower() == "chitin.key" for f in folder_path.rglob("*") if f.is_file())

GAMES = [
    entry
    for entry in ALL_GAMES
    if game_folder_valid(BASE_DIR / entry[0])
]

GAMES.append(("quit", "Exit"))

UP, DOWN, LEFT, RIGHT = 0, 1, 2, 3
BUTTON_A, BUTTON_B, BUTTON_START, BUTTON_SELECT = 4, 5, 6, 7

class Input:
    def __init__(self):
        self.pressing = []
        self.pressed = []

    def get(self):
        self.pressing.clear()
        self.pressed.clear()

        if pyxel.btn(pyxel.KEY_UP) or pyxel.btn(pyxel.KEY_W) or pyxel.btn(pyxel.GAMEPAD1_BUTTON_DPAD_UP):
            self.pressing.append(UP)
        elif pyxel.btn(pyxel.KEY_DOWN) or pyxel.btn(pyxel.KEY_S) or pyxel.btn(pyxel.GAMEPAD1_BUTTON_DPAD_DOWN):
            self.pressing.append(DOWN)
        if pyxel.btn(pyxel.KEY_LEFT) or pyxel.btn(pyxel.KEY_A) or pyxel.btn(pyxel.GAMEPAD1_BUTTON_DPAD_LEFT):
            self.pressing.append(LEFT)
        elif pyxel.btn(pyxel.KEY_RIGHT) or pyxel.btn(pyxel.KEY_D) or pyxel.btn(pyxel.GAMEPAD1_BUTTON_DPAD_RIGHT):
            self.pressing.append(RIGHT)
        if pyxel.btn(pyxel.KEY_Z) or pyxel.btn(pyxel.KEY_K) or pyxel.btn(pyxel.GAMEPAD1_BUTTON_A):
            self.pressing.append(BUTTON_A)
        if pyxel.btn(pyxel.KEY_X) or pyxel.btn(pyxel.KEY_L) or pyxel.btn(pyxel.GAMEPAD1_BUTTON_B):
            self.pressing.append(BUTTON_B)
        if pyxel.btn(pyxel.KEY_RETURN) or pyxel.btn(pyxel.GAMEPAD1_BUTTON_START):
            self.pressing.append(BUTTON_START)
        if pyxel.btn(pyxel.KEY_SPACE) or pyxel.btn(pyxel.GAMEPAD1_BUTTON_BACK):
            self.pressing.append(BUTTON_SELECT)

        if pyxel.btnp(pyxel.KEY_UP) or pyxel.btnp(pyxel.KEY_W) or pyxel.btnp(pyxel.GAMEPAD1_BUTTON_DPAD_UP):
            self.pressed.append(UP)
        elif pyxel.btnp(pyxel.KEY_DOWN) or pyxel.btnp(pyxel.KEY_S) or pyxel.btnp(pyxel.GAMEPAD1_BUTTON_DPAD_DOWN):
            self.pressed.append(DOWN)
        if pyxel.btnp(pyxel.KEY_LEFT) or pyxel.btnp(pyxel.KEY_A) or pyxel.btnp(pyxel.GAMEPAD1_BUTTON_DPAD_LEFT):
            self.pressed.append(LEFT)
        elif pyxel.btnp(pyxel.KEY_RIGHT) or pyxel.btnp(pyxel.KEY_D) or pyxel.btnp(pyxel.GAMEPAD1_BUTTON_DPAD_RIGHT):
            self.pressed.append(RIGHT)
        if pyxel.btnp(pyxel.KEY_Z) or pyxel.btnp(pyxel.KEY_K) or pyxel.btnp(pyxel.GAMEPAD1_BUTTON_A):
            self.pressed.append(BUTTON_A)
        if pyxel.btnp(pyxel.KEY_X) or pyxel.btnp(pyxel.KEY_L) or pyxel.btnp(pyxel.GAMEPAD1_BUTTON_B):
            self.pressed.append(BUTTON_B)
        if pyxel.btnp(pyxel.KEY_RETURN) or pyxel.btnp(pyxel.GAMEPAD1_BUTTON_START):
            self.pressed.append(BUTTON_START)
        if pyxel.btnp(pyxel.KEY_SPACE) or pyxel.btnp(pyxel.GAMEPAD1_BUTTON_BACK):
            self.pressed.append(BUTTON_SELECT)

class FlameEffect:
    def __init__(self, width, height, decay_pallet, update_every=8):
        self.width = width
        self.height = height
        self.buffer = [[0 for _ in range(width)] for _ in range(height)]
        self.frame_count = 0
        self.decay_pallet = decay_pallet
        self.max_decay = len(decay_pallet)-1
        self.update_every = update_every  # how many frames to skip between updates

    def update(self):
        self.frame_count += 1
        if self.frame_count % self.update_every != 0:
            return  # Skip this frame

        # Give the base a bit more variance
        for x in range(self.width):
            if random.randint(0, 3):
                self.buffer[self.height - 1][x] = self.max_decay
            else:
                self.buffer[self.height - 1][x] = random.randint(max(self.max_decay - 5, 1), self.max_decay-1)

        for y in range(self.height - 2, -1, -1):
            for x in range(self.width):
                decay = random.randint(0, 1)
                drift = random.randint(0, 2)
                src_x = x

                if drift == 1 and x > 0:
                    src_x -= 1
                elif drift == 2 and x < self.width - 1:
                    src_x += 1

                below = self.buffer[y + 1][src_x]
                # self.buffer[y][x] = max(below - (1 - decay & 1), 0)
                self.buffer[y][x] = max(below - decay, 0)

    def draw(self):
        for y in range(self.height):
            for x in range(self.width):
                decay = self.buffer[y][x]
                if decay > 0:
                    pyxel.pset(x, y, self.decay_pallet[decay])


class MenuApp:
    def __init__(self):
        self.selected = 0
        self.input = Input()
        pyxel.init(160, 120, title="GemRB Launcher")
        self.select_file = BASE_DIR / "game_select.txt"

        # Clear game.
        try:
            with open(self.select_file, "w") as f:
                f.write("quit")

        except Exception as e:
            print(f"Failed to write game selection: {e}")

        # Optional: tweak the colour palette
        pyxel.colors[1] = 0x050503
        pyxel.colors[2] = 0x331400
        pyxel.colors[3] = 0x662100
        pyxel.colors[4] = 0x993300
        pyxel.colors[5] = 0xcc4400
        pyxel.colors[6] = 0xff6600
        pyxel.colors[7] = 0xff9933
        pyxel.colors[8] = 0xffcc66
        pyxel.colors[9] = 0xffff99
        pyxel.colors[10] = 0xffffff

        # Allow a slower decay rate.
        decay_pallet = [0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10]

        self.flames = FlameEffect(pyxel.width, pyxel.height, decay_pallet, 3)
        pyxel.run(self.update, self.draw)

    def update(self):
        self.flames.update()
        self.input.get()

        if UP in self.input.pressed:
            self.selected = (self.selected - 1) % len(GAMES)

        elif DOWN in self.input.pressed:
            self.selected = (self.selected + 1) % len(GAMES)

        elif BUTTON_A in self.input.pressed or BUTTON_START in self.input.pressed:
            script = GAMES[self.selected][0]

            self.launch_script(script)

    def launch_script(self, script):
        select_file = BASE_DIR / "game_select.txt"
        try:
            with open(select_file, "w") as f:
                f.write(script)
            print(f"Wrote selected game to: {select_file}")
        except Exception as e:
            print(f"Failed to write game selection: {e}")
        pyxel.quit()

    def draw(self):
        pyxel.cls(0)
        self.flames.draw()

        title = "Select a GemRB Game"
        line_height = 6
        title_height = line_height
        title_padding = 4
        menu_height = len(GAMES) * line_height
        total_height = title_height + title_padding + menu_height
        top = (pyxel.height - total_height) // 2 - 5

        # Left-aligned title
        pyxel.text(10, top, title, 12)

        for i, (_, name) in enumerate(GAMES):
            y = top + title_height + title_padding + i * line_height
            if i == self.selected:
                pyxel.text(10, y, f"> {name}", 7)
            else:
                pyxel.text(10, y, f"  {name}", 6)


if __name__ == "__main__":
    MenuApp()

