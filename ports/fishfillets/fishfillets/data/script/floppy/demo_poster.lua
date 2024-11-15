
codename = "floppy"
file_include("script/share/level_dialog.lua")
dialogLoad("script/"..codename.."/demo_")

-- -----------------------------------------------------------------
file_include("script/share/prog_demo.lua")
demo_display("images/"..codename.."/poster.png", 0, 0)

planTalk("dlg-x-poster1")
planTalk("dlg-x-poster2")
planSpace()
planTalk("dlg-x-poster3")
planSpace()
planTalk("dlg-x-poster4")
planTalk("dlg-x-poster5")
planTalk("dlg-x-poster6")
planTalk("dlg-x-poster7")
planTalk("dlg-x-poster8")
planTalk("dlg-x-poster9")
planSpace()
planTalk("dlg-x-poster10")
planTalk("dlg-x-poster11")
planTalk("dlg-x-poster12")
planTalk("dlg-x-poster13")
planStop()

