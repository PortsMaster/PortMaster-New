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

function init(me)
	v.energyGod = getEntity("EnergyGod")
	node_setCursorActivation(me, false)
	if getStory() >= 5.1 then
		entity_delete(v.energyGod)
		v.energyGod = 0
	end
end

function song(me, song)
	if isStory(5) then
		if song == SONG_ENERGYFORM then			
			entity_flipToEntity(getNaija(), v.energyGod)
			wnd(1)
			txt("At last, I am free. Now use the gift of my spirit, little Naija.")
			--txt("ENERGY GOD FADES AWAY")			
			wnd(0)
			entity_delete(v.energyGod, 3)
			watch(3)
			voice("naija_energyform")
			setStory(5.1)
		end
	end
end

function update(me, dt)
	if getStory()<5 then
		if entity_x(getNaija()) < node_x(me) then
			
			local naija = getNaija()
			local energyDoor = node_getNearestEntity(me, "EnergyDoor")
			if energyDoor ~= 0 then
				entity_setState(energyDoor, STATE_CLOSE)
			end
			
			
			entity_idle(naija)
			entity_clearVel(naija)
			setStory(5)
			watch(3.1)
			entity_flipToEntity(naija, v.energyGod)
			wnd(1)
			
			txt("Creature: Who goes there?")			
			txt("Naija: It... it is I, Naija.")
			txt("Creature: Naija... what a beautiful name.")
			txt("Naija: Beautiful?")
			txt("Creature: Come closer, little Naija.")
			wnd(0)
			
			entity_swimToNode(naija, getNode("ENERGYGOD_NAIJA"))
			entity_watchForPath(naija)
			cam_toNode(getNode("ENERGYGOD_CAM"))
			
			wnd(1)
			txt("Naija: ...")
			txt("Naija: In the name of the Old Father! What kind of foul creature are you?")
			txt("Nerhaji: Ha! Foul? I am Nerhaji! Once I was as mighty a God as any. Now reduced to this form... it is more than foul, it is sacrilege.")
			wnd(0)
			-- [[ACTION...
			--txt("Action: ENERGY GOD GRABS NAIJA")
			
			entity_animate(v.energyGod, "grabTransition")
			watch(0.25)
			-- ...ACTION]]
			setNaijaHeadTexture("Pain")
			entity_animate(getNaija(), "trapped", LOOP_INF)						
			entity_animate(v.energyGod, "grabLoop", LOOP_INF)
			watch(1)
			wnds(1)
			txt("Naija: What? Put me down!")
			txt("Nerhaji: You are a defiant one, indeed. One I would have called a sinner, so long ago. One who would have been fed to me, as nothing more than a tasty morsel.")
			txt("Naija: *pain* Let... me... go!")
			-- [[ACTIoN...
			txt("Action: SQUEEZING SOUND")
			-- ...ActioN]]
			--entity_animate(getNaija(), "trapped2", LOOP_INF)
			txt("Nerhaji: This pain you feel Naija, does it make you feel alive?")
			txt("Naija: *pain* What...?")
			txt("Nerhaji: Your bones could be crushed in an instant. Your spirit extinguished from this realm forever.")
			txt("Naija: *pain* ...")
			txt("Nerhaji: You may very well be asking yourself, 'Why am I still alive?'")
			txt("Nerhaji: The answer is simple.")
			txt("Nerhaji: It is by my grace that you are allowed to continue squirming in my mighty grasp.")
			txt("Nerhaji: For you see, Naija; I need something from you.")
			txt("Nerhaji: I require a gift, and it is a gift that even a frail mortal as yourself, can provide.")
			txt("Naija: *pain* What... do you want...")
			txt("Nerhaji: Quite simply, Naija, I am old. I am tired.")
			txt("Nerhaji: I have spent an eternity in this place, longing to be free.")
			txt("Naija: *pain* What... makes you think... that I would free you...")
			txt("Nerhaji: Ha! As if I would desire to rule in this dying age. No, Naija... I wish to be free from existence.")
			txt("Naija: You want to... die?")			
			wnd(0)
			
			entity_animate(v.energyGod, "idle", LOOP_INF)
			--ENERGY GOD RELASES NAIJA
			
			setNaijaHeadTexture("")
			entity_idle(naija)
			
			entity_swimToNode(naija, getNode("NAIJA_BACKOFF"))
			entity_watchForPath(naija)
			entity_flipToEntity(naija, v.energyGod)
			wnd(1)
			txt("Nerhaji: What was truly me has long since died. All that remains is to free my spirit.")
			txt("Nerhaji: I will teach you the Song that will bind me to the void, once and for all.")
			wnd(0)
			
			cam_toEntity(naija)
			
			-- gain energy form song
			learnSong(SONG_ENERGYFORM)
		end
	end
end
