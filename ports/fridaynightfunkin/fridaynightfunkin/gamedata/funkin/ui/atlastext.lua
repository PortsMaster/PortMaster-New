local AtlasText = SpriteGroup:extend("AtlasText")
local AtlasChar = require "funkin.ui.atlaschar"

AtlasText.defaultFont = paths.getJSON("data/fonts/default")
AtlasText.tabSize = 2
AtlasText.lineSize = 70
AtlasText.spaceWidth = 40

function AtlasText.getFont(font, size)
	font = paths.getJSON("data/fonts/" .. font)
	if font == nil then
		return AtlasText.defaultFont
	end

	if size ~= nil then font.scale = size end
	font.scale = font.scale or 1
	font.lineSize = font.lineSize or AtlasText.lineSize
	font.spaceWidth = font.spaceWidth or AtlasText.spaceWidth
	return font
end

function AtlasText:new(x, y, text, font, limit, align)
	Object.new(self, x or 0, y or 0)

	self.text = text or ""
	self.limit = limit or 0
	self.align = align or "left"
	self.italic = false

	self.lines = {}

	self.group = Group()
	self.members = self.group.members

	self:setTyping(0)
	self:setFont(font)

	self.batch = love.graphics.newSpriteBatch(
		self.frames.texture, 1, "stream")

	self.oldProps = {
		text  = self.text, align = self.align,
		limit = self.limit, font = self.font
	}
end

function AtlasText:add(o)
	if not o.is or not o:is(AtlasChar) then
		local format = 'Expected AtlasChar object, got %s. Ignoring'
		print(string.format(format, tostring(o)))
		return
	end
	AtlasText.super.add(self, o)
end

function AtlasText:setTyping(speed, sound)
	self.typed = speed > 0
	self.__target, self.timer, self.index = self.text, 0, 0
	self.sound, self.speed, self.completeCallback = sound, speed, nil
	self.finished = not self.typed
	if self.typed then self.text = "" end
end

function AtlasText:setFont(font, size)
	if (font and self.font == font) and (size and self.size == size) then
		return
	end
	font = font or self.font or AtlasText.defaultFont
	self.font = type(font) == "string" and
		AtlasText.getFont(font, size) or font

	self.frames = paths.getSparrowAtlas('fonts/' .. self.font.name)
	if self.batch then self.batch:setTexture(self.frames.texture) end

	self:setText()
end

function AtlasText:setText(text)
	self:cleanup()

	if text ~= nil then self.text = text end
	local font = self.font
	if font == nil then return end

	local line, width, cache, idx = "", 0, {}, 1

	for _, char in ipairs(self.text:split()) do
		local c = self:_makeChar(char)
		cache[idx] = c
		idx = idx + (char ~= "\n" and 1 or 0)

		if char == "\n" or (self.limit > 0 and width + c.width >= self.limit) then
			table.insert(self.lines, {t = line, w = width})
			line = char == "\n" and "" or char
			width = char == "\n" and 0 or c.width
		else
			line = line .. char
			width = width + c.width
		end
	end
	if #line > 0 then table.insert(self.lines, {t = line, w = width}) end

	idx = 1
	for i, curLine in ipairs(self.lines) do
		local x, xOff, y = 0, 0, (i - 1) * (font.lineSize * font.scale)
		if self.align ~= "left" then
			xOff = (self.limit - curLine.w) / (self.align == "center" and 2 or 1)
		end

		for _ = 1, #curLine.t do
			local char = cache[idx]; idx = idx + 1
			if char.is then
				char:setPosition(x + xOff, y)
				self:add(char)
			end
			x = x + char.width
		end
	end

	self:updateHitbox()
end

function AtlasText:hasChanged(props)
	for _, k in pairs(props) do
		if self.oldProps[k] ~= self[k] then
			self.oldProps[k] = self[k]
			return true
		end
	end
	return false
end

function AtlasText:update(dt)
	if self:hasChanged({"text", "align", "limit", "font"}) then
		self:setFont()
	end

	if not self.typed then
		return AtlasText.super.update(self, dt)
	end

	if self.typed and not self.finished then
		self.timer = self.timer + dt
		if self.timer >= self.speed then
			self:addLetter()
		end

		if self.index == #self.__target then
			self.finished = true
			if self.completeCallback then self.completeCallback() end
		end
	end

	AtlasText.super.update(self, dt)
end

function AtlasText:forceEnd()
	if not self.typed then return end

	self.text = self.__target
	self.finished = true
	if self.completeCallback then self.completeCallback() end
end

function AtlasText:addLetter()
	if not self.typed then return end

	self.timer = 0
	self.index = self.index + 1
	self.text = self.__target:sub(1, self.index)
	if self.sound then game.sound.play(self.sound) end
end

function AtlasText:_makeChar(char, x, y)
	if char ~= " " and char ~= "	" then
		return AtlasChar(x, y, char, self)
	else
		if char ~= "\n" then
			return {width = (self.font.spaceWidth * (char == "	" and
				AtlasText.tabSize or 1)) * self.font.scale}
		end
	end
	return nil
end

function AtlasText:__render(camera)
	if not self.batch then return end

	for _, member in ipairs(self.members) do
		member:__render(camera)
	end

	local texture = self.batch:getTexture()

	local oldState = Object.saveDrawState(texture)
	local mode = self.antialiasing and "linear" or "nearest"
	texture:setFilter(mode, mode, oldState.filter[3])

	local x, y, rad, sx, sy, ox, oy = self.x, self.y, math.rad(self.angle),
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y,
		self.origin.x, self.origin.y

	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	x, y = x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	love.graphics.setColor(Color.vec4(self.color, self.alpha))
	love.graphics.setBlendMode(self.blend)
	love.graphics.setShader(self.shader)

	love.graphics.draw(self.batch, x, y, rad, sx, sy, ox, oy)

	Object.loadDrawState(oldState)
end

function AtlasText:cleanup()
	for i = #self.members, 1, -1 do
		local char = self.members[i]
		char:destroy()
		self:remove(char)
	end
	if self.batch then self.batch:clear() end
	self.lines = {}
end

function AtlasText:destroy()
	self:cleanup()
	if self.batch then self.batch:release() end
	self.batch = nil
	AtlasText.super.destroy(self)
end

function AtlasText:isOnScreen(...) return Object.isOnScreen(self, ...) end

function AtlasText:_isOnScreen(...) return Object._isOnScreen(self, ...) end

function AtlasText:_canDraw() return #self.members > 0 and Object._canDraw(self) end

function AtlasText:_prepareCameraDraw() end

function AtlasText:__drawNestGroup() end

function AtlasText:__tostring() return self.text end

-- moved getWidth/Height stuff to updateHitbox, because it's called
-- less times, what should have a minimal preformance hit for huge texts
function AtlasText:updateHitbox()
	if not next(self.members) then return 0 end

	local xmin, xmax, ymin, ymax = self:__getNestDimension(self.members)
	self.width, self.height = xmax - xmin, ymax - ymin
	local sx, sy = self.scale.x * self.zoom.x, self.scale.y * self.zoom.y
	self.width, self.height = self.width * sx, self.height * sy

	self:centerOffsets()
	self:centerOrigin()
end

function AtlasText:getWidth() return self.width end

function AtlasText:getHeight() return self.height end

return AtlasText
