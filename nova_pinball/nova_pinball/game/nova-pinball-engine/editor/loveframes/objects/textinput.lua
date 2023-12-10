--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

local utf8 = require("utf8")

return function(loveframes)
---------- module start ----------

-- textinput object
local newobject = loveframes.NewObject("textinput", "loveframes_object_textinput", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()
	
	self.type = "textinput"
	self.keydown = "none"
	self.tabreplacement = "        "
	self.maskchar = "*"
	self.font = loveframes.basicfont
	self.width = 200
	self.height = 25
	self.delay = 0
	self.repeatdelay = 0.80
	self.repeatrate = 0.02
	self.offsetx = 0
	self.offsety = 0
	self.indincatortime = 0
	self.indicatornum = 0
	self.indicatorx = 0
	self.indicatory = 0
	self.textx = 0
	self.texty = 0
	self.textoffsetx = 5
	self.textoffsety = 5
	self.unicode = 0
	self.limit = 0
	self.line = 1
	self.itemwidth = 0
	self.itemheight = 0
	self.extrawidth = 0
	self.extraheight = 0
	self.rightpadding = 0
	self.bottompadding = 0
	self.lastclicktime = 0
	self.maxx = 0
	self.buttonscrollamount = 0.10
	self.mousewheelscrollamount = 5
	self.usable = {}
	self.unusable = {}
	self.lines = {""}
	self.placeholder = ""
	self.internals = {}
	self.showindicator = true
	self.focus = false
	self.multiline = false
	self.vbar = false
	self.hbar = false
	self.alltextselected = false
	self.linenumbers = true
	self.linenumberspanel = false
	self.editable = true
	self.internal = false
	self.autoscroll = false
	self.masked = false
	self.trackindicator = true
	self.OnEnter = nil
	self.OnTextChanged = nil
	self.OnFocusGained = nil
	self.OnFocusLost = nil
	self.OnCopy = nil
	self.OnPaste = nil
	
	self:SetDrawFunc()
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	-- check to see if the object is being hovered over
	self:CheckHover()
	
	local time = love.timer.getTime()
	local keydown = self.keydown
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	local font = self.font
	local theight = font:getHeight()
	local delay = self.delay
	local lines = self.lines
	local numlines = #lines
	local multiline = self.multiline
	local width = self.width
	local height = self.height
	local vbar = self.vbar
	local hbar = self.hbar
	local inputobject = loveframes.inputobject
	local internals = self.internals
	local repeatrate = self.repeatrate
	local hover = self.hover
	
	-- move to parent if there is a parent
	if parent ~= base then
		local parentx = parent.x
		local parenty = parent.y
		local staticx = self.staticx
		local staticy = self.staticy
		self.x = parentx + staticx
		self.y = parenty + staticy
	end
	
	if inputobject ~= self then
		self.focus = false
		self.alltextselected = false
	end
	
	self:PositionText()
	self:UpdateIndicator()
	
	-- calculations for multiline mode
	if multiline then
		local twidth = 0
		local panel = self:GetLineNumbersPanel()
		local textoffsetx = self.textoffsetx
		local textoffsety = self.textoffsety
		local linenumbers = self.linenumbers
		local masked = self.masked
		local maskchar = self.maskchar
		-- get the longest line of text
		for k, v in ipairs(lines) do
			local linewidth = 0
			if masked then
				linewidth = font:getWidth(v:gsub(".", maskchar))
			else
				linewidth = font:getWidth(v)
			end
			if linewidth > twidth then
				twidth = linewidth
			end
		end
		-- item width calculation
		if vbar then
			self.itemwidth = twidth + 16 + textoffsetx * 2
		else
			self.itemwidth = twidth + (textoffsetx * 2)
		end
		if panel then
			local panelwidth = panel.width
			self.itemwidth = self.itemwidth + panelwidth + textoffsetx + 5
		end
		-- item height calculation
		if hbar then
			self.itemheight = theight * numlines + 16 + textoffsety * 2
		else
			self.itemheight = theight * numlines
		end
		-- extra width and height calculations
		self.extrawidth = self.itemwidth - width
		self.extraheight = self.itemheight - height
		local itemwidth = self.itemwidth
		local itemheight = self.itemheight
		if itemheight > height then
			if not vbar then
				local scrollbody = loveframes.objects["scrollbody"]:new(self, "vertical")
				scrollbody.internals[1].internals[1].autoscroll = self.autoscroll
				table.insert(self.internals, scrollbody)
				self.vbar = true
				if hbar then
					local vbody = self:GetVerticalScrollBody()
					local vbodyheight = vbody:GetHeight() - 15
					local hbody = self:GetHorizontalScrollBody()
					local hbodywidth = hbody:GetWidth() - 15
					vbody:SetHeight(vbodyheight)
					hbody:SetWidth(hbodywidth)
				end
			end
		else
			if vbar then
				self:GetVerticalScrollBody():Remove()
				self.vbar = false
				self.offsety = 0
				if self.hbar then
					local hbody = self:GetHorizontalScrollBody()
					local hbodywidth = hbody:GetWidth() - 15
					hbody:SetWidth(hbodywidth)
				end
			end
		end
		
		if itemwidth > width then
			if not hbar then
				local scrollbody = loveframes.objects["scrollbody"]:new(self, "horizontal")
				scrollbody.internals[1].internals[1].autoscroll = self.autoscroll
				table.insert(self.internals, scrollbody)
				self.hbar = true
				if self.vbar then
					local vbody = self:GetVerticalScrollBody()
					local hbody = self:GetHorizontalScrollBody()
					vbody:SetHeight(vbody:GetHeight() - 15)
					hbody:SetWidth(hbody:GetWidth() - 15)
				end
			end
		else
			if hbar then
				self:GetHorizontalScrollBody():Remove()
				self.hbar = false
				self.offsetx = 0
				if vbar then
					local vbody = self:GetVerticalScrollBody()
					if vbody then
						vbody:SetHeight(vbody:GetHeight() + 15)
					end
				end
			end
		end
		if linenumbers then
			if not self.linenumberspanel then
				local linenumberspanel = loveframes.objects["linenumberspanel"]:new(self)
				table.insert(internals, linenumberspanel)
				self.linenumberspanel = true
			end
		else
			if self.linenumberspanel then
				table.remove(internals, 1)
				self.linenumberspanel = false
			end
		end
	end
	
	for k, v in ipairs(internals) do
		v:update(dt)
	end
	
	if update then
		update(self, dt)
	end
	
end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function newobject:draw()
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	local x = self.x
	local y = self.y
	local width = self.width
	local height = self.height
	local stencilfunc = function() love.graphics.rectangle("fill", x, y, width, height) end
	local vbar = self.vbar
	local hbar = self.hbar
	
	-- set the object's draw order
	self:SetDrawOrder()
	
	if vbar and hbar then
		stencilfunc = function() love.graphics.rectangle("fill", x, y, width - 16, height - 16) end
	end
	
	love.graphics.stencil(stencilfunc)
	love.graphics.setStencilTest("greater", 0)
	
	local drawfunc = self.Draw or self.drawfunc
	if drawfunc then
		drawfunc(self)
	end
	
	love.graphics.setStencilTest()
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:draw()
		end
	end
	
	drawfunc = self.DrawOver or self.drawoverfunc
	if drawfunc then
		drawfunc(self)
	end
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	if not visible then
		return
	end
	
	local hover = self.hover
	local internals = self.internals
	local alt = love.keyboard.isDown("lalt", "ralt")
	local vbar = self.vbar
	local hbar = self.hbar
	local scrollamount = self.mousewheelscrollamount
	local focus = self.focus
	local alltextselected = self.alltextselected
	local onfocusgained = self.OnFocusGained
	local onfocuslost = self.OnFocusLost
	local time = love.timer.getTime()
	local inputobject = loveframes.inputobject
	
	if hover then
		if button == 1 then
			if inputobject ~= self then
				loveframes.inputobject = self
			end
			if not alltextselected then
				local lastclicktime = self.lastclicktime
				if (time > lastclicktime) and time < (lastclicktime + 0.25) then
					if not self.multiline then
						if self.lines[1] ~= "" then
							self.alltextselected = true
						end
					else
						self.alltextselected = true
					end
				end
			else
				self.alltextselected = false
			end
			self.focus = true
			self.lastclicktime = time
			self:GetTextCollisions(x, y)
			if onfocusgained and not focus then
				onfocusgained(self)
			end
			local baseparent = self:GetBaseParent()
			if baseparent and baseparent.type == "frame" then
				baseparent:MakeTop()
			end
		elseif button == "wu" then
			if not alt then
				if focus then
					self.line = math.max(self.line - scrollamount, 1)
				elseif vbar then
					local vbar = self:GetVerticalScrollBody().internals[1].internals[1]
					vbar:Scroll(-scrollamount)
				end
			else
				if focus then
					self:MoveIndicator(-scrollamount)
				elseif hbar then
					local hbar = self:GetHorizontalScrollBody().internals[1].internals[1]
					hbar:Scroll(-scrollamount)
				end
			end
		elseif button == "wd" then
			if not alt then
				if focus then
					self.line = math.min(self.line + scrollamount, #self.lines)
				elseif vbar then
					local vbar = self:GetVerticalScrollBody().internals[1].internals[1]
					vbar:Scroll(scrollamount)
				end
			else
				if focus then
					self:MoveIndicator(scrollamount)
				elseif hbar then
					local hbar = self:GetHorizontalScrollBody().internals[1].internals[1]
					hbar:Scroll(scrollamount)
				end
			end
		end
	else
		if inputobject == self then
			loveframes.inputobject = false
			if onfocuslost then
				onfocuslost(self)
			end
		end
	end
	
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	if not visible then
		return
	end
	
	local internals = self.internals
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: keypressed(key, isrepeat)
	- desc: called when the player presses a key
--]]---------------------------------------------------------
function newobject:keypressed(key, isrepeat)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local time = love.timer.getTime()
	local focus = self.focus
	local repeatdelay = self.repeatdelay
	local alltextselected = self.alltextselected
	local editable = self.editable
	
	self.delay = time + repeatdelay
	self.keydown = key
	
	if (loveframes.IsCtrlDown()) and focus then
		if key == "a" then
			if not self.multiline then
				if self.lines[1] ~= "" then
					self.alltextselected = true
				end
			else
				self.alltextselected = true
			end
		elseif key == "c" and alltextselected then
			local text = self:GetText()
			local oncopy = self.OnCopy
			love.system.setClipboardText(text)
			if oncopy then
				oncopy(self, text)
			end
		elseif key == "x" and alltextselected and editable then
			local text = self:GetText()
			local oncut = self.OnCut
			love.system.setClipboardText(text)
			if oncut then
				oncut(self, text)
			else
				self:SetText("")
			end
		elseif key == "v" and editable then
			self:Paste()
		else
			self:RunKey(key, false)
		end
	else
		self:RunKey(key, false)
	end
	
