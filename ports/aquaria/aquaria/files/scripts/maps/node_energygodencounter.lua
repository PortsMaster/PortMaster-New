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

v.energyGod = 0
v.naija = 0
v.noteSung1 = 0
v.noteSung2 = 0
v.noteSung3 = 0
v.foundSong = false
v.songDelay = 0
v.singDelay = 8
v.maxSingDelay = 10
v.running = false

-- SEE ENERGYTEMPLE_FIRSTSLOT

local function singSong(me)
	local node = getNode("SONGMOUTH")				
	spawnParticleEffect("EnergyGodSong", node_x(node), node_y(node))
	playSfx("EnergyGodSong")
end

function init(me)
	loadSound("EnergyGodSong")
	
	v.naija = getNaija()
	
	if isFlag(FLAG_ENERGYGODENCOUNTER, 3) then
		local templeStatue = getEntity("TempleStatue")
		entity_setState(templeStatue, STATE_BROKEN)
		
		local door = node_getNearestEntity(getNode("STATUEEXITDOOR"), "energydoor")
		entity_setState(door, STATE_OPENED)
	end
	
	loadSound("CrumbleFall")
	
	if isFlag(FLAG_ENERGYGODENCOUNTER, 1) then		
		local pn = getNode("SONGMOUTH")	
		local ent = createEntity("EnergyGodSpirit", "", node_x(pn), node_y(pn))
		fadeOutMusic(1)
	end
	--debugLog(string.format("%d flag is %d", FLAG_ENERGYGODENCOUNTER, getFlag(FLAG_ENERGYGODENCOUNTER)))
	--[[
	if getFlag(FLAG_ENERGYGODENCOUNTER) > 0 then
		debugLog("setting door... closed")
		energyDoor = node_getNearestEntity(me, "EnergyDoor")
		if energyDoor ~= 0 then
			entity_setState(energyDoor, STATE_CLOSED)
		else
			debugLog("Could not find door")
		end
	else
		debugLog("FLAG NOT SET")
	end
	]]--
	--[[
	i = 0
	while (i < 100) do
		debugLog("BLAH")
		i = i + 1
	end
	]]--
	--[[
	v.energyGod = getEntity("EnergyGod")
	FLAG_ENERGYGODENCOUNTER
	if getStory() >= 5.1 then
		entity_delete(v.energyGod)
		v.energyGod = 0
	end	
	]]--
end

local function transformScene(me)
	setCutscene(1,1)
	setFlag(FLAG_ENERGYGODENCOUNTER, 3)
	local camNode = getNode("ENERGYGODCAM")
	local particleNode = getNode("ENERGYGODPARTICLES")
	local particleNode2 = getNode("ENERGYGODPARTICLES2")
	entity_swimToNode(v.naija, me)
	entity_watchForPath(v.naija)
	entity_flipToNode(v.naija, camNode)
	entity_idle(v.naija)
	entity_clearVel(v.naija)
	watch(0.5)
	cam_toNode(camNode)
	
	local templeStatue = getEntity("TempleStatue")
	entity_setState(templeStatue, STATE_BREAK)
	playSfx("CrumbleFall")
	local crumbleNode = getNode("CRUMBLEPARTICLES")	
	spawnParticleEffect("EnergyGodStatueCrumble", node_x(crumbleNode), node_y(crumbleNode))
	
	watch(2.3)
	
	esetv(v.naija, EV_LOOKAT, 0)
	
	playSfx("RockHit-Big")
	
	shakeCamera(8, 2)
	spawnParticleEffect("EnergyGodStatueDust", node_x(particleNode), node_y(particleNode))
	
	entity_animate(v.naija, "look-45", LOOP_INF, LAYER_HEAD)
	
	cam_toNode(getNode("ENERGYGODPARTICLESCAM"))

	while entity_isAnimating(templeStatue) do
		watch(FRAME_TIME)
	end	
	
	watch(2)
	
	setSceneColor(1, 0.6, 0.5, 4)
	
	spawnParticleEffect("EnergyGodEnergy", node_x(particleNode), node_y(particleNode))
	
	watch(2)
	
	spawnParticleEffect("EnergyGodSend", node_x(particleNode2), node_y(particleNode2))
	watch(0.5)
	voice("EnergyGodTransfer")
	entity_animate(v.naija, "checkoutEnergy")
	watch(1.5)
	
	
	
	watch(0.5)
	cam_toEntity(v.naija)
	
	setNaijaHeadTexture("Pain")
	entity_idle(v.naija)
	playSfx("NaijaZapped")
	setSceneColor(1, 0.5, 0.5, 1)
	entity_animate(v.naija, "energyStruggle", LOOP_INF)
	
	spawnParticleEffect("EnergyGodTransfer", entity_x(v.naija), entity_y(v.naija))
	watch(3.5)
	entity_animate(v.naija, "energyStruggle2", LOOP_INF)
	watch(1.0)
	
	learnSong(SONG_ENERGYFORM)
	changeForm(FORM_ENERGY)
	setSceneColor(1, 1, 1, 10)
	entity_idle(v.naija)
	playMusic("archaic")
	voice("NAIJA_ENERGYFORM")
	watch(2)
	entity_animate(v.naija, "checkoutEnergy")
	while entity_isAnimating(v.naija) do
		watch(FRAME_TIME)
	end
	watch(0.5)
	
	setCutscene(0)
	
	esetv(v.naija, EV_LOOKAT, 1)
	setControlHint(getStringBank(37), 0, 0, 0, 10, "", SONG_ENERGYFORM)
	
	local door = node_getNearestEntity(getNode("STATUEEXITDOOR"), "EnergyDoor")
	entity_setState(door, STATE_OPEN)
