codename = "linux"
file_include("script/share/level_dialog.lua")
dialogLoad("script/"..codename.."/demo_")
file_include("script/share/prog_demo.lua")
demo_display("images/"..codename.."/poster.png", 0, 0)

planTalk("poster1")
planTalk("poster2")
planStop()
