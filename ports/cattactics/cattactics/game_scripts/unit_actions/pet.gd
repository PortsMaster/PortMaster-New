set_variable("petting_strings", ["%s brushed up against %s... will they get along?" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()], "%s tried to lick %s... huh?" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()], "Looks like %s is bumping noses with %s?!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()]])

get_variable("petting_strings").shuffle()
set_variable("petting_string", get_variable("petting_strings")[0])

# get the attacked unit to face the attacking unit
gamescene.sprite_face_sprite(get_variable("unit_action_attacked").get_instance_id(), get_variable("unit_action_attacking").get_instance_id())

textbox(get_variable("petting_string"))
hide_textbox()

play_sfx("action_pet")
animate_sprite(get_variable("unit_action_attacking").get_instance_id(), "attack_%s" % [get_variable("unit_action_attacking").get_facing()], get_variable("unit_action_attacking").get_facing(), 0.5)
wait(0.2)
play_sfx("action_pet")
animate_sprite(get_variable("unit_action_attacking").get_instance_id(), "attack_%s" % [get_variable("unit_action_attacking").get_facing()], get_variable("unit_action_attacking").get_facing(), 0.5)
wait(0.5)


set_variable("petting_chance", max(0.1, ((float(max(1, get_variable("unit_action_attacked").get_stat("level"))) / float(max(1, get_variable("unit_action_attacked").get_stat("level")))) / 5) + get_variable("unit_action_attacking").get_affinity(get_variable("unit_action_attacked").get_instance_id())))

# textbox(get_variable("petting_chance"))

set_variable("petting_successful", (get_variable("petting_chance") >= randf_range(0, 1)))

# TODO: fix recruitment chance
set_variable("recruitment_successful", ((get_variable("petting_chance")) >= randf_range(0, 1)))


jump_if("petting_successful", get_variable("petting_successful"), true)
jump_if("petting_unsuccessful", get_variable("petting_successful"), false)

return()

# block:petting_successful
include("unit_actions/raise_affinity.gd")

# random buff
set_variable("random_stat_buff_unit", get_variable("unit_action_attacking"))
include("unit_actions/random_stat_buff.gd")

set_variable("random_stat_buff_unit", get_variable("unit_action_attacked"))
include("unit_actions/random_stat_buff.gd")

jump_if("recruitment_successful", (get_variable("recruitment_successful") == true and not get_variable("unit_action_attacking").get_unit_owner_type() in [1,2] and not get_variable("unit_action_attacked").get_unit_owner_type() == 0), true)
return()

# block:petting_unsuccessful
textbox("%s didn't like it, and attacked %s in response!" % [get_variable("unit_action_attacked").get_unit_name(), get_variable("unit_action_attacking").get_unit_name()])
hide_textbox()

set_variable("unit_action_attacked_facing", get_variable("unit_action_attacked").get_facing())
play_sfx("attack_general")
animate_sprite(get_variable("unit_action_attacked").get_instance_id(), "attack_%s" % [get_variable("unit_action_attacked_facing")], get_variable("unit_action_attacked_facing"))

include("unit_actions/lower_affinity.gd")
return()

# block:recruitment_successful
set_variable("recruit_unit_owner", get_variable("unit_action_attacking").get_unit_owner_type())
set_variable("recruit_unit", get_variable("unit_action_attacked"))
include("unit_actions/recruit.gd")
return()
