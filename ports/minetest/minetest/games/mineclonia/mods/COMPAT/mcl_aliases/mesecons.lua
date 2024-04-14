-- This file registers aliases for the /give /giveme commands.

minetest.register_alias("mesecons:mesecon", "mesecons:wire_00000000_off")
minetest.register_alias("mesecons:object_detector", "mesecons_detector:object_detector_off")
minetest.register_alias("mesecons:wireless_inverter", "mesecons_wireless:wireless_inverter_on")
minetest.register_alias("mesecons:wireless_receiver", "mesecons_wireless:wireless_receiver_off")
minetest.register_alias("mesecons:wireless_transmitter", "mesecons_wireless:wireless_transmitter_off")
minetest.register_alias("mesecons:switch", "mesecons_switch:mesecon_switch_off")
minetest.register_alias("mesecons:button", "mesecons_button:button_off")
minetest.register_alias("mesecons:piston", "mesecons_pistons:piston_normal_off")
minetest.register_alias("mesecons:mesecon_torch", "mesecons_torch:mesecon_torch_on")
minetest.register_alias("mesecons:torch", "mesecons_torch:mesecon_torch_on")
minetest.register_alias("mesecons:pressure_plate_stone", "mesecons_pressureplates:pressure_plate_stone_off")
minetest.register_alias("mesecons:pressure_plate_wood", "mesecons_pressureplates:pressure_plate_wood_off")
minetest.register_alias("mesecons:pressure_plate_birchwood", "mesecons_pressureplates:pressure_plate_birchwood_off")
minetest.register_alias("mesecons:pressure_plate_acaciawood", "mesecons_pressureplates:pressure_plate_acaciawood_off")
minetest.register_alias("mesecons:pressure_plate_darkwood", "mesecons_pressureplates:pressure_plate_darkwood_off")
minetest.register_alias("mesecons:pressure_plate_sprucewood", "mesecons_pressureplates:pressure_plate_sprucewood_off")
minetest.register_alias("mesecons:pressure_plate_junglewood", "mesecons_pressureplates:pressure_plate_junglewood_off")
minetest.register_alias("mesecons:mesecon_socket", "mesecons_temperest:mesecon_socket_off")
minetest.register_alias("mesecons:mesecon_inverter", "mesecons_temperest:mesecon_inverter_on")
minetest.register_alias("mesecons:noteblock", "mesecons_noteblock:noteblock")
minetest.register_alias("mesecons:delayer", "mesecons_delayer:delayer_off_1")
minetest.register_alias("mesecons:solarpanel", "mesecons_solarpanel:solar_panel_off")


--Backwards compatibility
minetest.register_alias("mesecons:mesecon_off", "mesecons:wire_00000000_off")
minetest.register_alias("mesecons_pistons:piston_sticky", "mesecons_pistons:piston_sticky_on")
minetest.register_alias("mesecons_pistons:piston_normal", "mesecons_pistons:piston_normal_on")
minetest.register_alias("mesecons_pistons:piston_up_normal", "mesecons_pistons:piston_up_normal_on")
minetest.register_alias("mesecons_pistons:piston_down_normal", "mesecons_pistons:piston_down_normal_on")
minetest.register_alias("mesecons_pistons:piston_up_sticky", "mesecons_pistons:piston_up_sticky_on")
minetest.register_alias("mesecons_pistons:piston_down_sticky", "mesecons_pistons:piston_down_sticky_on")

--MineClone 2 specials
minetest.register_alias("mesecons_materials:glue", "mcl_mobitems:slimeball")
