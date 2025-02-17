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

-- LIGHT CRYSTAL

v.charge = 0
v.delay = 1
v.glow = 0

function init(me)
	setupEntity(me)
	
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setProperty(me, EP_MOVABLE, true)
	entity_setCollideRadius(me, 32)
	entity_setWeight(me, 300)
	
	entity_setMaxSpeed(me, 450)
	
	entity_setEntityType(me, ET_NEUTRAL)
	
	entity_initSkeletal(me, "LightCrystal")
	entity_animate(me, "idle", -1)
	v.bone_glow = entity_getBoneByName(me, "Glow")
	bone_alpha(v.bone_glow, 0)
	v.glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(v.glow, 6, 6)
	quad_alpha(v.glow, 0)
end

function update(me, dt)
	entity_updateMovement(me, dt)
	entity_updateCurrents(me)
	quad_setPosition(v.glow, entity_getPosition(me))
end

function enterState(me)
	if entity_isState(me, STATE_CHARGED) then
		quad_alpha(v.glow, 1)
		bone_alpha(v.bone_glow, 1)
	elseif entity_isState(me, STATE_CHARGE) then
		quad_alpha(v.glow, 1, 1.5)
		bone_alpha(v.bone_glow, 1, 1.5)
		playSfx("SunForm")
	elseif entity_isState(me, STATE_DEAD) then
		quad_delete(v.glow)
	end
end

function exitState(me)
end

function hitSurface(me)
	--entity_sound(me, "rock-hit")
end

function damage(me, attacker, bone, damageType, dmg)	
	return false
end

function activate(me)
end
