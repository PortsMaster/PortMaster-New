local parseXml = loxreq "lib.xml"

local function sortFramesByIndices(prefix, postfix)
	local s, e = #prefix + 1, - #postfix - 1
	return function(a, b)
		return string.sub(a.name, s, e) < string.sub(b.name, s, e)
	end
end

local stencilSprite, stencilX, stencilY = nil, 0, 0
local function stencil()
	if stencilSprite then
		love.graphics.push()
		love.graphics.translate(stencilX + stencilSprite.clipRect.x +
			stencilSprite.clipRect.width / 2,
			stencilY + stencilSprite.clipRect.y +
			stencilSprite.clipRect.height / 2)
		love.graphics.rotate(stencilSprite.angle)
		love.graphics.translate(-stencilSprite.clipRect.width / 2,
			-stencilSprite.clipRect.height / 2)
		love.graphics.rectangle("fill", -stencilSprite.width / 2,
			-stencilSprite.height / 2,
			stencilSprite.clipRect.width,
			stencilSprite.clipRect.height)
		love.graphics.pop()
	end
end

---@class Sprite:Object
local Sprite = Object:extend("Sprite")

function Sprite.newFrame(name, x, y, w, h, sw, sh, ox, oy, ow, oh)
	local aw, ah = x + w, y + h
	return {
		name = name,
		quad = love.graphics.newQuad(x, y, aw > sw and w - (aw - sw) or w,
			ah > sh and h - (ah - sh) or h, sw, sh),
		width = ow == nil and w or ow,
		height = oh == nil and h or oh,
		offset = {x = ox == nil and 0 or ox, y = oy == nil and 0 or oy}
	}
end

function Sprite.getFramesFromSparrow(texture, description)
	if type(texture) == "string" then
		texture = love.graphics.newImage(texture)
	end

	local frames = {texture = texture, frames = {}}
	local sw, sh = texture:getDimensions()
	for _, c in ipairs(parseXml(description).TextureAtlas.children) do
		if c.name == "SubTexture" then
			table.insert(frames.frames,
				Sprite.newFrame(c.attrs.name, tonumber(c.attrs.x),
					tonumber(c.attrs.y),
					tonumber(c.attrs.width),
					tonumber(c.attrs.height), sw, sh,
					tonumber(c.attrs.frameX),
					tonumber(c.attrs.frameY),
					tonumber(c.attrs.frameWidth),
					tonumber(c.attrs.frameHeight)))
		end
	end

	return frames
end

function Sprite.getFramesFromPacker(texture, description)
	if type(texture) == "string" then
		texture = love.graphics.newImage(texture)
	end

	local frames = {texture = texture, frames = {}}
	local sw, sh = texture:getDimensions()

	local pack = description:trim()
	local lines = pack:split("\n")
	for i = 1, #lines do
		local currImageData = lines[i]:split("=")
		local name = currImageData[1]:trim()
		local currImageRegion = currImageData[2]:split(" ")

		table.insert(frames.frames,
			Sprite.newFrame(name, tonumber(currImageRegion[1]),
				tonumber(currImageRegion[2]),
				tonumber(currImageRegion[3]),
				tonumber(currImageRegion[4]), sw, sh))
	end

	return frames
end

function Sprite.getTiles(texture, tileSize, region, tileSpacing)
	if region == nil then
		region = {
			x = 0,
			y = 0,
			width = texture:getWidth(),
			height = texture:getHeight()
		}
	else
		if region.width == 0 then
			region.width = texture:getWidth() - region.x
		end
		if region.height == 0 then
			region.height = texture:getHeight() - region.y
		end
	end

	tileSpacing = (tileSpacing ~= nil) and tileSpacing or {x = 0, y = 0}

	local tileFrames = {}

	region.x = math.floor(region.x)
	region.y = math.floor(region.y)
	region.width = math.floor(region.width)
	region.height = math.floor(region.height)
	tileSpacing = {x = math.floor(tileSpacing.x), y = math.floor(tileSpacing.y)}
	tileSize = {x = math.floor(tileSize.x), y = math.floor(tileSize.y)}

	local spacedWidth = tileSize.x + tileSpacing.x
	local spacedHeight = tileSize.y + tileSpacing.y

	local numRows = (tileSize.y == 0) and 1 or
		math.floor(
			(region.height + tileSpacing.y) / spacedHeight)
	local numCols = (tileSize.x == 0) and 1 or
		math.floor((region.width + tileSpacing.x) / spacedWidth)

	local sw, sh = texture:getDimensions()
	local totalFrame = 0
	for j = 0, numRows - 1 do
		for i = 0, numCols - 1 do
			table.insert(tileFrames,
				Sprite.newFrame(tostring(totalFrame),
					region.x + i * spacedWidth,
					region.y + j * spacedHeight,
					tileSize.x, tileSize.y, sw, sh))
			totalFrame = totalFrame + 1
		end
	end

	return tileFrames
end

