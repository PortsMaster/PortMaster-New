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

v.curNote = -1
v.noteTimer = 0

v.delayTime = 2
v.delay = v.delayTime

v.attackDelay = 0

v.noteQuad = 0

v.holdingNote = false

v.maxHits = 6
v.hits = v.maxHits

local STATE_HURT			= 1000
local STATE_SING			= 1001

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_setTexture(me, "particles/lines")
	entity_setAllDamageTargets(me, false)
	
	entity_rotate(me, 360, 1, -1)
	
	entity_scale(me, 1.5, 1.5, 2, -1, 1, 1)

	entity_setCollideRadius(me, 32)	
	
	entity_setState(me, STATE_IDLE)
	
	entity_setBlendType(me, BLEND_ADD)
	
	
	
	for i=0,7 do
		loadSound(getNoteName(i, "low-"))
	end
	
	entity_addVel(me, randVector(500))
	
	entity_setMaxSpeed(me, 300)
	entity_alpha(me, 0)
	
	loadSound("energyboss-die")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	playSfx("spirit-enter")
	entity_alpha(me, 1, 1.5)
	
	playMusic("ancienttest")
end

function update(me, dt)
	entity_updateMovement(me, dt)
	
	entity_doCollisionAvoidance(me, dt, 10, 0.2)
	
	if entity_isState(me, STATE_IDLE) then
		v.delay = v.delay - dt
		if v.delay < 0 then
			v.delay = v.delayTime
			entity_setState(me, STATE_SING) 
		end
	end
	
	if entity_isState(me, STATE_SING) then
		if v.holdingNote then
			v.noteTimer = v.noteTimer + dt
			if v.noteTimer > 1 then
				-- hit it!
				v.holdingNote = false
				entity_setState(me, STATE_HURT)
			end
		end
		if v.noteQuad ~= 0 then
			quad_setPosition(v.noteQuad, entity_x(me), entity_y(me))
		end
	end
	
	if entity_isState(me, STATE_ATTACK) then
		entity_doEntityAvoidance(me, dt, 128, 0.2)
		v.attackDelay = v.attackDelay + (dt * (1.0-(v.hits/v.maxHits))*3)
		if v.attackDelay > 1 then
			local s = createShot("energygodspirit", me, v.n, entity_x(me), entity_y(me))
			v.attackDelay = 0
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_HURT) then
		entity_setMaxSpeedLerp(me, 4)
		entity_setMaxSpeedLerp(me, 1, 5)
		
		entity_addVel(me, randVector(500))
		
		playSfx("secret")
		playSfx("energyorbcharge")
		entity_setStateTime(me, 3)
		if v.hits == 1 then
			entity_setStateTime(me, 0.5)
		end
		v.curNote = -1
		spawnParticleEffect("energygodspirithit", entity_x(me), entity_y(me))
		entity_heal(v.n, 0.5)
		setSceneColor(0.5, 0.5, 1, 0.5)
		
		entity_setMaxSpeed(me, entity_getMaxSpeed(me)+50)
	elseif entity_isState(me, STATE_SING) then
		
		entity_setStateTime(me, 5)
		v.curNote = getRandNote()
		local r, g, b = getNoteColor(v.curNote)
		entity_color(me, r*0.9 + 0.1, g*0.9 + 0.1, b*0.9 + 0.1, 1)
		
		playSfx(getNoteName(v.curNote, "low-"))
		
		
		local t = 6
		v.noteQuad = createQuad(string.format("Song/NoteSymbol%d", v.curNote), 6)
		quad_alphaMod(v.noteQuad, 0.2)
		quad_scale(v.noteQuad, 1, 1)
		quad_scale(v.noteQuad, 3, 3, t, 0, 0, 1)
		quad_setPosition(v.noteQuad, entity_x(me), entity_y(me))
		quad_setBlendType(v.noteQuad, BLEND_ADD)
		quad_delete(v.noteQuad, t)
		
		setSceneColor(r*0.5 + 0.5, g*0.5 + 0.5, b*0.5 + 0.5, 1)
		
		shakeCamera(4, 3)
	elseif entity_isState(me, STATE_ATTACK) then
		entity_setMaxSpeedLerp(me, 4)
		entity_addVel(me, randVector(800))
		--entity_moveTowardsTarget(me, 800, 1)
		entity_setMaxSpeedLerp(me, 1, 5)
		entity_setStateTime(me, 4)
		setSceneColor(1, 0.5, 0.5, 1)
		v.attackDelay = 0
	elseif entity_isState(me, STATE_DEATHSCENE) then

	end
end

function exitState(me)
	if entity_isState(me, STATE_SING) then
		entity_color(me, 1, 1, 1, 1)
		--voice("laugh1")
		entity_setState(me, STATE_ATTACK)
		if v.noteQuad ~= 0 then
			quad_delete(v.noteQuad, 1)
			v.noteQuad = 0
		end
	elseif entity_isState(me, STATE_ATTACK) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_HURT) then
		
		
		v.hits = v.hits - 1
		
		if v.hits <= 0 then
			setFlag(FLAG_ENERGYGODENCOUNTER, 2)
			entity_damage(me, v.n, 10000)
			
			setSceneColor(1, 1, 1, 5)
			fadeOutMusic(6)
			shakeCamera(10, 4)
			cam_toEntity(me)
			shakeCamera(10, 4)
			watch(4)
			spawnParticleEffect("energygodspirithit", entity_x(me), entity_y(me))
			playSfx("energyboss-die")
			shakeCamera(15, 2)
			watch(2)
			playSfx("spirit-enter")
			shakeCamera(20, 2)
			watch(2)
			cam_toEntity(getNaija())
		
			local node = entity_getNearestNode(me, "energygodencounter")
			if node ~= 0 then
				node_activate(node)
			end
		else
			entity_setState(me, STATE_ATTACK)
		end
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
	if v.curNote == note then
		v.holdingNote = true
		v.noteTimer = 0
	end
end

function songNoteDone(me, note)
	v.holdingNote = false
end

function song(me, song)
end

function activate(me)
end