end

function songNote(me, songNote)
	if isFlag(FLAG_ENERGYGODENCOUNTER, 2) then
		v.noteSung1 = v.noteSung2
		v.noteSung2 = v.noteSung3
		v.noteSung3 = songNote
		v.songDelay = 0
		
		if v.noteSung1 == 7 and v.noteSung2 == 6 and v.noteSung3 == 5 then
			v.foundSong = true
			v.songDelay = 1.2
		end
	end
end

function update(me, dt)
	if v.running then return end
	v.running = true
	if isFlag(FLAG_ENERGYGODENCOUNTER, 0) then
		if node_isEntityIn(me, v.naija) then
			local dc = getNode("ENERGYDOORCAM")
			local energyDoor = node_getNearestEntity(dc, "EnergyDoor")
			if energyDoor ~= 0 then
				entity_setState(energyDoor, STATE_CLOSE)
			end
			
			
			entity_idle(v.naija)
			entity_clearVel(v.naija)
			cam_toNode(getNode("ENERGYDOORCAM"))
			watch(1)
			emote(EMOTE_NAIJAUGH)
			watch(2.1)			
			
			cam_toNode(getNode("ENERGYGODCAM"))
			entity_flipToNode(v.naija, getNode("ENERGYGODCAM"))
			
			fadeOutMusic(5)
			
			watch(2)
			
			--[[
			local sn = getNode("ENERGYSPIRIT")
			spawnParticleEffect("EnergySpirit", node_x(sn), node_y(sn))
			]]--
			--entity_sound(v.naija, "EnergyGodSong")
			--singSong(me)
			
			
			
			
			local pn = getNode("SONGMOUTH")	
			local ent = createEntity("EnergyGodSpirit", "", node_x(pn), node_y(pn))
			
			emote(EMOTE_NAIJAWOW)
			watch(1)
			
			emote(EMOTE_NAIJAWOW)
			watch(1)
		
			
			--[[
			v.singDelay = v.maxSingDelay
			]]--
			
			cam_toEntity(v.naija)
			
			setFlag(FLAG_ENERGYGODENCOUNTER, 1)
		end
	elseif isFlag(FLAG_ENERGYGODENCOUNTER, 2) then
		
		if node_isEntityInRange(me, v.naija, 1000) then
			if v.singDelay > 0 then
				v.singDelay = v.singDelay - dt
				if v.singDelay < 0 then
					v.singDelay = v.maxSingDelay
					singSong(me)
				end
			end
		end
		if v.songDelay > 0 then
			v.songDelay = v.songDelay - dt
			if v.songDelay < 0 then
				v.songDelay = 0
				transformScene(me)
			end
		end
	end
	v.running = false
end

function activate(me)
	entity_idle(v.naija)
	entity_clearVel(v.naija)
	
	cam_toNode(getNode("ENERGYGODCAM"))
	entity_flipToNode(v.naija, getNode("ENERGYGODCAM"))
	
	v.singDelay = v.maxSingDelay
	watch(2)
	
	singSong(me)
	v.singDelay = v.maxSingDelay
	
	watch(3)
	
	cam_toEntity(v.naija)
end
