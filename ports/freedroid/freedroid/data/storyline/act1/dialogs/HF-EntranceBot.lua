---------------------------------------------------------------------
-- This file is part of Freedroid
--
-- Freedroid is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Freedroid is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Freedroid; see the file COPYING. If not, write to the
-- Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
-- MA 02111-1307 USA
----------------------------------------------------------------------
--[[WIKI
PERSONALITY = {"Robotic"},
PURPOSE = "$$NAME$$ guards and limits access to the Mega Systems Factory entrance"
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		Npc:says(_"Welcome to the MegaSys Factory complex.")
		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			Tux:says(_"Still alive? Don't you know that you should update your firmware often?")
		end
		Npc:says(_"Access is restricted to authorized personnel.")
		Npc:says(_"Proof of authorization is required.")
		if (not HF_EntranceBot_MSStockCertificateOpensGate) then
			if (Tux:has_met("WillGapes")) then
				Tux:update_quest("Open Sesame", "I managed to find the main gates, but an annoying droid locked the innermost gate. I need to proof that I am authorized to visit the Factory. Maybe Will Gapes can help?")
			else
				Tux:update_quest("Open Sesame", "I managed to find the main gates, but an annoying droid locked the innermost gate. I need to proof that I am authorized to visit the Factory. Maybe I missed something?")
			end
			HF_EntranceBot_MSStockCertificateOpensGate = true
		end

		if (Tux:done_quest("Open Sesame")) then
			Tux:says(_"How many times do I have to show you my certificate, tin can?")
			if (Tux:has_item("MS Stock Certificate")) then
				Npc:says(_"[b]Validating certificate...[/b]")
				Npc:says(_"[b]Validation complete.[/b]", "NO_WAIT")
				Npc:says(_"[b]Certificate valid.[/b]", "NO_WAIT")
				Npc:says(_"You may enter.")
				change_obstacle_state("HF-EntranceInnerGate", "opened")
				hide("node1", "node2", "node3")
			else
				Tux:says(_"Oh, I... uh... must have left it in my other armor.")
				Tux:says(_"I'll go get it for you. Yes. Because I TOTALLY know where it is. I hope.")
			end
		else
			show("node1", "node2", "node3")
		end
		show("node99")
	end,

	{
		id = "node1",
		text = _"I am THE ONE.",
		code = function()
			Npc:says(_"You are THE ONE without permission.")
			Npc:says(_"Please consider leaving.")
			hide("node1")
			end_dialog()
		end,
	},
	{
		id = "node2",
		text = _"I am working here.",
		code = function()
			Npc:says(_"Me too.")
			Npc:says(_"Please prove your statement.")
			Tux:says(_"Do I look like a typical MegaSys slave, err, worker to you, stupid bot?")
			Npc:says(_"No insults, please. But, no")
			if (Tux:has_item("MS Stock Certificate")) then
				Tux:says(_"But I have this certificate")
				Npc:says(_"[b]Validating certificate...[/b]")
				Npc:says(_"[b]Validation complete.[/b]", "NO_WAIT")
				Npc:says(_"[b]Certificate valid.[/b]", "NO_WAIT")
				Npc:says(_"You may enter.")
				if ((Tux:has_quest("Open Sesame")) and
					(not Tux:done_quest("Open Sesame"))) then
						Tux:end_quest("Open Sesame", _"The gates are open. The firmware server should lay beyond them.")
				end
				change_obstacle_state("HF-EntranceInnerGate", "opened")
			else
				end_dialog()
			end
			hide("node2")
		end,
	},
	{
		id = "node3",
		text = _"I have come to save the world, I don't need any proof.",
		code = function()
			Npc:says(_"Feel uncertain about the future?")
			Npc:says(_"Purchase the MegaSys Security Bundle to help safeguard your home.")
			Npc:says(_"It contains:")
			Npc:says(_"The latest version of the [b]MegaSys[/b] operating system for [b]ONE DROID[/b]")
			Npc:says(_"Ten mini surveillance robots.")
			Npc:says(_"The book 'Subatomic and Nuclear Science for Dummies, Volume IV'.")
			Npc:says(_"And a MegaSys Vision Enhancement Device 3000 - what you cannot see, can't see you either!")
			Npc:says(_"If you order [b]RIGHT NOW[/b], we will [b]SHIP FOR FREE!!![/b]")
			Tux:says(_"No, thanks.")
			hide("node3")
		end,
	},
	{
		id = "node99",
		text = _"Bye",
		code = function()
			Npc:says(_"Remember, MegaSys products are the best!")
			end_dialog()
		end,
	},
}
