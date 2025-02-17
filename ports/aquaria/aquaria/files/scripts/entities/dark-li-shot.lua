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
v.died = false
v.myNote = -1
v.singing = false

v.bone_note = 0

v.darkli = 0

v.singTimer = 0

v.startDelay = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "darklishot")
	entity_setAllDamageTargets(me, false)
	
	entity_setHealth(me, 1)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setDeathScene(me, true)
	
	entity_setMaxSpeed(me, 400)
	
	v.bone_note = entity_getBoneByIdx(me, 1)
	
	esetv(me, EV_TYPEID, EVT_DARKLISHOT)
	
	v.darkli = entity_getNearestEntity(me, "creatorform5")
	
	entity_setCollideRadius(me, 96)
	
	entity_scale(me, 0.8, 0.8)
	
	entity_alpha(me, 0)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if v.startDelay > 0 then
		v.startDelay = v.startDelay - dt
		
		if v.startDelay < 0 then
			entity_alpha(me, 1, 0.5)
			spawnParticleEffect("darklishot-spawn", entity_x(me), entity_y(me))
			entity_sound(me, getNoteName(v.myNote, "low-"), 1, 2)
			playSfx("hellbeast-shot")
		end
		return
	end
	
	entity_moveTowardsTarget(me, dt, 1000)

	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 100) then
		entity_damage(me, me, 1)
	else
		if v.singing then
			v.singTimer = v.singTimer + dt
			if v.singTimer > 0.1 then	
				-- die
				entity_msg(v.darkli, "died")
				entity_damage(me, me, 1)
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		local t = 2
		entity_setStateTime(me, t)
		spawnParticleEffect("", entity_x(me), entity_y(me))
		entity_scale(me, 0, 0, t)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if attacker == me then
		return true
	end
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
	if entity_getAlpha(me) > 0 then
		if note == v.myNote then
			v.singing = true
			entity_offset(me, -5, 0)
			entity_offset(me, 5, 0, 0.01, -1, 1)
		end
	end
end

function songNoteDone(me, note)
	entity_offset(me, 0, 0, 0.1)
	if note == v.myNote then
		
		v.singing = false
		v.singTimer = 0
	end
end

function song(me, song)
end

function activate(me)
end

function msg(me, msg, val)
	if msg == "note" then
		v.myNote = val
		bone_setTexture(v.bone_note, string.format("song/notesymbol%d", v.myNote))
		bone_scale(v.bone_note, 1, 1)
		bone_scale(v.bone_note, 4, 4, 0.5, -1, 1)
		bone_alpha(v.bone_note, 0.5)
		local r,g,b = getNoteColor(v.myNote)
		r = r*0.5 + 0.5
		g = g*0.5 + 0.5
		b = b*0.5 + 0.5
		bone_setColor(v.bone_note, r, g, b)
	end
	if msg == "sd" then
		v.startDelay = val
		
		if v.startDelay <= 0 then
			v.startDelay = 0.1
		end
	end
end


