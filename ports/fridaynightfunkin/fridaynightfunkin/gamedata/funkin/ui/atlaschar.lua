local AtlasChar = Sprite:extend("AtlasChar")

function AtlasChar:new(x, y, char, parent)
	AtlasChar.super.new(self, x or 0, y or 0)

	self.char = char or "#"
	self.parent = parent

	self:setFont()
end

function AtlasChar:setFont()
	local font = self.parent.font or AtlasText.defaultFont
	self:setFrames(self.parent.frames)

	self:updateHitbox()
	self:setGraphicSize(self.width * (font.scale))
	self:updateHitbox()

	self.antialiasing = font.antialiasing ~= nil and
		font.antialiasing or true

	self:setChar()
end

function AtlasChar:setChar(letter)
	self.char = letter or self.char

	local font = self.parent.font
	local ox, oy = font.offsets and font.offsets[1] or 0,
		font.offsets and font.offsets[2] or 0

	self.char = font.noUpper and self.char:lower() or
		(font.noLower and self.char:upper() or self.char)

	if font.characters then
		for _, char in ipairs(font.characters) do
			if char[1] == self.char then
				self.char = char[2]
				if char[3] then
					ox, oy = ox - char[3][1], oy - char[3][2]
				end
				break
			end
		end
	end

	local framerate = font.framerate or 24
	local looped = font.looped ~= nil and font.looped or true

	self:addAnimByPrefix(self.char, self.char, framerate, looped)
	if self.__animations and self.__animations[self.char] then
		self:play(self.char)
	end
	self:updateHitbox()

	local scale = (font.scale and font.scale or 1)
	ox, oy = ox, (oy - (110 - self.height)) * scale
	self.offset = {x = ox, y = oy}
end

function AtlasChar:__render(camera)
	local batch = self.parent and self.parent.batch
	if not batch then return end
	batch:setColor(Color.vec4(self.color, self.alpha))

	local f = self:getCurrentFrame()
	local x, y, rad, sx, sy, ox, oy = self.x, self.y, math.rad(self.angle),
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y,
		self.origin.x, self.origin.y
	local s = (self.parent and self.parent.italic) and -0.2 or 0

	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	if font and font.scale then sx, sy = sx * font.scale, sy * font.scale end

	x, y = x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	if f then
		ox, oy = ox + f.offset.x, oy + f.offset.y
		if not self.batchIdx then
			self.batchIdx = batch:add(f.quad, x, y, rad, sx, sy, ox, oy, s)
		else
			batch:set(self.batchIdx, f.quad, x, y, rad, sx, sy, ox, oy, s)
		end
	end
end

function AtlasChar:destroy()
	AtlasChar.super.destroy(self)
	if self.parent and self.parent.batch and self.batchIdx then
		self.parent.batch:set(self.batchIdx, 0, 0, 0, 0, 0, 0, 0)
	end
	self.parent = nil
end

return AtlasChar
