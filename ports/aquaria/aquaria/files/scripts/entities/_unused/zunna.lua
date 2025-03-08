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
-- Z U N N A
-- ================================================================================================

-- entity specific
local STATE_WAIT			= 1000
local STATE_WEAK			= 1001
local STATE_ATTACKPREP		= 1002
local STATE_ATTACK			= 1003
local STATE_RANGEATTACK		= 1004


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

attackDelay = 2
rangeAttackDelay = 2
lunges = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init()
	if getFlag("Battled.Zunna")==1 then
		entity_delete()
	else
		setupBasicEntity(
		"zunna-body",					-- texture
		12,								-- health
		1,								-- manaballamount
		10,								-- exp
		1,								-- money
		48,								-- collideRadius (only used if hit entities is on)
		STATE_WAIT,						-- initState
		256,							-- sprite width	
		256,							-- sprite height
		1,								-- particle "explosion" type, 0 = none
		0,								-- 0/1 hit other entities off/on (uses collideRadius)
		4000							-- updateCull -1: disabled, default: 4000
		)
	end
	
	entity_initSegments(10, 16, 16, "zunna-tentacle", 
	"zunna-tentacle", 128, 128, 0.05, 0)
	--createSubEntity("ZunnaArm")
end

function update(dt)
	if not(entity_getState()==STATE_DEAD) and not(entity_getState()==STATE_WEAK) then
		if entity_hasTarget() then
			if entity_isTargetInRange(64) then
				entity_hurtTarget(1);
				entity_pushTarget(250)
			end
		end
	end
	
	if entity_getState()==STATE_IDLE then
		if not entity_hasTarget() then
			entity_findTarget(1000)
		else
			if entity_isTargetInRange(250) then
				entity_moveAroundTarget(dt, 250*5, 0)
				entity_moveTowardsTarget(dt, 250*2.5)
			elseif entity_isTargetInRange(1200) then
				entity_moveTowardsTarget(dt, 1000)
			else
				entity_doFriction(dt, 100)
			end
			if entity_isTargetInRange(500) then
				attackDelay = attackDelay - dt
				if attackDelay <= 0 then
					if lunges > 2 then
						--entity_setState(STATE_RANGEATTACK)
						lunges = 0
						attackDelay = 2
					else
						--entity_setState(STATE_ATTACKPREP)
						lunges = lunges + 1
						attackDelay = 4
						if rangeAttackDelay < 2 then
							rangeAttackDelay = rangeAttackDelay + 2
						end
					end
				end
			end						
		end
	end
	if not(entity_getState() == STATE_WEAK) then
		if entity_getHealth() < 10 then
			entity_setState(STATE_WEAK)
		end
	end
	entity_doCollisionAvoidance(dt, 10, 1)
	if entity_getState()==STATE_WEAK then
		entity_doFriction(dt, 1000)
	end
	--entity_doSpellAvoidance(dt, 200, 1.5)
	--entity_rotateToVel(0.1)
	entity_updateMovement(dt)
end

function enterState()
	if entity_getState()==STATE_IDLE then
		entity_setMaxSpeed(1000)
	elseif entity_getState()==STATE_WAIT then
		entity_setMaxSpeed(0)
		entity_setActivation(1, 80, 320)
	elseif entity_getState()==STATE_WEAK then		
		--simpleConversation("Zunna_Weak")
		entity_setActivation(0, 80, 256)
	elseif entity_getState()==STATE_DEAD then
		setFlag("Battled.Zunna", 1)
		setFlag("ZunnaDied", 1)
		simpleConversation("Zunna_Died")
		setCanWarp(1)
		killEntity("Tungar")
		setFlag("HereticCave1", 6)
	end
end

function exitState()
end

function hitSurface()
end

function activate()
	if entity_getState()==STATE_WAIT then
		simpleConversation("Zunna_Battle")
		playMusic("Boss")
		entity_setState(STATE_IDLE)
		entity_setActivationType(-1)
	elseif entity_getState()==STATE_WEAK then
		setFlag("Battled.Zunna", 1)
		setFlag("ZunnaDied", 0)
		simpleConversation("Zunna_Capture")
		setCanWarp(1)
		killEntity("Tungar")
		setFlag("HereticCave1", 6)
		entity_delete()
	end
end