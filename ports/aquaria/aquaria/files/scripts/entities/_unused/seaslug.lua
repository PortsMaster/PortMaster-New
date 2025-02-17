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

-- ================================================================================================
-- S E A  S L U G
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.fireDelay = 2
v.moveTimer = 0
v.shellOff = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init()
	setupBasicEntity(
	"seaslug",						-- texture
	15,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	64,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initPart(
	"Shell", 
	"seaslug-shell",
	22,
	-10,
	1,
	0, 
	0)

	
	entity_clampToSurface()
end

function update(dt)
	-- dt, pixelsPerSecond, climbHeight, outfromwall
	entity_moveAlongSurface(dt, 80, 6, 24)
	-- entity_rotateToSurfaceNormal(0.1)
	v.moveTimer = v.moveTimer + dt*80
	if v.moveTimer > 800 then
		entity_flipHorizontal()
		entity_switchSurfaceDirection()
		v.moveTimer = 0
	end
	if v.shellOff==0 and entity_getHealth() < 10 then
		v.shellOff = 1
		entity_partAlpha("Shell", 0, 1)
	end
	if not(entity_hasTarget()) then
		entity_findTarget(1200)
	else
		if entity_isTargetInRange(64) then
			entity_pushTarget(500)
			entity_hurtTarget(1)
		end
		if v.shellOff==1 then
			if v.fireDelay > 0 then
				v.fireDelay = v.fireDelay - dt
				if v.fireDelay < 0 then
					-- FIXME: obsolete function
					-- dmg, mxspd, homing, numsegs, out
					--entity_fireAtTarget(1, 400, 200, 3, 64)
					v.fireDelay = 2
				end
			end
		end
	end
end

function enterState()
	if entity_getState()==STATE_IDLE then
	end
end

function exitState()
end

function hitSurface()
end