end

--[[---------------------------------------------------------
	- func: keyreleased(key)
	- desc: called when the player releases a key
--]]---------------------------------------------------------
function newobject:keyreleased(key)
	
	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	if not visible then
		return
	end
	
	self.keydown = "none"
	
end

--[[---------------------------------------------------------
	- func: textinput(text)
	- desc: called when the inputs text
--]]---------------------------------------------------------
function newobject:textinput(text)

	if text:find("kp.") then
		text = text:gsub("kp", "")
	end
		
	self:RunKey(text, true)
	
end

--[[---------------------------------------------------------
	- func: RunKey(key, istext)
	- desc: runs a key event on the object
--]]---------------------------------------------------------
function newobject:RunKey(key, istext)
	
	local visible = self.visible
	local focus = self.focus
	
	if not visible then
		return
	end
	
	if not focus then
		return
	end
	
	local x = self.x
	local offsetx = self.offsetx
	local lines = self.lines
	local line = self.line
	local numlines = #lines
	local curline = lines[line]
	local text = curline
	local ckey = ""
	local font = self.font
	local swidth = self.width
	local textoffsetx = self.textoffsetx
	local indicatornum = self.indicatornum
	local multiline = self.multiline
	local alltextselected = self.alltextselected
	local editable = self.editable
	local initialtext = self:GetText()
	local ontextchanged = self.OnTextChanged
	local onenter = self.OnEnter
	
	if not istext then
		if key == "left" then
			indicatornum = self.indicatornum
			if not multiline then
				self:MoveIndicator(-1)
				local indicatorx = self.indicatorx
				if indicatorx <= x and indicatornum ~= 0 then
					local width = font:getWidth(text:sub(indicatornum, indicatornum + 1))
					self.offsetx = offsetx - width
				elseif indicatornum == 0 and offsetx ~= 0 then
					self.offsetx = 0
				end
			else
				if indicatornum == 0 then
					if line > 1 then
						self.line = line - 1
						local numchars = utf8.len(lines[self.line])
						self:MoveIndicator(numchars)
					end
				else
					self:MoveIndicator(-1)
				end
			end
			if alltextselected then
				self.line = 1
				self.indicatornum = 0
				self.alltextselected = false
			end
			return
		elseif key == "right" then
			indicatornum = self.indicatornum
			if not multiline then
				self:MoveIndicator(1)
				local indicatorx = self.indicatorx
				if indicatorx >= (x + swidth) and indicatornum ~= utf8.len(text) then
					local width = font:getWidth(text:sub(indicatornum, indicatornum))
					self.offsetx = offsetx + width
				elseif indicatornum == utf8.len(text) and offsetx ~= ((font:getWidth(text)) - swidth + 10) and font:getWidth(text) + textoffsetx > swidth then
					self.offsetx = ((font:getWidth(text)) - swidth + 10)
				end
			else
				if indicatornum == utf8.len(text) then
					if line < numlines then
						self.line = line + 1
						self:MoveIndicator(0, true)
					end
				else
					self:MoveIndicator(1)
				end
			end
			if alltextselected then
				self.line = #lines
				self.indicatornum = utf8.len(lines[#lines])
				self.alltextselected = false
			end
			return
		elseif key == "up" then
			if multiline then
				if line > 1 then
					self.line = line - 1
					if indicatornum > utf8.len(lines[self.line]) then
						self.indicatornum = utf8.len(lines[self.line])
					end
				end
			end
			return
		elseif key == "down" then
			if multiline then
				if line < #lines then
					self.line = line + 1
					if indicatornum > utf8.len(lines[self.line]) then
						self.indicatornum = utf8.len(lines[self.line])
					end
				end
			end
			return
		end
		
		if not editable then
			return
		end
		
		-- key input checking system
		if key == "backspace" then
			ckey = key
			if alltextselected then
				self:Clear()
				self.alltextselected = false
				indicatornum = self.indicatornum
			else
				if text ~= "" and indicatornum ~= 0 then
					text = self:RemoveFromText(indicatornum)
					self:MoveIndicator(-1)
					lines[line] = text
				end
				if multiline then
					if line > 1 and indicatornum == 0 then
						local newindicatornum = 0
						local oldtext = lines[line]
						table.remove(lines, line)
						self.line = line - 1
						if utf8.len(oldtext) > 0 then
							newindicatornum = utf8.len(lines[self.line])
							lines[self.line] = lines[self.line] .. oldtext
							self:MoveIndicator(newindicatornum)
						else
							self:MoveIndicator(utf8.len(lines[self.line]))
						end
					end
				end
				local masked = self.masked
				local cwidth = 0
				if masked then
					local maskchar = self.maskchar
					cwidth = font:getWidth(text:gsub(".", maskchar))
				else
					cwidth = font:getWidth(text)
				end
				if self.offsetx > 0 then
					self.offsetx = self.offsetx - cwidth
				elseif self.offsetx < 0 then
					self.offsetx = 0
				end
			end
		elseif key == "delete" then
			if not editable then
				return
			end
			ckey = key
			if alltextselected then
				self:Clear()
				self.alltextselected = false
				indicatornum = self.indicatornum
			else
				if text ~= "" and indicatornum < utf8.len(text) then
					text = self:RemoveFromText(indicatornum + 1)
					lines[line] = text
				elseif indicatornum == utf8.len(text) and line < #lines then
					local oldtext = lines[line + 1]
					if utf8.len(oldtext) > 0 then
						-- FIXME: newindicatornum here???
						-- newindicatornum = utf8.len(lines[self.line])
						lines[self.line] = lines[self.line] .. oldtext
					end
					table.remove(lines, line + 1)
				end
			end
		elseif key == "return" or key == "kpenter" then
			ckey = key
			-- call onenter if it exists
			if onenter then
				onenter(self, text)
			end
			-- newline calculations for multiline mode
			if multiline then
				if alltextselected then
					self.alltextselected = false
					self:Clear()
					indicatornum = self.indicatornum
					line = self.line
				end
				local newtext = "" 
				if indicatornum == 0 then
					newtext = self.lines[line]
					self.lines[line] = ""
				elseif indicatornum > 0 and indicatornum < utf8.len(self.lines[line]) then
					newtext = self.lines[line]:sub(indicatornum + 1, utf8.len(self.lines[line]))
					self.lines[line] = self.lines[line]:sub(1, indicatornum)
				end
				if line ~= #lines then
					table.insert(self.lines, line + 1, newtext)
					self.line = line + 1
				else
					table.insert(self.lines, newtext)
					self.line = line + 1
				end
				self.indicatornum = 0
				local hbody = self:GetHorizontalScrollBody()
				if hbody then
					hbody:GetScrollBar():Scroll(-hbody:GetWidth())
				end
			end
		elseif key == "tab" then
			if alltextselected then
				return
			end
			ckey = key
			self.lines[self.line] = self:AddIntoText(self.tabreplacement, self.indicatornum)
			self:MoveIndicator(utf8.len(self.tabreplacement))
		end
	else
		if not editable then
			return
		end
		-- do not continue if the text limit has been reached or exceeded
		if utf8.len(text) >= self.limit and self.limit ~= 0 and not alltextselected then
			return
		end
		-- check for unusable characters
		if #self.usable > 0 then
			local found = false
			for k, v in ipairs(self.usable) do
				if v == key then
					found = true
				end
			end
			if not found then
				return
			end
		end
		-- check for usable characters
		if #self.unusable > 0 then
			local found = false
			for k, v in ipairs(self.unusable) do
				if v == key then
					found = true
				end
			end
			if found then
				return
			end
		end
		if alltextselected then
			self.alltextselected = false
			self:Clear()
			indicatornum = self.indicatornum
			text = ""
			lines = self.lines
			line = self.line
		end
		if indicatornum ~= 0 and indicatornum ~= utf8.len(text) then
			text = self:AddIntoText(key, indicatornum)
			lines[line] = text
			self:MoveIndicator(1)
		elseif indicatornum == utf8.len(text) then
			text = text .. key
			lines[line] = text
			self:MoveIndicator(1)
		elseif indicatornum == 0 then
			text = self:AddIntoText(key, indicatornum)
			lines[line] = text
			self:MoveIndicator(1)
		end
		lines = self.lines
		line = self.line
		curline = lines[line]
		text = curline
		if not multiline then
			local masked = self.masked
			local twidth = 0
			local cwidth = 0
			if masked then
				local maskchar = self.maskchar
				twidth = font:getWidth(text:gsub(".", maskchar))
				cwidth = font:getWidth(key:gsub(".", maskchar))
			else
				twidth = font:getWidth(text)
				cwidth = font:getWidth(key)
			end
			-- swidth - 1 is for the "-" character
			if (twidth + textoffsetx) >= (swidth - 1) then
				self.offsetx = self.offsetx + cwidth
			end
		end
	end
	
	local curtext = self:GetText()
	if ontextchanged and initialtext ~= curtext then
		ontextchanged(self, key)
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: MoveIndicator(num, exact)
	- desc: moves the object's indicator
--]]---------------------------------------------------------
function newobject:MoveIndicator(num, exact)

	local lines = self.lines
	local line = self.line
	local curline = lines[line]
	local text = curline
	local indicatornum = self.indicatornum
	
	if not exact then
		self.indicatornum = indicatornum + num
	else
		self.indicatornum = num
	end
	
	if self.indicatornum > utf8.len(text) then
		self.indicatornum = utf8.len(text)
	elseif self.indicatornum < 0 then
		self.indicatornum = 0
	end
	
	self.showindicator = true
	self:UpdateIndicator()
	
	return self
	
