extends "res://world/ui/WASDHint.gd"
# Cassette Beasts port: the first steps' movement hint. The game shows the keyboard's movement keys whenever no pad
# is connected; the handheld is the keyboard player (gptokeyb2), so they are hidden as for a pad, and the jump and
# dash prompts (the game's Switch icons, PortOptions.gd) stay. Installed by PortOptions.gd. License: 0BSD.


func update_icons():
	.update_icons()
	if wasd_grid:
		wasd_grid.visible = false