function Sprite:new(x, y, texture)
	Sprite.super.new(self, x, y)

	self.texture = Sprite.defaultTexture

	self.clipRect = nil

	self.curAnim = nil
	self.curFrame = nil
	self.animFinished = nil
	self.animPaused = false

	self.__frames = nil
	self.__animations = nil

	self.__width, self.__height = self.width, self.height

	if texture then self:loadTexture(texture) end
end

function Sprite:destroy()
	Sprite.super.destroy(self)

	self.texture = nil

	self.__frames = nil
	self.__animations = nil

	self.curAnim = nil
	self.curFrame = nil
	self.animFinished = nil
	self.animPaused = false
end

function Sprite:loadTexture(texture, animated, frameWidth, frameHeight)
	if animated == nil then animated = false end

	if type(texture) == "string" then
		texture = love.graphics.newImage(texture)
	end
	self.texture = texture or Sprite.defaultTexture

	self.curAnim = nil
	self.curFrame = nil
	self.animFinished = nil

	if frameWidth == nil then frameWidth = 0 end
	if frameWidth == 0 then
		frameWidth = animated and self.texture:getHeight() or
			self.texture:getWidth()
		frameWidth = (frameWidth > self.texture:getWidth()) or
			self.texture:getWidth() or frameWidth
	elseif frameWidth > self.texture:getWidth() then
		print('frameWidth: ' .. frameWidth ..
			' is larger than the graphic\'s width: ' ..
			self.texture:getWidth())
	end
	self.width = frameWidth

	if frameHeight == nil then frameHeight = 0 end
	if frameHeight == 0 then
		frameHeight = animated and frameWidth or self.texture:getHeight()
		frameHeight = (frameHeight > self.texture:getHeight()) or
			self.texture:getHeight() or frameHeight
	elseif frameHeight > self.texture:getHeight() then
		print('frameHeight: ' .. frameHeight ..
			' is larger than the graphic\'s height: ' ..
			self.texture:getHeight())
	end
	self.height = frameHeight

	self.__width, self.__height = self.width, self.height

	if animated then
		self.__frames = Sprite.getTiles(texture,
			{x = frameWidth, y = frameHeight})
	end

	return self
end

function Sprite:loadTextureFromSprite(sprite)
	self.texture = sprite.texture

	self.antialiasing = sprite.antialiasing

	self.curAnim = nil
	self.curFrame = nil
	self.animFinished = nil

	self.width, self.height = sprite.width, sprite.height
	self.__width, self.__height = self.width, self.height

	if sprite.__frames ~= nil then
		self.__frames = table.clone(sprite.__frames)
	end

	return self
end

function Sprite:addAnim(name, frames, framerate, looped)
	if not frames or #frames == 0 then return end

	if framerate == nil then framerate = 30 end
	if looped == nil then looped = true end

	local anim = {
		name = name,
		framerate = framerate,
		looped = looped,
		frames = {}
	}
	for _, i in ipairs(frames) do
		table.insert(anim.frames, self.__frames[i + 1])
	end

	if not self.__animations then self.__animations = {} end
	self.__animations[name] = anim
end

function Sprite:addAnimByPrefix(name, prefix, framerate, looped)
	if framerate == nil then framerate = 30 end
	if looped == nil then looped = true end

	local anim, foundFrame = {
		name = name,
		framerate = framerate,
		looped = looped,
		frames = {}
	}, false
	for _, f in ipairs(self.__frames) do
		if f.name:startsWith(prefix) then
			foundFrame = true
			table.insert(anim.frames, f)
		end
	end
	if not foundFrame then return end

	table.sort(anim.frames, sortFramesByIndices(prefix, ""))

	if not self.__animations then self.__animations = {} end
	self.__animations[name] = anim
end

function Sprite:addAnimByIndices(name, prefix, indices, postfix, framerate,
								 looped)
	if postfix == nil then postfix = "" end
	if framerate == nil then framerate = 30 end
	if looped == nil then looped = true end

	local anim = {
		name = name,
		framerate = framerate,
		looped = looped,
		frames = {}
	}

	local allFrames, foundFrame = {}, false
	local notPostfix = #postfix <= 0
	for _, f in ipairs(self.__frames) do
		if f.name:startsWith(prefix) and
			(notPostfix or f.name:endsWith(postfix)) then
			foundFrame = true
			table.insert(allFrames, f)
		end
	end
	if not foundFrame then return end

	table.sort(allFrames, sortFramesByIndices(prefix, postfix))

	for _, i in ipairs(indices) do
		local f = allFrames[i + 1]
		if f then table.insert(anim.frames, f) end
	end

	if not self.__animations then self.__animations = {} end
	self.__animations[name] = anim
end

function Sprite:play(anim, force, frame)
	local curAnim = self.curAnim

	if curAnim and not force and curAnim.name == anim and
		not self.animFinished then
		self.animFinished = false
		self.animPaused = false
		return
	end

	curAnim = self.__animations[anim]
	if curAnim then
		self.curAnim = curAnim
		self.curFrame = frame or 1
		self.animFinished = false
		self.animPaused = false
	end
end

function Sprite:pause()
	if self.curAnim and not self.animFinished then self.animPaused = true end
end

function Sprite:resume()
	if self.curAnim and not self.animFinished then self.animPaused = false end
