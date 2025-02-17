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

v.minNode = 1
v.maxNodes = 7

v.nodes = nil
v.raceStarted = false
v.avatarNode = 1
v.n = 0
v.timer = 0
v.lastNodeTimer = 0
v.maxLastNodeTimer = 20
v.raceTime = 0

v.kappa1 = 0
v.kappa2 = 0

v.songNote1 = 0
v.songNote2 = 0
v.songNote3 = 0
v.songNote4 = 0

v.timeRock = 0

v.maxLaps = 4
v.lap = 1

v.incut = false

v.doStartRace = false

function init(me)
	-- this could be odd.. if you add nodes after... postinit for nodes??
	v.nodes = {}
	for i=v.minNode, v.maxNodes do
		local nodeName = string.format("R0%d", i)
		v.nodes[i] = getNode(nodeName)
		if v.nodes[i]==0 then
			--debugLog("Could not find node named: " + nodeName)
		end
	end
	v.n = getNaija()
	
	--debugLog("setting")
	--node_setCursorActivation(me, true)	
	
	v.kappa1 = node_getNearestEntity(me, "Kappa")
	v.kappa2 = entity_getNearestEntity(v.kappa1, "Kappa")
	
	v.timeRock = node_getNearestEntity(me, "TimeRock")
	
	loadSound("mia-appear")
	
	setFlag(FLAG_SEAHORSETIMETOBEAT, 90) -- 2:00 -- used to be 90 / 1:30
	
	if isFlag(FLAG_SEAHORSEBESTTIME, 0) then
		setFlag(FLAG_SEAHORSEBESTTIME, getFlag(FLAG_SEAHORSETIMETOBEAT))
	end
	
	entity_msg(v.timeRock, "time", getFlag(FLAG_SEAHORSEBESTTIME))
end

function postInit(me)
end

local function showLap()
	if v.lap >= v.maxLaps then
		centerText(getStringBank(853))
	else
		centerText(string.format("%s %d", getStringBank(852), v.lap))
	end
end

local function stopRace(me)
	setCameraLerpDelay(0)
	v.raceStarted = false
	overrideZoom(0, 5)
	
	setTimerTextAlpha(0, 1)
end

local function lost(me)
	v.raceStarted = false
	
	debugLog("you failed the race")

	playSfx("denied")
	entity_idle(v.n)
	fadeOutMusic(1.4)
	watch(0.5)
	fade2(1, 1, 1, 1, 1)
	watch(1)
	entity_setPosition(v.n, node_x(me), node_y(me))
	watch(0.5)
	
	updateMusic()
	
	fade2(0, 1, 1, 1, 1)
	watch(1)
	
	stopRace(me)
end

local function won(me)
	v.raceStarted = false
	
	updateMusic()
	
	
	
	entity_idle(v.n)
	watch(1)
	entity_flipToEntity(v.n, v.timeRock)
	
	if v.raceTime < getFlag(FLAG_SEAHORSEBESTTIME) then
		setFlag(FLAG_SEAHORSEBESTTIME, v.raceTime)
		cam_toEntity(v.timeRock)
		watch(0.5)
		entity_msg(v.timeRock, "time", v.raceTime)
		watch(3)
	end
	
	
	
	if v.raceTime < getFlag(FLAG_SEAHORSETIMETOBEAT) then
		if isFlag(FLAG_COLLECTIBLE_SEAHORSECOSTUME, 0) and getEntity("collectibleseahorsecostume") == 0 then
			local nd = getNode("armorloc")
			local e = createEntity("collectibleseahorsecostume", "", node_x(nd), node_y(nd))
			entity_alpha(e, 0)
			cam_toEntity(e)
			watch(0.5)
			playSfx("secret")
			playSfx("mia-appear")
			spawnParticleEffect("tinyredexplode", node_x(nd), node_y(nd))
			entity_alpha(e, 1, 1)
			watch(2)
		end
	end
	
	cam_toEntity(v.n)
	
	stopRace(me)
end


function songNoteDone(me, note, t)
	if not v.raceStarted then
		v.songNote1 = v.songNote2
		v.songNote2 = v.songNote3
		v.songNote3 = v.songNote4
		v.songNote4 = note

		if v.songNote1 == 0 and v.songNote2 == 3 and v.songNote3 == 4 and v.songNote4 == 5 then
			debugLog("setting startRace")
			v.doStartRace = true
		end
	end
end

function update(me, dt)
	if v.incut then return end
	v.n = getNaija()
	if v.doStartRace then
		debugLog("start race!")
		v.incut = true
		
		entity_idle(v.n)
		
		v.avatarNode = 1
		v.raceTime = 0
		v.lastNodeTimer = 0
		
		fade2(1, 0.5, 1, 1, 1)
		watch(0.5)
		
		entity_setPosition(v.n, node_x(me), node_y(me))
		watch(0.4)
		fade2(0, 1, 1, 1, 1)
		overrideZoom(0.4, 3)
		fadeOutMusic(2)
		watch(2.5)
		entity_setState(v.kappa1, STATE_CHARGE1)
		entity_setState(v.kappa2, STATE_CHARGE1)
		watch(1)
		entity_setState(v.kappa1, STATE_CHARGE2)
		entity_setState(v.kappa2, STATE_CHARGE2)
		watch(1)
		entity_setState(v.kappa1, STATE_CHARGE3)
		entity_setState(v.kappa2, STATE_CHARGE3)
		v.raceStarted = true
		entity_addVel(v.n, 0, -800)
		
		setCameraLerpDelay(0.04)
		playMusic("sunworm")
		
		v.lap = 1
		
		showLap()
		
		v.doStartRace = false
		v.incut = false
		
		setTimerTextAlpha(1, 1)
	end
	if v.raceStarted then
		overrideZoom(0.4, 0.5)
		
		local node = entity_getNearestNode(v.n, "wrongway")
		if node ~= 0 and node_isEntityIn(node, v.n) then
			centerText(getStringBank(851))
			lost(me)
		else
			v.raceTime = v.raceTime + dt
			
			setTimerText(v.raceTime)
			
			v.lastNodeTimer = v.lastNodeTimer + dt
			if v.lastNodeTimer > v.maxLastNodeTimer then
				lost(me)
			end
			if node_isEntityIn(v.nodes[v.avatarNode], v.n) then
				local k1 = node_getNearestEntity(v.nodes[v.avatarNode], "kappa")
				local k2 = entity_getNearestEntity(k1, "kappa")
				--debugLog(string.format("crossed node %d", v.avatarNode))
				playSfx("secret", 0, 0.5)
				v.lastNodeTimer = 0
				v.avatarNode = v.avatarNode + 1
				if v.avatarNode > v.maxNodes then
					v.lap = v.lap + 1
					showLap()
					if v.lap < v.maxLaps then
						v.avatarNode = 1
						entity_setState(k1, STATE_CHARGE2)
						entity_setState(k2, STATE_CHARGE2)
					else
						entity_setState(k1, STATE_CHARGE3)
						entity_setState(k2, STATE_CHARGE3)
						won(me)
					end
				else
					entity_setState(k1, STATE_CHARGE1)
					entity_setState(k2, STATE_CHARGE1)
				end
			end
		end
		
		debugLog(string.format("v.raceTime: %d", v.raceTime))
	end
end

function activate(me)
end


