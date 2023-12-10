--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

local path = ...

local loveframes = {}

-- special require for loveframes specific modules
loveframes.require = function(name)
	local ret = require(name)
	if type(ret) == 'function' then return ret(loveframes) end
	return ret
end

-- loveframes specific modules
loveframes.require(path .. ".libraries.utils")
loveframes.require(path .. ".libraries.templates")
loveframes.require(path .. ".libraries.objects")
loveframes.require(path .. ".libraries.skins")

-- generic libraries
loveframes.class = require(path .. ".third-party.middleclass")
loveframes.utf8 = require(path .. ".third-party.utf8")


-- library info
loveframes.author = "Kenny Shields"
loveframes.version = "11.2"
loveframes.stage = "Alpha"

-- library configurations
loveframes.config = {}
loveframes.config["DIRECTORY"] = nil
loveframes.config["DEFAULTSKIN"] = "Default"
loveframes.config["ACTIVESKIN"] = "Default"
loveframes.config["INDEXSKINIMAGES"] = true
loveframes.config["DEBUG"] = false
loveframes.config["ENABLE_SYSTEM_CURSORS"] = true

-- misc library vars
loveframes.state = "none"
loveframes.drawcount = 0
loveframes.collisioncount = 0
loveframes.objectcount = 0
loveframes.hoverobject = false
loveframes.modalobject = false
loveframes.inputobject = false
loveframes.downobject = false
loveframes.resizeobject = false
loveframes.dragobject = false
loveframes.hover = false
loveframes.input_cursor_set = false
loveframes.prevcursor = nil
loveframes.basicfont = love.graphics.newFont(12)
loveframes.basicfontsmall = love.graphics.newFont(10)
loveframes.collisions = {}

-- install directory of the library
local dir = loveframes.config["DIRECTORY"] or path

-- replace all "." with "/" in the directory setting
dir = dir:gsub("\\", "/"):gsub("(%a)%.(%a)", "%1/%2")
loveframes.config["DIRECTORY"] = dir

