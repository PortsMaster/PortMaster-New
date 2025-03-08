-- Copyright (C) 2007, 2010 - Bit-Blot
--
-- This file is part of Aquaria.
--
-- Aquaria is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.n = 0

v.off = 0
v.glow = 0
v.flag = 0

v.sz = 0.7
v.nqtimer = 0
v.noteQuad = 0
v.delay = 0

v.boneGroup = nil

v.noteBone = 0
v.spinDir = 1

v.index = 0

local function boneGroupAlpha(a, t)
	for i=1,14 do
		bone_alpha(v.boneGroup[i], a, t, 0, 0, 1)
	end
end

function v.commonInit(me, skel, num, f, r, g, b)
	v.boneGroup = {}

	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, skel)
	
	entity_setEntityLayer(me, 1)
	
	entity_setState(me, STATE_FIGURE)
	entity_scale(me, v.sz, v.sz)
	v.off = 6.28*(num*0.25)
	
	v.body = entity_getBoneByName(me, "Body")
		
	v.glow = entity_getBoneByName(me, "Glow")
	v.noteBone = entity_getBoneByName(me, "Note")
	
	bone_setVisible(v.glow, true)
	bone_setVisible(v.noteBone, true)
	
	bone_alpha(v.noteBone)
	bone_setBlendType(v.glow, BLEND_ADD)
	bone_scale(v.glow, 4, 4)
	bone_scale(v.glow, 8, 8, 0.5, -1, 1, 1)
	
	bone_setColor(v.glow, r*0.5 + 0.5, g*0.5 + 0.5, b*0.5 + 0.5)
	
	bone_setAnimated(v.noteBone, ANIM_POS)
	bone_setAnimated(v.glow, ANIM_POS)
	
	loadSound("Spirit-Awaken")
	loadSound("Spirit-Join")
	
	v.flag = f
	
	v.index = num
	--[[
	for i=0,13 do
		v.boneGroup[i+1] = entity_getBoneByIndex(me, i)
	end
	]]--
	
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

v.incut=false
function update(me, dt)
	
	if v.nqtimer > 0 then
		v.nqtimer = v.nqtimer - dt
		if v.nqtimer <= 0 then
		end
	end
	--entity_updateMovement(me, dt)
	if entity_isState(me, STATE_FIGURE) then
		if v.incut then return end
		if entity_isEntityInRange(me, v.n, 256) then
			v.incut = true
			entity_setInvincible(v.n, true)
			entity_idle(v.n)
			entity_flipToEntity(v.n, me)
			cam_toEntity(me)
			watch(2)
			
			if v.index == 0 then
				voice("Naija_SpiritKrotite")
			elseif v.index == 1 then
				voice("Naija_SpiritMithalas")
			elseif v.index == 2 then
				voice("Naija_SpiritDruniad")
			elseif v.index == 3 then
				voice("Naija_SpiritErulian")
			end
			watchForVoice()
			
			spawnParticleEffect("SpiritBeacon", entity_x(v.n), entity_y(v.n))
			playSfx("Spirit-Beacon")
			watch(0.4)
			
			spawnParticleEffect("SpiritBeacon", entity_x(me), entity_y(me))
			playSfx("Spirit-Beacon")
			watch(1)
			
			entity_alpha(me, 1, 2)
		
			watch(0.5)
			playSfx("Spirit-Awaken")
			watch(1.25)
			entity_rotate(me, 0, 1, 0, 0, 1)
			entity_setState(me, STATE_IDLE)
			watch(2)
			watch(1)
			bone_alpha(v.glow, 1, 1, 0, 0, 1)
			watch(1)
			playSfx("Spirit-Join")
			entity_setState(me, STATE_FOLLOW)
			setFlag(v.flag, 1)
			watch(2)
			cam_toEntity(v.n)
			if isFlag(FLAG_SPIRIT_DRASK, 1)
			and isFlag(FLAG_SPIRIT_ERULIAN, 1)
			and isFlag(FLAG_SPIRIT_KROTITE, 1)
			and isFlag(FLAG_SPIRIT_DRUNIAD, 1) then
				voice("Naija_FourSpirits")
				watch(2)
			end
			entity_setInvincible(v.n, false)
			v.incut=false
		end
	end
	if entity_isState(me, STATE_FOLLOW) then
		local dist = 400
		local t = 0
		local x = 0
		local y = 0
		if avatar_isRolling() then
			dist = 250
			v.spinDir = -avatar_getRollDirection()
			t = getTimer(6.28)*v.spinDir
		else
			t = getHalfTimer(6.28)*v.spinDir
		end
		
		if isForm(FORM_ENERGY) then
			dist = dist - 100
		end
		
		--[[
		if avatar_isBursting() then
			x = entity_velx(v.n)
			y = entity_vely(v.n)
			x, y = vector_setLength(x, y, 512)
		end
		]]--
		
		local a = t + v.off
		x = x + math.sin(a)*dist
		y = y + math.cos(a)*dist
		entity_setPosition(me, entity_x(v.n)+x, entity_y(v.n)+y, 0.2)
		
		--[[
		v.delay = v.delay - dt
		if v.delay < 0 then
			local s = createShot("FinalSpirit", me, 0, entity_x(me), entity_y(me))
			v.delay = 0.1
		end
		]]--
	end
	
	if v.noteQuad ~= 0 then
		quad_setPosition(v.noteQuad, entity_x(me), entity_y(me))
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_FIGURE) then
		entity_scale(me, v.sz, v.sz, 1)
		esetv(me, EV_LOOKAT, 1)
		--boneGroupAlpha(1, 1)
		bone_alpha(v.glow, 0, 1, 0, 0, 1)
		entity_alpha(me, 0.2, 1, 0, 0, 1)
		entity_animate(me, "figure", -1)
	elseif entity_isState(me, STATE_FOLLOW) then
		entity_scale(me, 0.2, 0.2, 1)
		entity_animate(me, "ball", -1, 0, 3)
		esetv(me, EV_LOOKAT, 0)
		--boneGroupAlpha(0, 1)
		bone_alpha(v.glow, 1, 1, 0, 0, 1)
		entity_alpha(me, 1, 2, 0, 0, 1)
		bone_rotate(v.glow, 0, 1, 0, 0, 1)
		bone_rotate(v.glow, 360, 1, -1)
	end
	bone_rotate(v.noteBone, -entity_getRotation(me))
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
	local t = 1
	--v.noteQuad = createQuad(string.format("Song/NoteSymbol%d", note), 6)
	bone_setTexture(v.noteBone, string.format("Song/NoteSymbol%d", note))
	bone_alpha(v.noteBone, 0.8)
	bone_alpha(v.noteBone, 0, t)
	bone_scale(v.noteBone, 4, 4)
	bone_scale(v.noteBone, 8, 8, t, 0, 0, 1)
	bone_setColor(v.noteBone, getNoteColor(note))
	--quad_setPosition(v.noteQuad, entity_x(me), entity_y(me))
	--quad_delete(v.noteQuad, t)
	v.nqtimer = t
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

