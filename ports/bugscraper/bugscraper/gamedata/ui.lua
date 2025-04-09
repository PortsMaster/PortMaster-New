require "util"
local Class = require "class"

local UI = Class:inherit()

function UI:init(x,y)
end

function UI:draw_half_icon_bar(x, y, val, max_val, img_full, img_half, img_empty, margin)
	-- Draw a bar in this style:
	-- ⚫︎ ⚫︎ ⚫︎ ◐ 〇 〇 〇
	margin = margin or 0
	local iy = floor(y)
	local img_w = img_full:getWidth() + margin
	local full_w = floor(max_val/2 - 1) * img_w + margin
	local x1 = x - full_w *.5

	for i=0, max_val-1, 2 do
		local img = img_empty
		if i < val then     img = img_full    end
		if i+1 == val then    img = img_half     end 

		local ix = floor(x1 + img_w*(i/2))
		gfx.draw(img, ix, iy)
		gfx.print(i, ix, iy+8)
	end
end

function UI:draw_icon_bar(x, y, val, max_val, img_full, img_empty, margin)
	-- Draw a bar in this style:
	-- ♥️ ♥️ ♥️ ♥️ ♡ ♡ ♡ 
	margin = margin or 0
	local iy = floor(y)
	local img_w = img_full:getWidth() + margin
	local full_w = max_val * img_w + margin
	local x1 = x - full_w *.5
	for i=0, max_val-1 do
		local img = (i < val) and img_full or img_empty
		local ix = floor(x1 + img_w*i)
		gfx.draw(img, ix, iy)
	end
end

function UI:draw_progress_bar(x, y, w, h, val, max_val, col_fill, col_out, col_fill_shadow, text, text_col, font)
	x = floor(x)
	y = floor(y)
	w = floor(w)
	h = floor(h)
	rect_color(col_out, "fill", x, y, w, h)

	local prog_w = floor( (w-2) * (val/max_val) )
	rect_color(col_fill,        "fill", x+1, y+1,   prog_w, h-2)
	rect_color(col_fill_shadow, "fill", x+1, y+h-2, prog_w, 1)

	text = text or ""
	text_col = text_col or COL_WHITE 
	font = font or FONT_MINI
	local old_font = gfx.getFont()
	gfx.setFont(font)
	print_color(COL_WHITE, text, x+1, y-2)
	gfx.setFont(old_font)
end

return UI:new()