-- enable key repeat
love.keyboard.setKeyRepeat(true)

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates all library objects
--]]---------------------------------------------------------
function loveframes.update(dt)

	local base = loveframes.base
	local input_cursor_set = loveframes.input_cursor_set
	
	loveframes.collisioncount = 0
	loveframes.objectcount = 0
	loveframes.hover = false
	loveframes.hoverobject = false
	
	local downobject = loveframes.downobject
	if #loveframes.collisions > 0 then
		local top = loveframes.collisions[#loveframes.collisions]
		if not downobject then
			loveframes.hoverobject = top
		else
			if downobject == top then
				loveframes.hoverobject = top
			end
		end
	end
	
	if loveframes.config["ENABLE_SYSTEM_CURSORS"] then 
		local hoverobject = loveframes.hoverobject
		local arrow = love.mouse.getSystemCursor("arrow")
		local curcursor = love.mouse.getCursor()
		if hoverobject then
			local ibeam = love.mouse.getSystemCursor("ibeam")
			local mx, my = love.mouse.getPosition()
			if hoverobject.type == "textinput" and not loveframes.resizeobject then
				if curcursor ~= ibeam then
					love.mouse.setCursor(ibeam)
				end
			elseif hoverobject.type == "frame" then
				if not hoverobject.dragging and hoverobject.canresize then
					if loveframes.BoundingBox(hoverobject.x, mx, hoverobject.y, my, 5, 1, 5, 1) then
						local sizenwse = love.mouse.getSystemCursor("sizenwse")
						if curcursor ~= sizenwse then
							love.mouse.setCursor(sizenwse)
						end
					elseif loveframes.BoundingBox(hoverobject.x + hoverobject.width - 5, mx, hoverobject.y + hoverobject.height - 5, my, 5, 1, 5, 1) then
						local sizenwse = love.mouse.getSystemCursor("sizenwse")
						if curcursor ~= sizenwse then
							love.mouse.setCursor(sizenwse)
						end
					elseif loveframes.BoundingBox(hoverobject.x + hoverobject.width - 5, mx, hoverobject.y, my, 5, 1, 5, 1) then
						local sizenesw = love.mouse.getSystemCursor("sizenesw")
						if curcursor ~= sizenesw then
							love.mouse.setCursor(sizenesw)
						end
					elseif loveframes.BoundingBox(hoverobject.x, mx, hoverobject.y + hoverobject.height - 5, my, 5, 1, 5, 1) then
						local sizenesw = love.mouse.getSystemCursor("sizenesw")
						if curcursor ~= sizenesw then
							love.mouse.setCursor(sizenesw)
						end
					elseif loveframes.BoundingBox(hoverobject.x + 5, mx, hoverobject.y, my, hoverobject.width - 10, 1, 2, 1) then
						local sizens = love.mouse.getSystemCursor("sizens")
						if curcursor ~= sizens then
							love.mouse.setCursor(sizens)
						end
					elseif loveframes.BoundingBox(hoverobject.x + 5, mx, hoverobject.y + hoverobject.height - 2, my, hoverobject.width - 10, 1, 2, 1) then
						local sizens = love.mouse.getSystemCursor("sizens")
						if curcursor ~= sizens then
							love.mouse.setCursor(sizens)
						end
					elseif loveframes.BoundingBox(hoverobject.x, mx, hoverobject.y + 5, my, 2, 1, hoverobject.height - 10, 1) then
						local sizewe = love.mouse.getSystemCursor("sizewe")
						if curcursor ~= sizewe then
							love.mouse.setCursor(sizewe)
						end
					elseif loveframes.BoundingBox(hoverobject.x + hoverobject.width - 2, mx, hoverobject.y + 5, my, 2, 1, hoverobject.height - 10, 1) then
						local sizewe = love.mouse.getSystemCursor("sizewe")
						if curcursor ~= sizewe then
							love.mouse.setCursor(sizewe)
						end
					else
						if not loveframes.resizeobject then
							local arrow = love.mouse.getSystemCursor("arrow")
							if curcursor ~= arrow then
								love.mouse.setCursor(arrow)
							end
						end
					end
				end
			elseif hoverobject.type == "text" and hoverobject.linkcol and not loveframes.resizeobject then
				local hand = love.mouse.getSystemCursor("hand")
				if curcursor ~= hand then
					love.mouse.setCursor(hand)
				end
			end
			if curcursor ~= arrow then
				if hoverobject.type ~= "textinput" and hoverobject.type ~= "frame" and not hoverobject.linkcol and not loveframes.resizeobject then
					love.mouse.setCursor(arrow)
				elseif hoverobject.type ~= "textinput" and curcursor == ibeam then
					love.mouse.setCursor(arrow)
				end
			end
		else
			if curcursor ~= arrow and not loveframes.resizeobject then
				love.mouse.setCursor(arrow)
			end
		end
	end
	
	loveframes.collisions = {}
	base:update(dt)

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws all library objects
--]]---------------------------------------------------------
function loveframes.draw()

	local base = loveframes.base
	local r, g, b, a = love.graphics.getColor()
	local font = love.graphics.getFont()
	
	base:draw()
	
	loveframes.drawcount = 0
	
	if loveframes.config["DEBUG"] then
		loveframes.DebugDraw()
	end
	
	love.graphics.setColor(r, g, b, a)
	
	if font then
		love.graphics.setFont(font)
	end
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function loveframes.mousepressed(x, y, button)

	local base = loveframes.base
	base:mousepressed(x, y, button)
	
	-- close open menus
	local bchildren = base.children
	local hoverobject = loveframes.hoverobject
	for k, v in ipairs(bchildren) do
		local otype = v.type
		local visible = v.visible
		if hoverobject then
			local htype = hoverobject.type
			if otype == "menu" and visible and htype ~= "menu" and htype ~= "menuoption" then
				v:SetVisible(false)
			end
		else
			if otype == "menu" and visible then
				v:SetVisible(false)
			end
		end
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function loveframes.mousereleased(x, y, button)

	local base = loveframes.base
	base:mousereleased(x, y, button)
	
	-- reset the hover object
	if button == 1 then
		loveframes.downobject = false
		loveframes.selectedobject = false
	end
	
end

--[[---------------------------------------------------------
	- func: wheelmoved(x, y)
	- desc: called when the player moves a mouse wheel
--]]---------------------------------------------------------
function loveframes.wheelmoved(x, y)

	local base = loveframes.base
	base:wheelmoved(x, y)

end

--[[---------------------------------------------------------
	- func: keypressed(key, isrepeat)
	- desc: called when the player presses a key
--]]---------------------------------------------------------
function loveframes.keypressed(key, isrepeat)

	local base = loveframes.base
	base:keypressed(key, isrepeat)
	
end

--[[---------------------------------------------------------
	- func: keyreleased(key)
	- desc: called when the player releases a key
--]]---------------------------------------------------------
function loveframes.keyreleased(key)

	local base = loveframes.base
	base:keyreleased(key)
	
end

--[[---------------------------------------------------------
	- func: textinput(text)
	- desc: called when the user inputs text
--]]---------------------------------------------------------
function loveframes.textinput(text)

	local base = loveframes.base
	base:textinput(text)
	
end


loveframes.LoadObjects(dir .. "/objects")
loveframes.LoadTemplates(dir .. "/templates")
loveframes.LoadSkins(dir .. "/skins")

-- create the base gui object
local base = loveframes.objects["base"]
loveframes.base = base:new()

return loveframes
