
codename = "INTRO"
file_include("script/share/level_dialog.lua")
dialogLoad("script/share/intro_", "sound/share/intro/")

file_include("script/share/prog_demo.lua")
demo_display("images/menu/intro.png", 0, 0)

planTalk("dlg-x-poster1")
planStop()