end

--[[---------------------------------------------------------
	- func: UpdateIndicator()
	- desc: updates the object's text insertion position 
			indicator
--]]---------------------------------------------------------
function newobject:UpdateIndicator()

	local time = love.timer.getTime()
	local indincatortime = self.indincatortime
	local indicatornum = self.indicatornum
	local lines = self.lines
	local line = self.line
	local curline = lines[line]
	local text = curline
	local font = self.font
	local theight = font:getHeight()
	local offsetx = self.offsetx
	local multiline = self.multiline
	local showindicator = self.showindicator
	local alltextselected = self.alltextselected
	local textx = self.textx
	local texty = self.texty
	local masked = self.masked
	
	if indincatortime < time then
		if showindicator then
			self.showindicator = false
		else
			self.showindicator = true
		end
		self.indincatortime = time + 0.50
	end
	
	if alltextselected then
		self.showindicator = false
	else
		if love.keyboard.isDown("up", "down", "left", "right") then
			self.showindicator = true
		end
	end
	
	local width = 0
	if masked then
		width = font:getWidth(string.rep(self.maskchar,indicatornum))
	else
		if indicatornum == 0 then
			width = 0
		elseif indicatornum >= utf8.len(text) then
			width = font:getWidth(text)
		else
			width = font:getWidth(text:sub(1, utf8.offset (text, indicatornum + 1) - 1))
		end
	end
	
	if multiline then
		self.indicatorx = textx + width
		self.indicatory	= texty + theight * line - theight
	else
		self.indicatorx = textx + width
		self.indicatory	= texty
	end
	
	-- indicator should be visible, so correcting scrolls
	if self.focus and self.trackindicator then
		local indicatorRelativeX = width + self.textoffsetx - self.offsetx
		local leftlimit, rightlimit = 1, self:GetWidth() - 1
		if self.linenumberspanel then
			rightlimit = rightlimit - self:GetLineNumbersPanel().width
		end
		if self.vbar then
			rightlimit = rightlimit - self:GetVerticalScrollBody().width
		end
		if not (indicatorRelativeX > leftlimit and indicatorRelativeX < rightlimit) then 
			local hbody = self:GetHorizontalScrollBody()
			if hbody then
				local twidth = 0
				for k, v in ipairs(lines) do
					local linewidth = 0
					if self.masked then
						linewidth = font:getWidth(v:gsub(".", self.maskchar))
					else
						linewidth = font:getWidth(v)
					end
					if linewidth > twidth then
						twidth = linewidth
					end
				end
				local correction = self:GetWidth() / 8
				if indicatorRelativeX < leftlimit then
					correction = correction * -1
				end
				hbody:GetScrollBar():ScrollTo((width + correction) / twidth)
			end
		end
		local indicatorRelativeY = (line - 1) * theight + self.textoffsety - self.offsety
		local uplimit, downlimit = theight, self:GetHeight() - theight
		if self.hbar then
			downlimit = downlimit - self:GetHorizontalScrollBody().height
		end
		if not (indicatorRelativeY > uplimit and indicatorRelativeY < downlimit) then 
			local vbody = self:GetVerticalScrollBody()
			if vbody then
				local correction = self:GetHeight() / 8 / theight
				if indicatorRelativeY < uplimit then
					correction = correction * -1
				end
				vbody:GetScrollBar():ScrollTo((line - 1 + correction)/#lines)
			end
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: AddIntoText(t, p)
	- desc: adds text into the object's text at a given 
			position
--]]---------------------------------------------------------
function newobject:AddIntoText(t, p)

	local lines = self.lines
	local line = self.line
	local curline = lines[line]
	local text = curline
	local part1 = text:sub(1, utf8.offset(text, p + 1) - 1)
	local part2 = text:sub(utf8.offset(text, p + 1))
	local new = part1 .. t .. part2
	
	return new
	
