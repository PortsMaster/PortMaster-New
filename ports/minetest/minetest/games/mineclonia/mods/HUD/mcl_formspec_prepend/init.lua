core.register_on_joinplayer(function(player)
	player:set_formspec_prepend(mcl_vars.gui_nonbg .. mcl_vars.gui_bg_color .. mcl_vars.gui_bg_img)
end)
