--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- skin table
local skin = {}

-- skin info (you always need this in a skin)
skin.name = "Orange"
skin.author = "Nikolai Resokav"
skin.version = "1.0"
skin.base = "Blue"

-- controls 
skin.controls = {}

-- multichoicerow
skin.controls.multichoicerow_body_hover_color       = {1, 0.6, 0, 1}

-- slider
skin.controls.slider_bar_outline_color              = {0.86, 0.86, 0.86, 1}

-- checkbox
skin.controls.checkbox_check_color                  = {1, 0.6, 0, 1}

-- radiobutton
skin.controls.radiobutton_body_color                = {1, 1, 1, 1}
skin.controls.radiobutton_check_color               = {1, 0.6, 0, 1}
skin.controls.radiobutton_inner_border_color        = {0.8, 0.48, 0, 1}
skin.controls.radiobutton_text_font                 = smallfont


-- columnlistrow
skin.controls.columnlistrow_body_selected_color     = {1, 0.6, 0, 1}
skin.controls.columnlistrow_body_hover_color        = {1, 0.68, 0.2, 1}

-- menuoption
skin.controls.menuoption_body_hover_color           = {1, 0.6, 0, 1}

-- register the skin
loveframes.RegisterSkin(skin)

---------- module end ----------
end
