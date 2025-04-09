--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- skin table
local skin = {}

-- skin info (you always need this in a skin)
skin.name = "Default"
skin.author = "ingsoc451"
skin.version = "0.9"

local color = function(s, a) return {loveframes.Color(s, a)} end

-- Controls
skin.controls = {}
skin.controls.smallfont = love.graphics.newFont(11)
skin.controls.color_image  = color"FFFFFF"

skin.controls.color_back0  = color"f0f0f0"
skin.controls.color_back1  = color"e0e0e0"
skin.controls.color_back2  = color"c0c0c0"
skin.controls.color_back3  = color"a0a0a0"
skin.controls.color_fore0  = color"505050"
skin.controls.color_fore1  = color"373737"
skin.controls.color_fore2  = color"202020"
skin.controls.color_fore3  = color"101010"
skin.controls.color_active = color"6298b3" --some blue

-- Directives
skin.directives = {}

skin.directives.text_default_color = skin.controls.color_fore0


local function ParseHeaderText(str, hx, hwidth, tx)
	
	local font = love.graphics.getFont()
	local twidth = love.graphics.getFont():getWidth(str)
	
	if (tx + twidth) - hwidth/2 > hx + hwidth then
		if #str > 1 then
			return ParseHeaderText(str:sub(1, #str - 1), hx, hwidth, tx, twidth)
		else
			return str
		end
	else
		return str
	end
	
end

local function ParseRowText(str, rx, rwidth, tx1, tx2)

	local twidth = love.graphics.getFont():getWidth(str)
	
	if (tx1 + tx2) + twidth > rx + rwidth then
		if #str > 1 then
			return ParseRowText(str:sub(1, #str - 1), rx, rwidth, tx1, tx2)
		else
			return str
		end
	else
		return str
	end
	
end

function skin.PrintText(text, x, y)
	love.graphics.print(text, math.floor(x + 0.5), math.floor(y + 0.5))
end

--[[---------------------------------------------------------
	- func: OutlinedRectangle(x, y, width, height, ovt, ovb, ovl, ovr)
	- desc: creates and outlined rectangle
--]]---------------------------------------------------------
function skin.OutlinedRectangle(x, y, width, height, ovt, ovb, ovl, ovr)

	local ovt = ovt or false
	local ovb = ovb or false
	local ovl = ovl or false
	local ovr = ovr or false
	
	-- top
	if not ovt then
		love.graphics.rectangle("fill", x, y, width, 1)
	end
	
	-- bottom
	if not ovb then
		love.graphics.rectangle("fill", x, y + height - 1, width, 1)
	end
	
	-- left
	if not ovl then
		love.graphics.rectangle("fill", x, y, 1, height)
	end
	
	-- right
	if not ovr then
		love.graphics.rectangle("fill", x + width - 1, y, 1, height)
	end
	
end

--[[---------------------------------------------------------
	- func: DrawFrame(object)
	- desc: draws the frame object
--]]---------------------------------------------------------
function skin.frame(object)
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local hover = object:IsTopChild()
	local name = object:GetName()
	local icon = object:GetIcon()
	local font = skin.controls.smallfont
	
	local body   = skin.controls.color_back0
	local top    = hover and skin.controls.color_active or skin.controls.color_fore0
	local fore   = skin.controls.color_back0
	local border = skin.controls.color_back1
	
	-- frame body
	love.graphics.setColor(body)
	love.graphics.rectangle("fill", x, y, width, height)
	
	-- frame top bar
	love.graphics.setColor(top)
	love.graphics.rectangle("fill", x, y, width, 25)
	
	-- frame name section
	love.graphics.setFont(font)
	
	if icon then
		local iconwidth = icon:getWidth()
		local iconheight = icon:getHeight()
		--icon:setFilter("nearest", "nearest")
		love.graphics.setColor(skin.controls.color_image)
		love.graphics.draw(icon, x + 5, y + 5)
		love.graphics.setColor(fore)
		skin.PrintText(name, x + iconwidth + 10, y + 5)
	else
		love.graphics.setColor(fore)
		skin.PrintText(name, x + 5, y + 5)
	end
	
	-- frame border
	love.graphics.setColor(border)
	skin.OutlinedRectangle(x, y, width, height)
	love.graphics.setColor(border)
	skin.OutlinedRectangle(x, y, width, height)
end

--[[---------------------------------------------------------
	- func: DrawButton(object)
	- desc: draws the button object
--]]---------------------------------------------------------

function skin.button(object)
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local hover = object:GetHover()
	local text = object:GetText()
	local font = skin.controls.smallfont
	local twidth = font:getWidth(object.text)
	local theight = font:getHeight(object.text)
	local down = object:GetDown()
	local checked = object.checked
	local enabled = object:GetEnabled()
	local clickable = object:GetClickable()
	local back, fore, border
	
	love.graphics.setFont(font)
	
	if not enabled or not clickable then
		back   = skin.controls.color_back1
		fore   = skin.controls.color_back2
		border = skin.controls.color_back2
		-- button body
		love.graphics.setColor(back)
		love.graphics.rectangle("fill", x, y, width, height)
		-- button text
		love.graphics.setFont(font)
		love.graphics.setColor(skin.controls.color_back3)
		skin.PrintText(text, x + width/2 - twidth/2, y + height/2 - theight/2)
		-- button border
		love.graphics.setColor(border)
		skin.OutlinedRectangle(x, y, width, height)
		return
	end
	
	if object.toggleable then
		if hover then
			if down then
				back   = skin.controls.color_active
				fore   = skin.controls.color_back0
				border = skin.controls.color_fore2
			else
				back  = skin.controls.color_active
				fore  = skin.controls.color_back0
				border = skin.controls.color_fore1
			end
		else
			if object.toggle then
				back  = skin.controls.color_fore0
				fore  = skin.controls.color_back0
				border = skin.controls.color_fore2
			else
				back  = skin.controls.color_back2
				fore  = skin.controls.color_fore0
				border = skin.controls.color_fore0
			end
		end
		
		-- button body
		love.graphics.setColor(back)
		love.graphics.rectangle("fill", x, y, width, height)
		-- button text
		love.graphics.setColor(fore)
		skin.PrintText(text, x + width/2 - twidth/2, y + height/2 - theight/2)
		-- button border
		love.graphics.setColor(border)
		skin.OutlinedRectangle(x, y, width, height)
		
	else
		if down or checked then
			back  = skin.controls.color_fore0
			fore  = skin.controls.color_back0
			border = skin.controls.color_fore2
		elseif hover then
			back  = skin.controls.color_active
			fore  = skin.controls.color_back0
			border = skin.controls.color_fore1
		else
			back  = skin.controls.color_back2
			fore  = skin.controls.color_fore0
			border = skin.controls.color_fore0
		end
		
		-- button body
		love.graphics.setColor(back)
		love.graphics.rectangle("fill", x, y, width, height)
		-- button text
		if object.image then
			love.graphics.setColor(skin.controls.color_image)
			love.graphics.draw(object.image, x + 5,  y + height/2 - object.image:getHeight()/2)
		end
		
		love.graphics.setColor(fore)
		skin.PrintText(text, x + width/2 - twidth/2, y + height/2 - theight/2)
		-- button border
		love.graphics.setColor(border)
		skin.OutlinedRectangle(x, y, width, height)
	end
	
	love.graphics.setColor(skin.controls.color_back0)
	skin.OutlinedRectangle(x + 1, y + 1, width - 2, height - 2)

end

--[[---------------------------------------------------------
	- func: DrawCloseButton(object)
	- desc: draws the close button object
--]]---------------------------------------------------------
function skin.closebutton(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local parent = object.parent
	local parentwidth = parent:GetWidth()
	local hover = object:GetHover()
	local down = object.down
	local image = skin.images["close.png"]
	local fore
	
	--image:setFilter("nearest", "nearest")
	
	if down then
		fore = skin.controls.color_back2
	elseif hover then
		fore = skin.controls.color_back1
	else
		fore = skin.controls.color_back0
	end
	
	love.graphics.setColor(fore)
	love.graphics.draw(image, x, y)
end

--[[---------------------------------------------------------
	- func: DrawImage(object)
	- desc: draws the image object
--]]---------------------------------------------------------
function skin.image(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local orientation = object:GetOrientation()
	local scalex = object:GetScaleX()
	local scaley = object:GetScaleY()
	local offsetx = object:GetOffsetX()
	local offsety = object:GetOffsetY()
	local shearx = object:GetShearX()
	local sheary = object:GetShearY()
	local image = object.image
	local imagecolor = object.imagecolor or skin.controls.color_image
	local stretch = object.stretch
	
	if stretch then
		scalex, scaley = object:GetWidth() / image:getWidth(), object:GetHeight() / image:getHeight()
	end
	
	love.graphics.setColor(imagecolor)
	love.graphics.draw(image, x, y, orientation, scalex, scaley, offsetx, offsety, shearx, sheary)
	
end

--[[---------------------------------------------------------
	- func: DrawImageButton(object)
	- desc: draws the image button object
--]]---------------------------------------------------------
function skin.imagebutton(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local text = object:GetText()
	local hover = object:GetHover()
	local image = object:GetImage()
	local imagecolor = object.imagecolor or skin.controls.color_image
	local down = object.down
	local font = skin.controls.smallfont
	local twidth = font:getWidth(object.text)
	local theight = font:getHeight(object.text)
	local checked = object.checked
	
	local fore1, fore2 = skin.controls.color_back0

	if down then
		if image then
			love.graphics.setColor(imagecolor)
			love.graphics.draw(image, x + 1, y + 1)
		end
		love.graphics.setFont(font)
		love.graphics.setColor(skin.controls.color_back2)
		skin.PrintText(text, x + width/2 - twidth/2 + 1, y + height - theight - 5 + 1)
		love.graphics.setColor(skin.controls.color_fore3)
		skin.PrintText(text, x + width/2 - twidth/2 + 1, y + height - theight - 6 + 1)
	elseif hover then
		if image then
			love.graphics.setColor(imagecolor)
			love.graphics.draw(image, x, y)
		end
		love.graphics.setFont(font)
		love.graphics.setColor(skin.controls.color_back1)
		skin.PrintText(text, x + width/2 - twidth/2, y + height - theight - 5)
		love.graphics.setColor(skin.controls.color_fore2)
		skin.PrintText(text, x + width/2 - twidth/2, y + height - theight - 6)
	else
		if image then
			love.graphics.setColor(imagecolor)
			love.graphics.draw(image, x, y)
		end
		love.graphics.setFont(font)
		love.graphics.setColor(skin.controls.color_back0)
		skin.PrintText(text, x + width/2 - twidth/2, y + height - theight - 5)
		love.graphics.setColor(skin.controls.color_fore0)
		skin.PrintText(text, x + width/2 - twidth/2, y + height - theight - 6)
	end
	if checked == true then
		love.graphics.setColor(skin.controls.color_back2)
		love.graphics.setLineWidth(3)
		love.graphics.setLineStyle("smooth")
		love.graphics.rectangle("line", x+1, y+1, width-2, height-2)
	end

end

--[[---------------------------------------------------------
	- func: DrawProgressBar(object)
	- desc: draws the progress bar object
--]]---------------------------------------------------------
function skin.progressbar(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local value = object:GetValue()
	local max = object:GetMax()
	local text = object:GetText()
	local barwidth = object:GetBarWidth()
	local font = skin.controls.smallfont
	local twidth = font:getWidth(text)
	local theight = font:getHeight("m")
		
	-- progress bar body
	love.graphics.setColor(skin.controls.color_back0)
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(skin.controls.color_back2)
	love.graphics.rectangle("fill", x, y, barwidth, height)
	love.graphics.setFont(font)
	love.graphics.setColor(skin.controls.color_fore0)
	skin.PrintText(text, x + width/2 - twidth/2, y + height/2 - theight/2)
	
	-- progress bar border
	love.graphics.setColor(skin.controls.color_fore0)
	skin.OutlinedRectangle(x, y, width, height)
	
	object:SetText(value .. "/" ..max)
	
end

--[[---------------------------------------------------------
	- func: DrawScrollArea(object)
	- desc: draws the scroll area object
--]]---------------------------------------------------------
function skin.scrollarea(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local bartype = object:GetBarType()
	
	love.graphics.setColor(skin.controls.color_back0)
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(skin.controls.color_back1)
	
	if bartype == "vertical" then
		skin.OutlinedRectangle(x, y, width, height, true, true)
	elseif bartype == "horizontal" then
		skin.OutlinedRectangle(x, y, width, height, false, false, true, true)
	end
	
end

--[[---------------------------------------------------------
	- func: DrawScrollBar(object)
	- desc: draws the scroll bar object
--]]---------------------------------------------------------
function skin.scrollbar(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local dragging = object:IsDragging()
	local hover = object:GetHover()
	local bartype = object:GetBarType()
	local back, border
	
	if dragging then
		back  = skin.controls.color_fore0
		border = skin.controls.color_fore2
	elseif hover then
		back  = skin.controls.color_active
		border = skin.controls.color_fore1
	else
		back  = skin.controls.color_back2
		border = skin.controls.color_fore0
	end
	
	love.graphics.setColor(back)
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(border)
	skin.OutlinedRectangle(x, y, width, height)

	love.graphics.setColor(skin.controls.color_back0)
	skin.OutlinedRectangle(x + 1, y + 1, width - 2, height - 2)
end

--[[---------------------------------------------------------
	- func: DrawScrollBody(object)
	- desc: draws the scroll body object
--]]---------------------------------------------------------
function skin.scrollbody(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local bodycolor = skin.controls.scrollbody_body_color
	
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(skin.controls.color_back2)
	skin.OutlinedRectangle(x, y, width, height)

end


--[[---------------------------------------------------------
	- func: DrawScrollButton(object)
	- desc: draws the scroll button object
--]]---------------------------------------------------------
function skin.scrollbutton(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local hover = object:GetHover()
	local scrolltype = object:GetScrollType()
	local down = object.down
	local back, fore, border
	
	if down then
		back  = skin.controls.color_fore0
		fore  = skin.controls.color_back0
		border = skin.controls.color_fore2
	elseif hover then
		back  = skin.controls.color_active
		fore  = skin.controls.color_back0
		border = skin.controls.color_fore1
	else
		back  = skin.controls.color_back2
		fore  = skin.controls.color_fore0
		border = skin.controls.color_fore0
	end
	
	-- button back
	love.graphics.setColor(back)
	love.graphics.rectangle("fill", x, y, width, height)
	-- button border
	love.graphics.setColor(border)
	skin.OutlinedRectangle(x, y, width, height)
	
	local image
	if scrolltype == "up" then
		image = skin.images["arrow-up.png"]
	elseif scrolltype == "down" then
		image = skin.images["arrow-down.png"]
	elseif scrolltype == "left" then
		image = skin.images["arrow-left.png"]
	elseif scrolltype == "right" then
		image = skin.images["arrow-right.png"]
	end
	
	local imagewidth = image:getWidth()
	local imageheight = image:getHeight()
	--image:setFilter("nearest", "nearest")
	love.graphics.setColor(fore)

	love.graphics.draw(image, x + width/2 - imagewidth/2, y + height/2 - imageheight/2)

	love.graphics.setColor(skin.controls.color_back0)
	skin.OutlinedRectangle(x + 1, y + 1, width - 2, height - 2)
end

--[[---------------------------------------------------------
	- func: skin.DrawSlider(object)
	- desc: draws the slider object
--]]---------------------------------------------------------
function skin.slider(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local slidtype = object:GetSlideType()
	local body = skin.controls.color_back1
	local border = skin.controls.color_back3
	
	if slidtype == "horizontal" then
		love.graphics.setColor(body)
		love.graphics.rectangle("fill", x, y + height/2 - 3, width, 6)
		love.graphics.setColor(border)
		love.graphics.rectangle("fill", x + 5, y + height/2 - 1, width - 10, 2)
	elseif slidtype == "vertical" then
		love.graphics.setColor(body)
		love.graphics.rectangle("fill", x + width/2 - 3, y, 6, height)
		love.graphics.setColor(border)
		love.graphics.rectangle("fill", x + width/2 - 1, y + 5, 2, height - 10)
	end
	
end

--[[---------------------------------------------------------
	- func: skin.DrawSliderButton(object)
	- desc: draws the slider button object
--]]---------------------------------------------------------
function skin.sliderbutton(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local hover = object:GetHover()
	local down = object.down
	local parent = object:GetParent()
	local enabled = parent:GetEnabled()
	
	if not enabled then
		-- button body
		love.graphics.setColor(skin.controls.color_back1)
		love.graphics.rectangle("fill", x, y, width, height)
		-- button border
		love.graphics.setColor(skin.controls.color_back2)
		skin.OutlinedRectangle(x, y, width, height)
		return
	end
	
	
	local image = skin.images["slider.png"]
	local imagewidth = image:getWidth()
	local imageheight = image:getHeight()
	--image:setFilter("nearest", "nearest")
	
	local fore
	if down then
		fore  = skin.controls.color_fore0
	elseif hover then
		fore  = skin.controls.color_active
	else
		fore  = skin.controls.color_back3
	end
	
	love.graphics.setColor(fore)
	love.graphics.draw(image, x + (width - imagewidth) / 2, y + (height - imageheight) / 2)
end

--[[---------------------------------------------------------
	- func: DrawPanel(object)
	- desc: draws the panel object
--]]---------------------------------------------------------
function skin.panel(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y, width, height)
	
	--love.graphics.setColor(skin.controls.color_back1)
	--skin.OutlinedRectangle(x + 1, y + 1, width - 2, height - 2)
	
	love.graphics.setColor(skin.controls.color_back2)
	skin.OutlinedRectangle(x, y, width, height)
	
end

--[[---------------------------------------------------------
	- func: DrawList(object)
	- desc: draws the list object
--]]---------------------------------------------------------
function skin.list(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local bodycolor = skin.controls.list_body_color
	
	love.graphics.setColor(skin.controls.color_back0)
	love.graphics.rectangle("fill", x, y, width, height)
	--love.graphics.setColor(skin.controls.color_back3)
	--skin.OutlinedRectangle(x, y, width, height)
		
end

--[[---------------------------------------------------------
	- func: DrawList(object)
	- desc: used to draw over the object and its children
--]]---------------------------------------------------------
function skin.list_over(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back3)
	skin.OutlinedRectangle(x, y, width, height)
	
end

--[[---------------------------------------------------------
	- func: DrawTabPanel(object)
	- desc: draws the tab panel object
--]]---------------------------------------------------------
function skin.tabpanel(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local buttonheight = object:GetHeightOfButtons()
	
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y + buttonheight, width, height - buttonheight)
	love.graphics.setColor(skin.controls.color_back2)
	skin.OutlinedRectangle(x, y + buttonheight - 1, width, height - buttonheight + 2)
	
	object:SetScrollButtonSize(15, buttonheight)

end

--[[---------------------------------------------------------
	- func: DrawOverTabPanel(object)
	- desc: draws over the tab panel object
--]]---------------------------------------------------------
function skin.tabpanel_over(object)

end

--[[---------------------------------------------------------
	- func: DrawTabButton(object)
	- desc: draws the tab button object
--]]---------------------------------------------------------
function skin.tabbutton(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local hover = object:GetHover()
	local text = object:GetText()
	local image = object:GetImage()
	local tabnumber = object:GetTabNumber()
	local parent = object:GetParent()
	local ptabnumber = parent:GetTabNumber()
	local font = skin.controls.smallfont
	local twidth = font:getWidth(object.text)
	local theight = font:getHeight(object.text)
	local imagewidth = 0
	local imageheight = 0
	local texthovercolor = skin.controls.button_text_hover_color
	local textnohovercolor = skin.controls.button_text_nohover_color
	
	if image then
		--image:setFilter("nearest", "nearest")
		imagewidth = image:getWidth()
		imageheight = image:getHeight()
		object.width = imagewidth + 15 + twidth
		if imageheight > theight then
			parent:SetTabHeight(imageheight + 10)
			object.height = imageheight + 10
		else
			object.height = parent.tabheight
		end
	else
		object.width = 10 + twidth
		object.height = parent.tabheight
	end
	
	local width  = object:GetWidth()
	local height = object:GetHeight()
	
	local back, fore, border
	
	if tabnumber ~= ptabnumber then
		back   = skin.controls.color_back1
		border = skin.controls.color_back2
		fore   = skin.controls.color_fore0
	else
		back   = skin.controls.color_active
		border = skin.controls.color_back2
		fore   = skin.controls.color_back0
	end

	-- button body
	love.graphics.setColor(back)
	love.graphics.rectangle("fill", x, y, width, height)
	-- button border
	love.graphics.setColor(border)
	skin.OutlinedRectangle(x, y, width, height)
	
	love.graphics.setFont(font)
	if image then
		-- button image
		love.graphics.setColor(skin.controls.color_image)
		love.graphics.draw(image, x + 5, y + height/2 - imageheight/2)
		-- button text
		love.graphics.setColor(fore)
		skin.PrintText(text, x + imagewidth + 10, y + height/2 - theight/2)
	else
		-- button text
		love.graphics.setColor(fore)
		skin.PrintText(text, x + 5, y + height/2 - theight/2)
	end

end

--[[---------------------------------------------------------
	- func: DrawMultiChoice(object)
	- desc: draws the multi choice object
--]]---------------------------------------------------------
function skin.multichoice(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local text = object:GetText()
	local choice = object:GetChoice()
	local image = skin.images["multichoice-arrow.png"]
	local font = skin.controls.smallfont
	local theight = font:getHeight("a")
	local hover = object:GetHover()
	--local down = object:GetDown()
	
	--image:setFilter("nearest", "nearest")
	
	local back, fore, border
	if hover then
		back  = skin.controls.color_active
		fore  = skin.controls.color_back0
		border = skin.controls.color_fore1
	else
		back  = skin.controls.color_back2
		fore  = skin.controls.color_fore0
		border = skin.controls.color_fore0
	end
			
	love.graphics.setColor(back)
	love.graphics.rectangle("fill", x, y, width, height)
	
	love.graphics.setColor(fore)
	love.graphics.setFont(font)
	
	if choice == "" then
		skin.PrintText(text, x + 5, y + height/2 - theight/2)
	else
		skin.PrintText(choice, x + 5, y + height/2 - theight/2)
	end
	
	love.graphics.draw(image, x + width - 20, y + 5)
	
	love.graphics.setColor(border)
	skin.OutlinedRectangle(x, y, width, height)

	love.graphics.setColor(skin.controls.color_back0)
	skin.OutlinedRectangle(x + 1, y + 1, width - 2, height - 2)
end

--[[---------------------------------------------------------
	- func: DrawMultiChoiceList(object)
	- desc: draws the multi choice list object
--]]---------------------------------------------------------
function skin.multichoicelist(object)
	
	local skin = object:GetSkin()
	local x = object:GetX() + 2
	local y = object:GetY()
	local width = object:GetWidth() - 4
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y, width, height)
	
end

--[[---------------------------------------------------------
	- func: DrawOverMultiChoiceList(object)
	- desc: draws over the multi choice list object
--]]---------------------------------------------------------
function skin.multichoicelist_over(object)

	local skin = object:GetSkin()
	local x = object:GetX() + 2
	local y = object:GetY() - 1
	local width = object:GetWidth() - 4
	local height = object:GetHeight() + 1
	
	love.graphics.setColor(skin.controls.color_fore0)
	skin.OutlinedRectangle(x, y, width, height)
	
end

--[[---------------------------------------------------------
	- func: DrawMultiChoiceRow(object)
	- desc: draws the multi choice row object
--]]---------------------------------------------------------
function skin.multichoicerow(object)
	
	local skin = object:GetSkin()
	local x = object:GetX() + 2
	local y = object:GetY()
	local width = object:GetWidth() - 4
	local height = object:GetHeight()
	local text = object:GetText()
	local font = skin.controls.smallfont
	local back, fore
	
	love.graphics.setFont(font)
	
	if object.hover then
		back = skin.controls.color_active
		fore = skin.controls.color_back0
	else
		back = skin.controls.color_back2
		fore = skin.controls.color_fore0
	end
	
	love.graphics.setColor(back)
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(fore)
	skin.PrintText(text, x + 5, y + 5)
	
end

--[[---------------------------------------------------------
	- func: DrawToolTip(object)
	- desc: draws the tool tip object
--]]---------------------------------------------------------
function skin.tooltip(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(skin.controls.color_back2)
	skin.OutlinedRectangle(x, y, width, height)
	
end

--[[---------------------------------------------------------
	- func: DrawText(object)
	- desc: draws the text object
--]]---------------------------------------------------------
function skin.text(object)
	local textdata = object.formattedtext
	local x = object.x
	local y = object.y
	local shadow = object.shadow
	local shadowxoffset = object.shadowxoffset
	local shadowyoffset = object.shadowyoffset
	local shadowcolor = object.shadowcolor
	local inlist, list = object:IsInList()
	local printfunc = function(text, x, y)
		love.graphics.print(text, math.floor(x + 0.5), math.floor(y + 0.5))
	end
	
	for k, v in ipairs(textdata) do
		local textx = v.x
		local texty = v.y
		local text = v.text
		local color = v.color
		local font = v.font
		local link = v.link
		local theight = font:getHeight("a")
		if inlist then
			local listy = list.y
			local listhieght = list.height
			if (y + texty) <= (listy + listhieght) and y + ((texty + theight)) >= listy then
				love.graphics.setFont(font)
				if shadow then
					love.graphics.setColor(unpack(shadowcolor))
					printfunc(text, x + textx + shadowxoffset, y + texty + shadowyoffset)
				end
				if link then
					local linkcolor = v.linkcolor
					local linkhovercolor = v.linkhovercolor
					local hover = v.hover
					if hover then
						love.graphics.setColor(linkhovercolor)
					else
						love.graphics.setColor(linkcolor)
					end
				else
					love.graphics.setColor(unpack(color))
				end
				printfunc(text, x + textx, y + texty)
			end
		else
			love.graphics.setFont(font)
			if shadow then
				love.graphics.setColor(unpack(shadowcolor))
				printfunc(text, x + textx + shadowxoffset, y + texty + shadowyoffset)
			end
			if link then
				local linkcolor = v.linkcolor
				local linkhovercolor = v.linkhovercolor
				local hover = v.hover
				if hover then
					love.graphics.setColor(linkhovercolor)
				else
					love.graphics.setColor(linkcolor)
				end
			else
				love.graphics.setColor(unpack(color))
			end
			printfunc(text, x + textx, y + texty)
		end
	end
end

--[[---------------------------------------------------------
	- func: DrawTextInput(object)
	- desc: draws the text input object
--]]---------------------------------------------------------
function skin.textinput(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local font = object:GetFont()
	local focus = object:GetFocus()
	local showindicator = object:GetIndicatorVisibility()
	local alltextselected = object:IsAllTextSelected()
	local textx = object:GetTextX()
	local texty = object:GetTextY()
	local text = object:GetText()
	local multiline = object:GetMultiLine()
	local lines = object:GetLines()
	local placeholder = object:GetPlaceholderText()
	local offsetx = object:GetOffsetX()
	local offsety = object:GetOffsetY()
	local indicatorx = object:GetIndicatorX()
	local indicatory = object:GetIndicatorY()
	local vbar = object:HasVerticalScrollBar()
	local hbar = object:HasHorizontalScrollBar()
	local linenumbers = object:GetLineNumbersEnabled()
	local itemwidth = object:GetItemWidth()
	local masked = object:GetMasked()
	local theight = font:getHeight("a")
	
	love.graphics.setColor(skin.controls.color_back0)
	love.graphics.rectangle("fill", x, y, width, height)
	
	if alltextselected then
		local bary = 0
		if multiline then
			for i=1, #lines do
				local str = lines[i]
				if masked then
					str = str:gsub(".", "*")
				end
				local twidth = font:getWidth(str)
				if twidth == 0 then
					twidth = 5
				end
				love.graphics.setColor(skin.controls.color_active)
				love.graphics.rectangle("fill", textx, texty + bary, twidth, theight)
				bary = bary + theight
			end
		else
			local twidth = 0
			if masked then
				local maskchar = object:GetMaskChar()
				twidth = font:getWidth(text:gsub(".", maskchar))
			else
				twidth = font:getWidth(text)
			end
			love.graphics.setColor(skin.controls.color_active)
			love.graphics.rectangle("fill", textx, texty, twidth, theight)
		end
	end
	
	if showindicator and focus then
		love.graphics.setColor(skin.controls.color_fore0)
		love.graphics.rectangle("fill", indicatorx, indicatory, 1, theight)
	end
	
	if not multiline then
		object:SetTextOffsetY(height/2 - theight/2)
		if offsetx ~= 0 then
			object:SetTextOffsetX(0)
		else
			object:SetTextOffsetX(5)
		end
	else
		if vbar then
			if offsety ~= 0 then
				if hbar then
					object:SetTextOffsetY(5)
				else
					object:SetTextOffsetY(-5)
				end
			else
				object:SetTextOffsetY(5)
			end
		else
			object:SetTextOffsetY(5)
		end
		
		if hbar then
			if offsety ~= 0 then
				if linenumbers then
					local panel = object:GetLineNumbersPanel()
					if vbar then
						object:SetTextOffsetX(5)
					else
						object:SetTextOffsetX(-5)
					end
				else
					if vbar then
						object:SetTextOffsetX(5)
					else
						object:SetTextOffsetX(-5)
					end
				end
			else
				object:SetTextOffsetX(5)
			end
		else
			object:SetTextOffsetX(5)
		end
		
	end
	
	textx = object:GetTextX()
	texty = object:GetTextY()
	
	love.graphics.setFont(font)
	
	if alltextselected then
		love.graphics.setColor(skin.controls.color_back0)
	elseif #lines == 1 and lines[1] == "" then
		love.graphics.setColor(skin.controls.color_back2)
	else
		love.graphics.setColor(skin.controls.color_fore0)
	end
	
	local str = ""
	if multiline then
		for i=1, #lines do
			str = lines[i]
			if masked then
				local maskchar = object:GetMaskChar()
				str = str:gsub(".", maskchar)
			end
			skin.PrintText(#str > 0 and str or (#lines == 1 and placeholder or ""), textx, texty + theight * i - theight)
		end
	else
		str = lines[1]
		if masked then
			local maskchar = object:GetMaskChar()
			str = str:gsub(".", maskchar)
		end
		skin.PrintText(#str > 0 and str or placeholder, textx, texty)
	end
	
	--love.graphics.setColor(skin.controls.color_back3)
	--skin.OutlinedRectangle(x + 1, y + 1, width - 2, height - 2)
	
end

--[[---------------------------------------------------------
	- func: DrawOverTextInput(object)
	- desc: draws over the text input object
--]]---------------------------------------------------------
function skin.textinput_over(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back3)
	skin.OutlinedRectangle(x, y, width, height)
	
end

--[[---------------------------------------------------------
	- func: skin.DrawCheckBox(object)
	- desc: draws the check box object
--]]---------------------------------------------------------
function skin.checkbox(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetBoxWidth()
	local height = object:GetBoxHeight()
	local checked = object:GetChecked()
	local hover = object:GetHover()
	local buttonimage
	if checked then
		buttonimage = skin.images["check-on.png"]
	else
		buttonimage = skin.images["check-off.png"]
	end
	
	if hover ~= checked then
		love.graphics.setColor(skin.controls.color_active)
	else
		love.graphics.setColor(skin.controls.color_fore0)
	end
	local iwidth  = buttonimage:getWidth()
	local iheight = buttonimage:getHeight()
	--buttonimage:setFilter("nearest", "nearest")
	love.graphics.draw(buttonimage, x  + (width - iwidth) / 2, y  + (height - iheight) / 2)
	
end

--[[---------------------------------------------------------
	- func: skin.DrawCheckBox(object)
	- desc: draws the radio button object
--]]---------------------------------------------------------
function skin.radiobutton(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetBoxWidth()
	local height = object:GetBoxHeight()
	local checked = object:GetChecked()
	local hover = object:GetHover()
	local buttonimage
	if checked then
		buttonimage = skin.images["radio-on.png"]
	else
		buttonimage = skin.images["radio-off.png"]
	end
	
	if hover ~= checked then
		love.graphics.setColor(skin.controls.color_active)
	else
		love.graphics.setColor(skin.controls.color_fore0)
	end
	local iwidth  = buttonimage:getWidth()
	local iheight = buttonimage:getHeight()
	--buttonimage:setFilter("nearest", "nearest")
	love.graphics.draw(buttonimage, x  + (width - iwidth) / 2, y  + (height - iheight) / 2)
	
end

--[[---------------------------------------------------------
	- func: skin.DrawCollapsibleCategory(object)
	- desc: draws the collapsible category object
--]]---------------------------------------------------------
function skin.collapsiblecategory(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local text = object:GetText()
	local open = object:GetOpen()
	local font = skin.controls.smallfont
	
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y, width, height)
	
	love.graphics.setColor(skin.controls.color_active)
	love.graphics.rectangle("fill", x, y, width, 25)
	
	love.graphics.setColor(skin.controls.color_back3)
	skin.OutlinedRectangle(x, y, width, height)
	
	love.graphics.setColor(skin.controls.color_back0)
	if open then
		local icon = skin.images["collapse.png"]
		--icon:setFilter("nearest", "nearest")
		love.graphics.draw(icon, x + width - 21, y + 5)
		love.graphics.setColor(skin.controls.color_back0)
		skin.OutlinedRectangle(x + 1, y + 1, width - 2, 24)
	else
		local icon = skin.images["expand.png"]
		--icon:setFilter("nearest", "nearest")
		love.graphics.draw(icon, x + width - 21, y + 5)
		love.graphics.setColor(skin.controls.color_back0)
		skin.OutlinedRectangle(x + 1, y + 1, width - 2, 23)
	end
	
	love.graphics.setFont(font)
	love.graphics.setColor(skin.controls.color_back0)
	skin.PrintText(text, x + 5, y + 5)
	
end

--[[---------------------------------------------------------
	- func: skin.DrawColumnList(object)
	- desc: draws the column list object
--]]---------------------------------------------------------
function skin.columnlist(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_active)
	love.graphics.rectangle("fill", x, y, width, height)
end

--[[---------------------------------------------------------
	- func: skin.DrawColumnListHeader(object)
	- desc: draws the column list header object
--]]---------------------------------------------------------
function skin.columnlistheader(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local hover = object:GetHover()
	local down = object.down
	local font = skin.controls.smallfont
	local theight = font:getHeight(object.name)
	
	local name = ParseHeaderText(object:GetName(), x, width, x + width/2)
	local twidth = font:getWidth(name)
	
	local back, fore, border
	
	if down then
		back  = skin.controls.color_fore0
		fore  = skin.controls.color_back0
		border = skin.controls.color_fore2
	elseif hover then
		back  = skin.controls.color_active
		fore  = skin.controls.color_back0
		border = skin.controls.color_fore1
	else
		back  = skin.controls.color_back2
		fore  = skin.controls.color_fore0
		border = skin.controls.color_fore0
	end
	
	-- header body
	love.graphics.setColor(back)
	love.graphics.rectangle("fill", x, y, width, height)
	-- header name
	love.graphics.setFont(font)
	love.graphics.setColor(fore)
	skin.PrintText(name, x + width/2 - twidth/2, y + height/2 - theight/2)
	-- header border
	love.graphics.setColor(border)
	skin.OutlinedRectangle(x, y, width+1, height)
	
end

--[[---------------------------------------------------------
	- func: skin.DrawColumnListArea(object)
	- desc: draws the column list area object
--]]---------------------------------------------------------
function skin.columnlistarea(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back0)
	love.graphics.rectangle("fill", x, y, width, height)
	
	local cheight = 0
	local columns = object:GetParent():GetChildren()
	if #columns > 0 then
		cheight = columns[1]:GetHeight()
	end
	
	-- header body
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y, width, cheight)
	
	love.graphics.setColor(skin.controls.color_back2)
	skin.OutlinedRectangle(x, y, width, cheight)
	
end

--[[---------------------------------------------------------
	- func: skin.DrawOverColumnListArea(object)
	- desc: draws over the column list area object
--]]---------------------------------------------------------
function skin.columnlistarea_over(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back3)
	skin.OutlinedRectangle(x, y, width, height)
end

--[[---------------------------------------------------------
	- func: skin.DrawColumnListRow(object)
	- desc: draws the column list row object
--]]---------------------------------------------------------
function skin.columnlistrow(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local colorindex = object:GetColorIndex()
	local font = object:GetFont()
	local columndata = object:GetColumnData()
	local textx = object:GetTextX()
	local texty = object:GetTextY()
	local parent = object:GetParent()
	local theight = font:getHeight("a")
	local hover = object:GetHover()
	local selected = object:GetSelected()
	
	object:SetTextPos(5, height/2 - theight/2)
	
	if selected then
		love.graphics.setColor(skin.controls.color_back3)
	elseif hover then
		love.graphics.setColor(skin.controls.color_active)
	elseif colorindex == 1 then
		love.graphics.setColor(skin.controls.color_back1)
	else
		love.graphics.setColor(skin.controls.color_back2)
	end
	
	love.graphics.rectangle("fill", x, y, width, height)
	
	love.graphics.setFont(font)
	if selected then
		love.graphics.setColor(skin.controls.color_fore3)
	elseif hover then
		love.graphics.setColor(skin.controls.color_back0)
	else
		love.graphics.setColor(skin.controls.color_fore0)
	end
	for k, v in ipairs(columndata) do
		local rwidth = parent.parent:GetColumnWidth(k)
		if rwidth then
			local text = ParseRowText(v, x, rwidth, x, textx)
			skin.PrintText(text, x + textx, y + texty)
			x = x + parent.parent.children[k]:GetWidth()
		else
			break
		end
	end
	
end

--[[---------------------------------------------------------
	- func: skin.DrawModalBackground(object)
	- desc: draws the modal background object
--]]---------------------------------------------------------
function skin.modalbackground(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back2)
	love.graphics.rectangle("fill", x, y, width, height)
	
end

--[[---------------------------------------------------------
	- func: skin.DrawLineNumbersPanel(object)
	- desc: draws the line numbers panel object
--]]---------------------------------------------------------
function skin.linenumberspanel(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local offsety = object:GetOffsetY()
	local parent = object:GetParent()
	local lines = parent:GetLines()
	local font = parent:GetFont()
	local theight = font:getHeight("8")

	
	object:SetWidth(10 + font:getWidth(#lines))
	love.graphics.setFont(font)
	
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y, width, height)
	
	love.graphics.setColor(skin.controls.color_back0)
	skin.OutlinedRectangle(x, y, width, height, true, true, true, false)
	
	local startline = math.ceil(offsety / theight)
	if startline < 1 then
		startline = 1
	end
	local endline = math.ceil(startline + (height / theight)) + 1
	if endline > #lines then
		endline = #lines
	end
	
	for i=startline, endline do
		love.graphics.setColor(skin.controls.color_back3)
		skin.PrintText(i, x + 5, (y + (theight * (i - 1))) - offsety)
	end
	
end

--[[---------------------------------------------------------
	- func: skin.DrawNumberBox(object)
	- desc: draws the numberbox object
--]]---------------------------------------------------------
function skin.numberbox(object)

end

--[[---------------------------------------------------------
	- func: skin.DrawGrid(object)
	- desc: draws the grid object
--]]---------------------------------------------------------
function skin.grid(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	--love.graphics.setColor(colors.hl4)
	--love.graphics.rectangle("fill", x-1, y-1, width+2, height+2)
	
	local cx = x
	local cy = y
	local cw = object.cellwidth + (object.cellpadding * 2)
	local ch = object.cellheight + (object.cellpadding * 2)
	
	for i=1, object.rows do
		for n=1, object.columns do
			local ovt = false
			local ovl = false
			if i > 1 then
				ovt = true
			end
			if n > 1 then	
				ovl = true
			end
			love.graphics.setColor(skin.controls.color_back1)
			love.graphics.rectangle("fill", cx, cy, cw, ch)
			love.graphics.setColor(skin.controls.color_back3)
			skin.OutlinedRectangle(cx, cy, cw, ch, ovt, false, ovl, false)
			cx = cx + cw
		end
		cx = x
		cy = cy + ch
	end

end

--[[---------------------------------------------------------
	- func: skin.DrawForm(object)
	- desc: draws the form object
--]]---------------------------------------------------------
function skin.form(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local topmargin = object.topmargin
	local name = object.name
	local font = skin.controls.smallfont
	local textcolor = skin.controls.form_text_color
	local twidth = font:getWidth(name)
	
	love.graphics.setFont(font)
	love.graphics.setColor(skin.controls.color_fore0)
	skin.PrintText(name, x + 7, y)
	
	love.graphics.setColor(skin.controls.color_back3)
	love.graphics.rectangle("fill", x, y + 7, 5, 1)
	love.graphics.rectangle("fill", x + twidth + 9, y + 7, width - (twidth + 9), 1)
	love.graphics.rectangle("fill", x, y + height, width, 1)
	love.graphics.rectangle("fill", x, y + 7, 1, height - 7)
	love.graphics.rectangle("fill", x + width - 1, y + 7, 1, height - 7)
	
end

--[[---------------------------------------------------------
	- func: skin.DrawMenu(object)
	- desc: draws the menu object
--]]---------------------------------------------------------
function skin.menu(object)
	
	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y, width, height)
	
	love.graphics.setColor(skin.controls.color_back2)
	skin.OutlinedRectangle(x, y, width, height)
	
end

--[[---------------------------------------------------------
	- func: skin.DrawMenuOption(object)
	- desc: draws the menuoption object
--]]---------------------------------------------------------
function skin.menuoption(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	local hover = object:GetHover()
	local text = object:GetText()
	local icon = object:GetIcon()
	local option_type = object.option_type
	local font = skin.controls.smallfont
	local twidth = font:getWidth(text)
	
	
	if option_type == "divider" then
		love.graphics.setColor(skin.controls.color_fore0)
		love.graphics.rectangle("fill", x + 4, y + 2, width - 8, 1)
		object.contentheight = 10
	else
		love.graphics.setFont(font)
		if hover then
			love.graphics.setColor(skin.controls.color_active)
			love.graphics.rectangle("fill", x + 2, y + 2, width - 4, height - 4)
			love.graphics.setColor(skin.controls.color_back0)
			skin.PrintText(text, x + 26, y + 5)
		else
			love.graphics.setColor(skin.controls.color_fore0)
			skin.PrintText(text, x + 26, y + 5)
		end
		if icon then
			love.graphics.setColor(skin.controls.color_image)
			love.graphics.draw(icon, x + 5, y + 5)
		end
		object.contentwidth = twidth + 31
		object.contentheight = 25
	end
	
end

function skin.tree(object)

	local skin = object:GetSkin()
	local x = object:GetX()
	local y = object:GetY()
	local width = object:GetWidth()
	local height = object:GetHeight()
	
	love.graphics.setColor(skin.controls.color_back1)
	love.graphics.rectangle("fill", x, y, width, height)
	
end

function skin.treenode(object)

	local icon = object.icon
	local buttonimage = skin.images["tree-node-button-open.png"]
	local width = 0
	local x = object.x
	local leftpadding = 15 * object.level
	
	if object.level > 0 then
		leftpadding = leftpadding + buttonimage:getWidth() + 5
	else
		leftpadding = buttonimage:getWidth() + 5
	end
	
	local iconwidth = 24
	if icon then
		iconwidth = icon:getWidth()
	end
	
	local twidth = loveframes.basicfont:getWidth(object.text)
	local theight = loveframes.basicfont:getHeight(object.text)
	
	if object.tree.selectednode == object then
		love.graphics.setColor(skin.controls.color_active)
		love.graphics.rectangle("fill", x + leftpadding + 2 + iconwidth, object.y + 2, twidth, theight)
	end

	width = width + iconwidth + loveframes.basicfont:getWidth(object.text) + leftpadding
	--love.graphics.setColor(skin.controls.color_image)
	--love.graphics.draw(icon, x + leftpadding, object.y)
	love.graphics.setFont(loveframes.basicfont)
	love.graphics.setColor(skin.controls.color_fore0)
	skin.PrintText(object.text, x + leftpadding + 2 + iconwidth, object.y + 2)
	
	object:SetWidth(width + 5)
	
end

function skin.treenodebutton(object)
	
	local leftpadding = 15 * object.parent.level
	local image
	
	if object.parent.open then
		image = skin.images["tree-node-button-close.png"]
	else
		image = skin.images["tree-node-button-open.png"]
	end
	
	--image:setFilter("nearest", "nearest")
	
	love.graphics.setColor(skin.controls.color_image)
	love.graphics.draw(image, object.x, object.y)
	
	object:SetPos(2 + leftpadding, 3)
	object:SetSize(image:getWidth(), image:getHeight())
	
end

-- register the main skin
loveframes.RegisterSkin(skin)

-- alternate active colors
local subskin = {}
subskin.author    = skin.author
subskin.version   = skin.version
subskin.base      = skin.name
subskin.directory = skin.dir --loveframes.config["DIRECTORY"] .. "/skins/" ..skin.name
subskin.controls = {}

local colors = {
	red     = color"b36262",
	orange  = color"b38a62",
	green   = color"7db362",
	cyan    = color"62b3a5",
	blue    = color"6298b3",
	magenta = color"8a62b3",
	pink    = color"cc70b5"
}

for k, v in pairs(colors) do
	subskin.name = skin.name .. " " .. k
	subskin.controls.color_active = v
	loveframes.RegisterSkin(subskin)
end

-- Dark variant with alternate active colors
subskin.controls.color_back0  = color"101010"
subskin.controls.color_back1  = color"202020"
subskin.controls.color_back2  = color"373737"
subskin.controls.color_back3  = color"505050"
subskin.controls.color_fore0  = color"a0a0a0"
subskin.controls.color_fore1  = color"c0c0c0"
subskin.controls.color_fore2  = color"e0e0e0"
subskin.controls.color_fore3  = color"f0f0f0"

for k, v in pairs(colors) do
	subskin.name = "Dark " .. k
	subskin.controls.color_active = v
	loveframes.RegisterSkin(subskin)
end

--return skin

---------- module end ----------
end