end

--[[---------------------------------------------------------
	- func: RemoveFromText(p)
	- desc: removes text from the object's text a given 
			position
--]]---------------------------------------------------------
function newobject:RemoveFromText(p)

	local lines = self.lines
	local line = self.line
	local curline = lines[line]
	local text = curline
	local part1 = text:sub(1, utf8.offset(text, p) - 1)
	local part2 = text:sub(utf8.offset(text, p + 1))
	local new = part1 .. part2
	return new
	
end

--[[---------------------------------------------------------
	- func: GetTextCollisions(x, y)
	- desc: gets text collisions with the mouse
--]]---------------------------------------------------------
function newobject:GetTextCollisions(x, y)

	local font = self.font
	local lines = self.lines
	local numlines = #lines
	local line = self.line
	local curline = lines[line]
	local text = curline
	local xpos = 0
	local line = 0
	local vbar = self.vbar
	local hbar = self.hbar
	local multiline = self.multiline
	local selfx = self.x
	local selfy = self.y
	local selfwidth = self.width
	local masked = self.masked
			
	if multiline then
		local theight = font:getHeight()
		local liney = 0
		local selfcol
		if vbar and not hbar then
			selfcol = loveframes.BoundingBox(selfx, x, selfy, y, selfwidth - 16, 1, self.height, 1)
		elseif hbar and not vbar then
			selfcol = loveframes.BoundingBox(selfx, x, selfy, y, selfwidth, 1, self.height - 16, 1)
		elseif not vbar and not hbar then
			selfcol = loveframes.BoundingBox(selfx, x, selfy, y, selfwidth, 1, self.height, 1)
		elseif vbar and hbar then
			selfcol = loveframes.BoundingBox(selfx, x, selfy, y, selfwidth - 16, 1, self.height - 16, 1)
		end
		if selfcol then
			local offsety = self.offsety
			local textoffsety = self.textoffsety
			for i=1, numlines do
				local linecol = loveframes.BoundingBox(selfx, x, (selfy - offsety) + textoffsety + (theight * i) - theight, y, self.width, 1, theight, 1)
				if linecol then
					liney = (selfy - offsety) + textoffsety + (theight * i) - theight
					self.line = i
				end
			end
			local line = self.line
			local curline = lines[line]
			for i=1, utf8.len(curline) do
				local char = text:sub(i, i)
				local width = 0
				if masked then
					local maskchar = self.maskchar
					width = font:getWidth(maskchar)
				else
					width = font:getWidth(char)
				end
				local height = font:getHeight()
				local tx = self.textx + xpos
				local ty = self.texty
				local col = loveframes.BoundingBox(tx, x, liney, y, width, 1, height, 1)
				
				xpos = xpos + width
				
				if col then
					self:MoveIndicator(i - 1, true)
					break
				else
					self.indicatornum = utf8.len(curline)
				end
				
				if x < tx then
					self:MoveIndicator(0, true)
				end
				
				if x > (tx + width) then
					self:MoveIndicator(utf8.len(curline), true)
				end
			end
			
			if utf8.len(curline) == 0 then
				self.indicatornum = 0
			end
		end
	else
		local i = 0
		for p, c in utf8.codes(text) do
			i = i + 1
			local char = utf8.char(c)
			local width = 0
			if masked then
				local maskchar = self.maskchar
				width = font:getWidth(maskchar)
			else
				width = font:getWidth(char)
			end
			local height = font:getHeight()
			local tx = self.textx + xpos
			local ty = self.texty
			local col = loveframes.BoundingBox(tx, x, ty, y, width, 1, height, 1)
			xpos = xpos + width
			if col then
				self:MoveIndicator(i - 1, true)
				break
			end
			if x < tx then
				self:MoveIndicator(0, true)
			end
			if x > (tx + width) then
				self:MoveIndicator(utf8.len(text), true)
			end
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: PositionText()
	- desc: positions the object's text
