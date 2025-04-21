import os
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

    # Check for chitin.key (case-insensitive)
    return any(f.name.lower() == "chitin.key" for f in folder_path.rglob("*") if f.is_file())

# Filter valid games based on folder contents
GAMES = [
    entry
    for entry in ALL_GAMES
    if game_folder_valid(BASE_DIR / entry[0])
]

# Always add Exit as the final option
GAMES.append(("exit", "Exit"))

UP, DOWN, LEFT, RIGHT = 0, 1, 2, 3
BUTTON_A, BUTTON_B, BUTTON_START, BUTTON_SELECT = 4, 5, 6, 7


class Input:
    def __init__(self):
        self.pressing = []
        self.pressed = []

    def get(self):
        self.pressing.clear()
        self.pressed.clear()

        # Held
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

        # Pressed
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


class MenuApp:
    def __init__(self):
        self.selected = 0
        self.input = Input()
        pyxel.init(160, 120)
        pyxel.run(self.update, self.draw)

    def update(self):
        self.input.get()

        if UP in self.input.pressed:
            self.selected = (self.selected - 1) % len(GAMES)
        elif DOWN in self.input.pressed:
            self.selected = (self.selected + 1) % len(GAMES)
        elif BUTTON_A in self.input.pressed or BUTTON_START in self.input.pressed:
            script = GAMES[self.selected][0]
            if script == "exit":
                pyxel.quit()
            else:
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

        title = "Select a GemRB Game"
        line_height = 6
        title_height = line_height
        title_padding = 4
        menu_height = len(GAMES) * line_height
        total_height = title_height + title_padding + menu_height
        top = (pyxel.height - total_height) // 2

        title_x = (pyxel.width - len(title) * 4) // 2
        pyxel.text(title_x, top, title, 10)

        for i, (_, name) in enumerate(GAMES):
            y = top + title_height + title_padding + i * line_height
            if i == self.selected:
                pyxel.rect(20, y - 1, 120, 7, 1)
                pyxel.text(25, y, f"> {name}", 7)
            else:
                pyxel.text(25, y, f"  {name}", 6)


if __name__ == "__main__":
    MenuApp()

