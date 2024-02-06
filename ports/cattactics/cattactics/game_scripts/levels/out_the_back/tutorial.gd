# tutorial
jump("tutorial_state_%s" % [get_variable("tutorial_state", 1)])
return()

# block:tutorial_state_10
textbox("Hey, wait up!", "Snail")
textbox("High Affinity boosts your attack power when another cat is standing right next to you. You may have already seen it earlier when you fought against the Gray Cats, due to your high Affinity towards Spyro.", "Snail")
textbox("Every time you Pet a cat you have a chance to recruit them to your side and join your party!", "Snail")
textbox("If you are able to raise your Affinity with Misty, she will successfully join your party and follow you to the next area.", "Snail")
set_variable("tutorial_state", 11)
return()

# block:tutorial_state_11
return()