--]]---------------------------------------------------------
function newobject:PositionText()

	local multiline = self.multiline
	local x = self.x
	local y = self.y
	local offsetx = self.offsetx
	local offsety = self.offsety
	local textoffsetx = self.textoffsetx
	local textoffsety = self.textoffsety
	local linenumberspanel = self.linenumberspanel
	
	if multiline then
		if linenumberspanel then
			local panel = self:GetLineNumbersPanel()
			self.textx = ((x + panel.width) - offsetx) + textoffsetx
			self.texty = (y - offsety) + textoffsety
		else
			self.textx = (x - offsetx) + textoffsetx
			self.texty = (y - offsety) + textoffsety
		end
	else
		self.textx = (x - offsetx) + textoffsetx
		self.texty = (y - offsety) + textoffsety
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetTextOffsetX(num)
	- desc: sets the object's text x offset
--]]---------------------------------------------------------
function newobject:SetTextOffsetX(num)

	self.textoffsetx = num
	return self
	
end

--[[---------------------------------------------------------
	- func: SetTextOffsetY(num)
	- desc: sets the object's text y offset
--]]---------------------------------------------------------
function newobject:SetTextOffsetY(num)

	self.textoffsety = num
	return self
	
end

--[[---------------------------------------------------------
	- func: SetFont(font)
	- desc: sets the object's font
--]]---------------------------------------------------------
function newobject:SetFont(font)

	self.font = font
	return self
	
end

--[[---------------------------------------------------------
	- func: GetFont()
	- desc: gets the object's font
--]]---------------------------------------------------------
function newobject:GetFont()

	return self.font
	
end

--[[---------------------------------------------------------
	- func: SetFocus(focus)
	- desc: sets the object's focus
--]]---------------------------------------------------------
function newobject:SetFocus(focus)

	local inputobject = loveframes.inputobject
	local onfocusgained = self.OnFocusGained
	local onfocuslost = self.OnFocusLost
	
	self.focus = focus
	
	if focus then
		loveframes.inputobject = self
		if onfocusgained then
			onfocusgained(self)
		end
	else
		if inputobject == self then
			loveframes.inputobject = false
		end
		if onfocuslost then
			onfocuslost(self)
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetFocus()
	- desc: gets the object's focus
