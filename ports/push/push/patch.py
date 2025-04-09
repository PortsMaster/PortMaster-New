import re

s_levels = "./gamedata/s_levels.py"
with open(s_levels, "r") as file:
    content = file.read()

content = re.sub(
    r'self\.level_title = f"LEVEL {self\.map_json\[self\.level_index\]\["title"\]}"',
    'level_data = self.map_json[self.level_index]; self.level_title = f"LEVEL {level_data[\'title\']}"',
    content,
)

with open(s_levels, "w") as file:
    file.write(content)
