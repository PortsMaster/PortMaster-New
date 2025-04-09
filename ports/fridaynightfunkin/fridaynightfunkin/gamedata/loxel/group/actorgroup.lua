---@class ActorGroup:Sprite
local ActorGroup = ActorSprite:extend("ActorGroup")
ActorGroup:implement(SpriteGroup)

function ActorGroup:new(x, y, z, affect)
	ActorGroup.super.new(self, x, y, z)

	self.memberScales = {x = 1, y = 1, z = 1}
	self.memberRotations = {x = 0, y = 0, z = 0}
	self.memberAngles = 0

	self.group = Group()
	self.members = self.group.members

	self.__unusedCameraRenderQueue = {}
	self.__cameraRenderQueue = {}

	self:_initializeDrawFunctions()

	if affect == nil then affect = true end
	self.affectAngle = affect
	self.affectScale = affect
end

function ActorGroup:__drawNestGroup(members, camera, list, x2, y2, sf, force, zoomx, zoomy)
	for _, member in ipairs(members) do
		local sf2, px, py, sfx, sfy = member.scrollFactor, member.x, member.y
		if px then
			member.x, member.y = px + x2, py + y2
		end
		if sf2 then
			sfx, sfy = sf2.x, sf2.y
			sf2.x, sf2.y = sfx * sf.x, sfy * sf.y
		end

		if member.__cameraRenderQueue then
			if ActorSprite.super._canDraw(member) and next(member:_prepareCameraDraw(camera, force)) then
				table.insert(list, member)
			end
		elseif member:_canDraw() then
			if member.__render then
				local x, y, w, h, sx, sy, ox, oy = member:_getBoundary()

				if member:_isOnScreen(x, y, w, h, sx, sy, ox, oy,
						sf2 and sf2.x or 1, sf2 and sf2.y or 1, camera)
				then
					table.insert(list, member)
				end
			elseif member.members then
				self:__drawNestGroup(member.members, camera, list,
					(member.x or x2), (member.y or y2), (sf2 or sf), force, zoomx, zoomy)
			end
		end

		member.x, member.y = px, py
		if sf2 then
			sf2.x, sf2.y = sfx, sfy
		end
	end
end

local tempScales, tempRotations = {x = 1, y = 1, z = 1}, {x = 0, y = 0, z = 0}

function ActorGroup:__render(camera)
	local list = self.__cameraRenderQueue[camera]
	if not list then return end

	local cr, cg, cb, ca = love.graphics.getColor()
	self.__ogSetColor, love.graphics.setColor = love.graphics.setColor, self.__setColor

	local x, y, z, ox, oy, oz, rx, ry, rz, angle, sx, sy, sz, mmsx, mmsy, mmsz, mmrx, mmry, mmrz, mma,
	affectAngle, affectScale =
		self.x + self.offset.x,
		self.y + self.offset.y,
		self.z + self.offset.z,
		self.origin.x, self.origin.y, self.origin.z,
		self.rotation.x, self.rotation.y, self.rotation.z, self.angle,
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y, self.scale.z * self.zoom.z,
		self.memberScales.x, self.memberScales.y, self.memberScales.z,
		self.memberRotations.x, self.memberRotations.y, self.memberRotations.z, self.memberAngles,
		self.affectAngle, self.affectScale

	local a, b = camera.scroll, self.scrollFactor
	for i, member in ipairs(list) do
		if not member.ignoreAffectByGroup then -- i made it too comp[licated] im sorryy :sob:
			local mrot, msc, mmmr, mmms = member.rotation or tempRotations, member.scale or tempScales,
				member.memberRotations, member.memberScales

			local px, py, pz, pa, psx, psy, psz, pma, prx, pry, prz, pmsx, pmsy, pmsz, pmrx, pmry, pmrz =
				member.x or 0, member.y or 0, member.z or 0, member.angle or 0, msc.x, msc.y, msc.z, member.memberAngles

			local vx, vy, vz = Actor.worldSpin(px * sx, py * sy, pz * sz, rx, ry, rz, ox, oy, oz)
			member.x, member.y, member.z =
				vx + x + (a.x * member.scrollFactor.x * (1 - b.x)),
				vy + y + (a.y * member.scrollFactor.y * (1 - b.y)),
				vz + z

			if mmmr then
				pmrx, pmry, pmrz = mmmr.x, mmmr.y, mmmr.z
				mmmr.x, mmmr.y, mmmr.z = pmrx + mmrx, pmry + mmry, pmrz + mmrz
			end
			if pma then
				member.memberAngles = pma + mma
			else
				member.angle = pa + mma
			end
			if affectAngle then
				if mrot then
					prx, pry, prz = mrot.x, mrot.y, mrot.z
					mrot.x, mrot.y, mrot.z = prx + rx, pry + ry, prz + rz
				end
				member.angle = member.angle + angle
			end
			if not mmmr and mrot then
				if not prx then prx, pry, prz = mrot.x, mrot.y, mrot.z end
				mrot.x, mrot.y, mrot.z = mrot.x + mmrx, mrot.y + mmry, mrot.z + mmrz
			end

			if mmms then
				pmsx, pmsy, pmsz = mmms.x, mmms.y, mmms.z
				mmms.x, mmms.y, mmms.z = pmsx * mmsx, pmsy * mmsy, pmsz * mmsz
			else
				msc.x, msc.y, msc.z = psx * mmsx, psy * mmsy, psz * mmsz
			end
			if affectScale then
				msc.x, msc.y, msc.z = msc.x * sx, msc.y * sy, msc.z * sz
			end

			member:__render(camera)

			member.x, member.y, member.z, member.memberAngles = px, py, pz, pma
			if mmmr then mmmr.x, mmmr.y, mmmr.z = pmrx, pmry, pmrz end
			if prx then mrot.x, mrot.y, mrot.z = prx, pry, prz end
			if pa then
				member.angle = pa
			end
			if mmms then mmms.x, mmms.y, mmms.z = pmsx, pmsy, pmsz end
			msc.x, msc.y, msc.z = psx, psy, psz
		else
			member:__render(camera)
		end

		list[i] = nil
	end
	self.__cameraRenderQueue[camera] = nil
	table.insert(self.__unusedCameraRenderQueue, list)

	love.graphics.setColor = self.__ogSetColor
	self.__ogSetColor(cr, cg, cb, ca)
end

function ActorGroup:screenCenter(axes)
	self:getWidth()
	return ActorGroup.super.screenCenter(self, axes)
end

function ActorGroup:loadTexture() return self end

ActorGroup.updateHitbox = SpriteGroup.updateHitbox
ActorGroup.centerOffsets = SpriteGroup.centerOffsets
ActorGroup.fixOffsets = SpriteGroup.fixOffsets
ActorGroup.centerOrigin = SpriteGroup.centerOrigin
ActorGroup.loadTexture = SpriteGroup.loadTexture
ActorGroup.isOnScreen = SpriteGroup.isOnScreen
ActorGroup.update = SpriteGroup.update
ActorGroup._isOnScreen = SpriteGroup._isOnScreen
ActorGroup._canDraw = SpriteGroup._canDraw
ActorGroup.kill = SpriteGroup.kill
ActorGroup.revive = SpriteGroup.revive
ActorGroup.destroy = SpriteGroup.destroy

return ActorGroup
