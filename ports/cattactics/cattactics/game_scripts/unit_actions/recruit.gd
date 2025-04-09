# recruit a unit to our party by changing the owner ID of the spawned unit
get_variable("recruit_unit").set_unit_owner(get_variable("recruit_unit_owner"))

# will add unit to party if it's recruitable, if not it will get stats from existing party stats
gamescene.sync_spawned_unit_with_party_unit(get_variable("recruit_unit").get_instance_id())

gamescene.execute_scripts("on_recruit", false, get_variable("recruit_unit").get_instance_id())

set_variable("recruited_unit_%s" % [get_variable("recruit_unit").get_instance_id()], true)

play_sfx("recruited")

textbox("%s joined the party!" % [get_variable("recruit_unit").get_unit_name()])
hide_textbox()
return()
