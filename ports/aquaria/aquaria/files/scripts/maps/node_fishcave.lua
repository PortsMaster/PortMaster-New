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

v.door = 0
v.n1 = 0
v.n2 = 0
v.n3 = 0
v.n4 = 0
v.won = false
v.n = 0
v.tous = 0

v.r1 = 0
v.r2 = 0
v.r3 = 0
v.r4 = 0

v.hole = 0

v.spawnDelay = 0

v.numFishNeeded = 3

v.glow1 = 0
v.glow2 = 0
v.glow3 = 0
v.glow4 = 0

function init(me)
	-- for debug: 
	--node_setCursorActivation(me, true)
	v.n1 = getNode("FISHLOC1")
	v.n2 = getNode("FISHLOC2")
	v.n3 = getNode("FISHLOC3")
	v.n4 = getNode("FISHLOC4")
	
	v.glow1 = node_getNearestEntity(v.n1, "fishcaveglow")
	v.glow2 = node_getNearestEntity(v.n2, "fishcaveglow")
	v.glow3 = node_getNearestEntity(v.n3, "fishcaveglow")
	v.glow4 = node_getNearestEntity(v.n4, "fishcaveglow")
	
	entity_msg(v.glow1, "color", 1)
	entity_msg(v.glow2, "color", 1)
	entity_msg(v.glow3, "color", 1)
	entity_msg(v.glow4, "color", 1)
	
	v.r1 = getNode("rock1")
	v.r2 = getNode("rock2")
	v.r3 = getNode("rock3")
	v.r4 = getNode("rock4")
	
	v.n = getNaija()
	
	v.tous = getNode("TOUS")
	v.hole = getNode("HOLE")
end

local function checkCreateFish(i)
	if v.spawnDelay == 0 then
		local name = string.format("CaveFish%d", i)
		local num = node_getNumEntitiesIn(v.tous, name)
		if num < 6 then
			v.spawnDelay = 3
			local e = createEntity(name, "", node_x(v.hole), node_y(v.hole))
			entity_scale(e, 0.1, 0.1)
			entity_scale(e, 1, 1, 2)
			entity_alpha(e, 0)
			entity_alpha(e, 1, 0.5)
		end
	end
end

local function doNode(nd, fx, nt)
	screenFadeCapture()
	cam_toNode(nd)
	screenFadeGo(0.5)
	watch(0.5)
	spawnParticleEffect(fx, node_x(nd), node_y(nd))
	playSfx("speedup")
	playSfx("spirit-return")
	watch(0.4)
	
	if nt == 1 then
		playSfx("low-note0")
	elseif nt == 2 then
		playSfx("low-note4")
	elseif nt == 3 then
		playSfx("low-note5")
	elseif nt == 4 then
		playSfx("low-note3")
	end
	
	watch(2)
end

local function doScene(me)
	if isFlag(FLAG_FISHCAVE, 0) then
	--if true then
		-- you win
		setFlag(FLAG_FISHCAVE, 1)
		
		entity_idle(v.n)
		
		fade2(1,0.5,1,1,1)
		watch(0.5)
		entity_setPosition(v.n, node_x(me), node_y(me))
		fade2(0,1,1,1,1)
		watch(1)
		
		overrideZoom(0.5, 2)
		
		changeForm(FORM_NORMAL)
		entity_idle(v.n)
		watch(1)
		playSfx("naijagasp")
		entity_animate(v.n, "agony", -1)
		watch(1)
		
		setCameraLerpDelay(0.001)
		
		doNode(v.r1, "fishcave1", 1)
		doNode(v.r2, "fishcave2", 2)
		doNode(v.r3, "fishcave3", 3)
		doNode(v.r4, "fishcave4", 4)
		
		screenFadeCapture()
		cam_toEntity(v.n)
		screenFadeGo(0.5)
		watch(1)
		spawnParticleEffect("fishtrans", entity_x(v.n), entity_y(v.n))
		playSfx("invincible")
		playSfx("speedup")
		fade2(1, 2, 1, 1, 1)
		watch(2)
		
		learnSong(SONG_FISHFORM)
		fade2(0, 0.5, 1, 1, 1)
		changeForm(FORM_FISH)
		voice("Naija_Song_FishForm")
		
		setControlHint(getStringBank(39), 0, 0, 0, 10, "", SONG_FISHFORM)
		
		setCameraLerpDelay(0)
		
		overrideZoom(0)
	end
end

function update(me, dt)
	if isFlag(FLAG_FISHCAVE, 0) then
		local num1 = node_getNumEntitiesIn(v.n1, "CaveFish1")
		local num2 = node_getNumEntitiesIn(v.n2, "CaveFish2")
		local num3 = node_getNumEntitiesIn(v.n3, "CaveFish3")
		local num4 = node_getNumEntitiesIn(v.n4, "CaveFish4")
		--debugLog(string.format("%d, %d, %d, %d", num1, num2, num3, num4))
		if 	num1 >= v.numFishNeeded and
			num2 >= v.numFishNeeded and
			num3 >= v.numFishNeeded and
			num4 >= v.numFishNeeded then
			doScene(me)
		end
		
		entity_msg(v.glow1, "g", num1/v.numFishNeeded)
		entity_msg(v.glow2, "g", num2/v.numFishNeeded)
		entity_msg(v.glow3, "g", num3/v.numFishNeeded)
		entity_msg(v.glow4, "g", num4/v.numFishNeeded)
	end
	
	if v.spawnDelay > 0 then
		v.spawnDelay = v.spawnDelay - dt
		if v.spawnDelay < 0 then
			v.spawnDelay = 0
		end
	end
	
	for i=1,4 do
		checkCreateFish(i)
	end
end

function activate(me)
	doScene(me)
end