end

function Sprite:stop()
	if self.curAnim then
		self.animFinished = true
		self.animPaused = true
	end
end

function Sprite:finish()
	if self.curAnim then
		self:stop()
		self.curFrame = #self.curAnim.frames
	end
end

function Sprite:setFrames(frames)
	self.__frames = frames.frames
	self.texture = frames.texture

	self:loadTexture(frames.texture)
	self.width, self.height = self:getFrameDimensions()
	self.__width, self.__height = self.width, self.height
	self:centerOrigin()
end

function Sprite:getCurrentFrame()
	if self.curAnim then
		return self.curAnim.frames[math.floor(self.curFrame)]
	elseif self.__frames then
		return self.__frames[1]
	end
	return nil
end

function Sprite:getFrameWidth()
	local f = self:getCurrentFrame()
	return f and f.width or self.texture and self.texture:getWidth()
end

function Sprite:getFrameHeight()
	local f = self:getCurrentFrame()
	return f and f.height or self.texture and self.texture:getHeight()
end

function Sprite:getFrameDimensions()
	return self:getFrameWidth(), self:getFrameHeight()
end

function Sprite:getGraphicMidpoint()
	return self.x + self:getFrameWidth() / 2,
		self.y + self:getFrameHeight() / 2
end

function Sprite:setGraphicSize(width, height)
	if width == nil then width = 0 end
	if height == nil then height = 0 end

	self.scale.x = width / self:getFrameWidth()
	self.scale.y = height / self:getFrameHeight()

	if width <= 0 then
		self.scale.x = self.scale.y
	elseif height <= 0 then
		self.scale.y = self.scale.x
	end
end

function Sprite:updateHitbox()
	local width, height = self:getFrameDimensions()

	self.width = math.abs(self.scale.x * self.zoom.x) * width
	self.height = math.abs(self.scale.y * self.zoom.y) * height
	self.__width, self.__height = self.width, self.height

	self:fixOffsets(width, height)
	self:centerOrigin(width, height)
end

function Sprite:centerOffsets(width, height)
	self.offset.x = (width or self:getFrameWidth()) / 2
	self.offset.y = (height or self:getFrameHeight()) / 2
end

function Sprite:fixOffsets(width, height)
	self.offset.x = (self.width - (width or self:getFrameWidth())) / -2
	self.offset.y = (self.height - (height or self:getFrameHeight())) / -2
end

function Sprite:centerOrigin(width, height)
	self.origin.x = (width or self:getFrameWidth()) / 2
	self.origin.y = (height or self:getFrameHeight()) / 2
end

function Sprite:update(dt)
	if self.__width ~= self.width or self.__height ~= self.height then
		self:setGraphicSize(self.width, self.height)
		self.__width, self.__height = self.width, self.height
	end

	if self.curAnim and not self.animFinished and not self.animPaused then
		self.curFrame = self.curFrame + dt * self.curAnim.framerate
		if self.curFrame >= #self.curAnim.frames + 1 then
			if self.curAnim.looped then
				self.curFrame = 1
			else
				self.curFrame = #self.curAnim.frames
				self.animFinished = true
			end
		end
	end

	if self.moves then
		self.velocity.x = self.velocity.x + self.acceleration.x * dt
		self.velocity.y = self.velocity.y + self.acceleration.y * dt

		self.x = self.x + self.velocity.x * dt
		self.y = self.y + self.velocity.y * dt
	end
end

function Sprite:_canDraw()
	return self.texture ~= nil and (self.width ~= 0 or self.height ~= 0) and
		Sprite.super._canDraw(self)
end

function Sprite:__render(camera)
	local r, g, b, a = love.graphics.getColor()
	local shader = self.shader and love.graphics.getShader()
	local blendMode, alphaMode = love.graphics.getBlendMode()
	local min, mag, anisotropy, mode

	mode = self.antialiasing and "linear" or "nearest"
	min, mag, anisotropy = self.texture:getFilter()
	self.texture:setFilter(mode, mode, anisotropy)

	local f = self:getCurrentFrame()

	local x, y, rad, sx, sy, ox, oy = self.x, self.y, math.rad(self.angle),
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y,
		self.origin.x, self.origin.y

	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	x, y = x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	if f then ox, oy = ox + f.offset.x, oy + f.offset.y end

	love.graphics.setShader(self.shader); love.graphics.setBlendMode(self.blend)
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)

	if self.clipRect then
		stencilSprite, stencilX, stencilY = self, x, y
		love.graphics.stencil(stencil, "replace", 1, false)
		love.graphics.setStencilTest("greater", 0)
	end

	if f then
		love.graphics.draw(self.texture, f.quad, x, y, rad, sx, sy, ox, oy)
	else
		love.graphics.draw(self.texture, x, y, rad, sx, sy, ox, oy)
	end

	self.texture:setFilter(min, mag, anisotropy)

	love.graphics.setColor(r, g, b, a)
	love.graphics.setBlendMode(blendMode, alphaMode)
	if shader then love.graphics.setShader(shader) end
	if self.clipRect then love.graphics.setStencilTest() end
end

return Sprite