--]]---------------------------------------------------------
function newobject:GetFocus()

	return self.focus
	
end

--[[---------------------------------------------------------
	- func: GetIndicatorVisibility()
	- desc: gets the object's indicator visibility
--]]---------------------------------------------------------
function newobject:GetIndicatorVisibility()

	return self.showindicator
	
end

--[[---------------------------------------------------------
	- func: SetLimit(limit)
	- desc: sets the object's text limit
--]]---------------------------------------------------------
function newobject:SetLimit(limit)

	self.limit = limit
	return self
	
end

--[[---------------------------------------------------------
	- func: SetUsable(usable)
	- desc: sets what characters can be used for the 
			object's text
--]]---------------------------------------------------------
function newobject:SetUsable(usable)

	self.usable = usable
	return self
	
end

--[[---------------------------------------------------------
	- func: GetUsable()
	- desc: gets what characters can be used for the 
			object's text
--]]---------------------------------------------------------
function newobject:GetUsable()

	return self.usable
	
end

--[[---------------------------------------------------------
	- func: SetUnusable(unusable)
	- desc: sets what characters can not be used for the 
			object's text
--]]---------------------------------------------------------
function newobject:SetUnusable(unusable)

	self.unusable = unusable
	return self
	
end

--[[---------------------------------------------------------
	- func: GetUnusable()
	- desc: gets what characters can not be used for the 
			object's text
--]]---------------------------------------------------------
function newobject:GetUnusable()

	return self.unusable
	
end

--[[---------------------------------------------------------
	- func: Clear()
	- desc: clears the object's text
--]]---------------------------------------------------------
function newobject:Clear()

	self.lines = {""}
	self.line = 1
	self.offsetx = 0
	self.offsety = 0
	self.indicatornum = 0
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function newobject:SetText(text)

	local tabreplacement = self.tabreplacement
	local multiline = self.multiline
	
	text = tostring(text)
	text = text:gsub(string.char(9), tabreplacement)
	text = text:gsub(string.char(13), "")
	
	if multiline then
		text = text:gsub(string.char(92) .. string.char(110), string.char(10))
		local t = loveframes.SplitString(text, string.char(10))
		if #t > 0 then
			self.lines = t
		else
			self.lines = {""}
		end
		self.line = #self.lines
		self.indicatornum = utf8.len(self.lines[#self.lines])
	else
		text = text:gsub(string.char(92) .. string.char(110), "")
		text = text:gsub(string.char(10), "")
		self.lines = {text}
		self.line = 1
		self.indicatornum = utf8.len(text)
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function newobject:GetText()

	local multiline = self.multiline
	local lines = self.lines
	local text = ""
	
	if multiline then
		for k, v in ipairs(lines) do
			text = text .. v
			if k ~= #lines then
				text = text .. "\n"
			end
		end
	else
		text = lines[1]
	end
	
	return text
	
end

--[[---------------------------------------------------------
	- func: SetMultiline(bool)
	- desc: enables or disables allowing multiple lines for
			text entry
--]]---------------------------------------------------------
function newobject:SetMultiline(bool)

	local text = ""
	local lines = self.lines
	
	self.multiline = bool
	
	if bool then
		self:Clear()
	else
		for k, v in ipairs(lines) do
			text = text .. v
		end
		self:SetText(text)
		self.internals = {}
		self.vbar = false
		self.hbar = false
		self.linenumberspanel = false
	end
	
	return self

end

--[[---------------------------------------------------------
	- func: GetMultiLine()
	- desc: gets whether or not the object is using multiple
			lines
--]]---------------------------------------------------------
function newobject:GetMultiLine()

	return self.multiline
	
end

--[[---------------------------------------------------------
	- func: GetVerticalScrollBody()
	- desc: gets the object's vertical scroll body
--]]---------------------------------------------------------
function newobject:GetVerticalScrollBody()

	local vbar = self.vbar
	local internals = self.internals
	local item = false
	
	if vbar then
		for k, v in ipairs(internals) do
			if v.type == "scrollbody" and v.bartype == "vertical" then
				item = v
			end
		end
	end
	
	return item

end

--[[---------------------------------------------------------
	- func: GetHorizontalScrollBody()
	- desc: gets the object's horizontal scroll body
--]]---------------------------------------------------------
function newobject:GetHorizontalScrollBody()

	local hbar = self.hbar
	local internals = self.internals
	local item = false
	
	if hbar then
		for k, v in ipairs(internals) do
			if v.type == "scrollbody" and v.bartype == "horizontal" then
				item = v
			end
		end
	end
	
	return item

end

--[[---------------------------------------------------------
	- func: HasVerticalScrollBar()
	- desc: gets whether or not the object has a vertical
			scroll bar
--]]---------------------------------------------------------
function newobject:HasVerticalScrollBar()

	return self.vbar
	
end

--[[---------------------------------------------------------
	- func: HasHorizontalScrollBar()
	- desc: gets whether or not the object has a horizontal
			scroll bar
--]]---------------------------------------------------------
function newobject:HasHorizontalScrollBar()

	return self.hbar
	
end

--[[---------------------------------------------------------
	- func: GetLineNumbersPanel()
	- desc: gets the object's line numbers panel
--]]---------------------------------------------------------
function newobject:GetLineNumbersPanel()

	local panel = self.linenumberspanel
	local internals = self.internals
	local item = false
	
	if panel then
		for k, v in ipairs(internals) do
			if v.type == "linenumberspanel" then
				item = v
			end
		end
	end
	
	return item
	
end

--[[---------------------------------------------------------
	- func: ShowLineNumbers(bool)
	- desc: sets whether or not to show line numbers when
			using multiple lines
--]]---------------------------------------------------------
function newobject:ShowLineNumbers(bool)

	local multiline = self.multiline
	
	if multiline then
		self.linenumbers = bool
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetTextX()
	- desc: gets the object's text x
--]]---------------------------------------------------------
function newobject:GetTextX()

	return self.textx
	
end

--[[---------------------------------------------------------
	- func: GetTextY()
	- desc: gets the object's text y
--]]---------------------------------------------------------
function newobject:GetTextY()

	return self.texty
	
end

--[[---------------------------------------------------------
	- func: IsAllTextSelected()
	- desc: gets whether or not all of the object's text is
			selected
--]]---------------------------------------------------------
function newobject:IsAllTextSelected()

	return self.alltextselected
	
end

--[[---------------------------------------------------------
	- func: GetLines()
	- desc: gets the object's lines
--]]---------------------------------------------------------
function newobject:GetLines()

	return self.lines
	
end

--[[---------------------------------------------------------
	- func: GetOffsetX()
	- desc: gets the object's x offset
--]]---------------------------------------------------------
function newobject:GetOffsetX()

	return self.offsetx
	
end

--[[---------------------------------------------------------
	- func: GetOffsetY()
	- desc: gets the object's y offset
--]]---------------------------------------------------------
function newobject:GetOffsetY()

	return self.offsety
	
end

--[[---------------------------------------------------------
	- func: GetIndicatorX()
	- desc: gets the object's indicator's xpos
--]]---------------------------------------------------------
function newobject:GetIndicatorX()

	return self.indicatorx
	
end

--[[---------------------------------------------------------
	- func: GetIndicatorY()
	- desc: gets the object's indicator's ypos
--]]---------------------------------------------------------
function newobject:GetIndicatorY()

	return self.indicatory
	
end

--[[---------------------------------------------------------
	- func: GetLineNumbersEnabled()
	- desc: gets whether line numbers are enabled on the
			object or not
--]]---------------------------------------------------------
function newobject:GetLineNumbersEnabled()

	return self.linenumbers
	
end

--[[---------------------------------------------------------
	- func: GetItemWidth()
	- desc: gets the object's item width
--]]---------------------------------------------------------
function newobject:GetItemWidth()

	return self.itemwidth
	
end

--[[---------------------------------------------------------
	- func: GetItemHeight()
	- desc: gets the object's item height
--]]---------------------------------------------------------
function newobject:GetItemHeight()

	return self.itemheight
	
end

--[[---------------------------------------------------------
	- func: SetTabReplacement(tabreplacement)
	- desc: sets a string to replace tabs with
--]]---------------------------------------------------------
function newobject:SetTabReplacement(tabreplacement)

	self.tabreplacement = tabreplacement
	return self
	
end

--[[---------------------------------------------------------
	- func: GetTabReplacement()
	- desc: gets the object's tab replacement
--]]---------------------------------------------------------
function newobject:GetTabReplacement()

	return self.tabreplacement
	
end

--[[---------------------------------------------------------
	- func: SetEditable(bool)
	- desc: sets whether or not the user can edit the
			object's text
--]]---------------------------------------------------------
function newobject:SetEditable(bool)

	self.editable = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetEditable
	- desc: gets whether or not the user can edit the
			object's text
--]]---------------------------------------------------------
function newobject:GetEditable()

	return self.editable
	
end

--[[---------------------------------------------------------
	- func: SetButtonScrollAmount(speed)
	- desc: sets the scroll amount of the object's scrollbar
			buttons
--]]---------------------------------------------------------
function newobject:SetButtonScrollAmount(amount)

	self.buttonscrollamount = amount
	return self
	
end

--[[---------------------------------------------------------
	- func: GetButtonScrollAmount()
	- desc: gets the scroll amount of the object's scrollbar
			buttons
--]]---------------------------------------------------------
function newobject:GetButtonScrollAmount()

	return self.buttonscrollamount
	
end

--[[---------------------------------------------------------
	- func: SetMouseWheelScrollAmount(amount)
	- desc: sets the scroll amount of the mouse wheel
--]]---------------------------------------------------------
function newobject:SetMouseWheelScrollAmount(amount)

	self.mousewheelscrollamount = amount
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMouseWheelScrollAmount()
	- desc: gets the scroll amount of the mouse wheel
--]]---------------------------------------------------------
function newobject:GetButtonScrollAmount()

	return self.mousewheelscrollamount
	
end

--[[---------------------------------------------------------
	- func: SetAutoScroll(bool)
	- desc: sets whether or not the object should autoscroll
			when in multiline mode
--]]---------------------------------------------------------
function newobject:SetAutoScroll(bool)
	
	local internals = self.internals
	
	self.autoscroll = bool
	
	if internals[2] then
		internals[2].internals[1].internals[1].autoscroll = bool
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetAutoScroll()
	- desc: gets whether or not the object should autoscroll
			when in multiline mode
--]]---------------------------------------------------------
function newobject:GetAutoScroll()

	return self.autoscroll
	
end

--[[---------------------------------------------------------
	- func: SetRepeatDelay(delay)
	- desc: sets the object's repeat delay
--]]---------------------------------------------------------
function newobject:SetRepeatDelay(delay)

	self.repeatdelay = delay
	return self
	
end

--[[---------------------------------------------------------
	- func: GetRepeatDelay()
	- desc: gets the object's repeat delay
--]]---------------------------------------------------------
function newobject:GetRepeatDelay()

	return self.repeatdelay
	
end

--[[---------------------------------------------------------
	- func: SetRepeatRate(rate)
	- desc: sets the object's repeat rate
--]]---------------------------------------------------------
function newobject:SetRepeatRate(rate)

	self.repeatrate = rate
	return self
	
end

--[[---------------------------------------------------------
	- func: GetRepeatRate()
	- desc: gets the object's repeat rate
--]]---------------------------------------------------------
function newobject:GetRepeatRate()

	return self.repeatrate
	
end

--[[---------------------------------------------------------
	- func: SetValue(value)
	- desc: sets the object's value (alias of SetText)
--]]---------------------------------------------------------
function newobject:SetValue(value)

	self:SetText(value)
	return self
	
end

--[[---------------------------------------------------------
	- func: GetValue()
	- desc: gets the object's value (alias of GetText)
--]]---------------------------------------------------------
function newobject:GetValue()

	return self:GetText()
	
end

--[[---------------------------------------------------------
	- func: SetVisible(bool)
	- desc: sets the object's visibility
--]]---------------------------------------------------------
function newobject:SetVisible(bool)

	self.visible = bool
	
	if not bool then
		self.keydown = "none"
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: Copy()
	- desc: copies the object's text to the user's clipboard
--]]---------------------------------------------------------
function newobject:Copy()

	local text = self:GetText()
	love.system.setClipboardText(text)
	
	return self
	
end

--[[---------------------------------------------------------
	- func: Paste()
	- desc: pastes the current contents of the clipboard 
			into the object's text
--]]---------------------------------------------------------
function newobject:Paste()
	
	local text = love.system.getClipboardText()
	local usable = self.usable
	local unusable = self.unusable
	local limit = self.limit
	local alltextselected = self.alltextselected
	local onpaste = self.OnPaste
	local ontextchanged = self.OnTextChanged
	
	if limit > 0 then
		local curtext = self:GetText()
		local curlength = curtext:len()
		if curlength == limit then
			return
		else
			local inputlimit = limit - curlength
			if text:len() > inputlimit then
				text = text:sub(1, inputlimit)
			end
		end
	end
	local charcheck = function(a)
		if #usable > 0 then
			if not loveframes.TableHasValue(usable, a) then
				return ""
			end
		elseif #unusable > 0 then
			if loveframes.TableHasValue(unusable, a) then
				return ""
			end
		end
	end
	if #usable > 0 or #unusable > 0 then
		text = text:gsub(".", charcheck)
	end
	if alltextselected then
		self:SetText(text)
		self.alltextselected = false
		if ontextchanged then
			ontextchanged(self, text)
		end
	else
		local tabreplacement = self.tabreplacement
		local indicatornum = self.indicatornum
		local lines = self.lines
		local multiline = self.multiline
		if multiline then
			local parts = loveframes.SplitString(text, string.char(10))
			local numparts = #parts
			local oldlinedata = {}
			local line = self.line
			local first = lines[line]:sub(0, indicatornum)
			local last = lines[line]:sub(indicatornum + 1)
			if numparts > 1 then
				for i=1, numparts do
					local part = parts[i]:gsub(string.char(13),  "")
					part = part:gsub(string.char(9), "    ")
					if i ~= 1 then
						table.insert(oldlinedata, lines[line])
						lines[line] = part
						if i == numparts then
							self.indicatornum = part:len()
							lines[line] = lines[line] .. last
							self.line = line
						end
					else
						lines[line] = first .. part
					end
					line = line + 1
				end
				for i=1, #oldlinedata do
					lines[line] = oldlinedata[i]
					line = line + 1
				end
				if ontextchanged then
					ontextchanged(self, text)
				end
			elseif numparts == 1 then
				text = text:gsub(string.char(10), " ")
				text = text:gsub(string.char(13), " ")
				text = text:gsub(string.char(9), tabreplacement)
				local length = text:len()
				local new = first .. text .. last
				lines[line] = new
				self.indicatornum = indicatornum + length
				if ontextchanged then
					ontextchanged(self, text)
				end
			end
		else
			text = text:gsub(string.char(10), " ")
			text = text:gsub(string.char(13), " ")
			text = text:gsub(string.char(9), tabreplacement)
			local length = text:len()
			local linetext = lines[1]
			local part1 = linetext:sub(1, indicatornum)
			local part2 = linetext:sub(indicatornum + 1)
			local new = part1 .. text .. part2
			lines[1] = new
			self.indicatornum = indicatornum + length
			if ontextchanged then
				ontextchanged(self, text)
			end
		end
	end
	if onpaste then
		onpaste(self, text)
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SelectAll()
	- desc: selects all of the object's text
--]]---------------------------------------------------------
function newobject:SelectAll()

	if not self.multiline then
		if self.lines[1] ~= "" then
			self.alltextselected = true
		end
	else
		self.alltextselected = true
	end

	return self
	
end

--[[---------------------------------------------------------
	- func: DeselectAll()
	- desc: deselects all of the object's text
--]]---------------------------------------------------------
function newobject:DeselectAll()

	self.alltextselected = false
	return self
	
end

--[[---------------------------------------------------------
	- func: SetMasked(masked)
	- desc: sets whether or not the object is masked
--]]---------------------------------------------------------
function newobject:SetMasked(masked)

	self.masked = masked
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMasked()
	- desc: gets whether or not the object is masked
--]]---------------------------------------------------------
function newobject:GetMasked()

	return self.masked
	
end

--[[---------------------------------------------------------
	- func: SetMaskChar(char)
	- desc: sets the object's mask character
--]]---------------------------------------------------------
function newobject:SetMaskChar(char)

	self.maskchar = char
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMaskChar()
	- desc: gets the object's mask character
--]]---------------------------------------------------------
function newobject:GetMaskChar()

	return self.maskchar
	
end

--[[---------------------------------------------------------
	- func: SetPlaceholderText(text)
	- desc: sets the object's placeholder text
--]]---------------------------------------------------------
function newobject:SetPlaceholderText(text)

	self.placeholder = text
	return self
	
end

--[[---------------------------------------------------------
	- func: GetPlaceholderText()
	- desc: gets the object's placeholder text
--]]---------------------------------------------------------
function newobject:GetPlaceholderText()

	return self.placeholder
	
end

--[[---------------------------------------------------------
	- func: ClearLine(line)
	- desc: clears the specified line
--]]---------------------------------------------------------
function newobject:ClearLine(line)
	
	if self.lines[line] then
		self.lines[line] = ""
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetTrackingEnabled(bool)
	- desc: sets whether or not the object should
			automatically scroll to the position of its
			indicator
--]]---------------------------------------------------------
function newobject:SetTrackingEnabled(bool)

	self.trackindicator = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetTrackingEnabled()
	- desc: gets whether or not the object should
			automatically scroll to the position of its
			indicator
--]]---------------------------------------------------------
function newobject:GetTrackingEnabled()

	return self.trackindicator
	
end

---------- module end ----------
end
