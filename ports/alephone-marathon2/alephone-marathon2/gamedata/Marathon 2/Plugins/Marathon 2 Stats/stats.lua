-- Copyright (C) 2011 and beyond by Gregory Smith, Jeremiah Morris,
-- and the "Aleph One" developers.
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- This license is contained in the file "COPYING",
-- which is included with this source code; it is available online at
-- http://www.gnu.org/licenses/gpl.html

Triggers = {}

function Triggers.init(restored)

   for p in Players() do
      if p.local_ then
         local_player = p
      end
   end

   stats = {}

   stats["start tick"] = Game.ticks
   stats["player color"] = local_player.color.mnemonic
   if #Players > 1 then
      stats["player name"] = local_player.name
      stats["player team"] = local_player.team.mnemonic
   end
   stats["difficulty"] = Game.difficulty.mnemonic
   stats["game type"] = Game.type.mnemonic
   stats["level"] = Level.name
   stats["level index"] = Level.index
   stats["map checksum"] = Level.map_checksum
   stats["players"] = # Players

   stats["scenario name"] = "Marathon 2"
   stats["engine version"] = Game.version
   
   if restored then
      stats["restored"] = 1
   end
   establish_session(restored)
end

function Triggers.cleanup()

   stats["end tick"] = Game.ticks
   if Level.completed then
      stats["level completed"] = 1
      
      -- count monsters left alive on map
      for m in Monsters() do
         if not m.player and (m.vitality > 0 or not m.visible) then
          increment(m.type.mnemonic .. "s spared")
        end
      end
   end

   if #Players > 1 then
      stats["player index"] = local_player.index

      if Game.type ~= "kill monsters" and
         Game.type ~= "cooperative play" then
         stats["points"] = local_player.points
      end
     
      -- only check multiplayer wins if the game finishes
      -- corollary: untimed games with no kill limit never count as wins!
      local find_winner = false

      if Players[0].disconnected then
         -- gatherer went away, game was interrupted
         stats["interrupted"] = 1
      elseif Game.type == "cooperative play" then
         -- Lua doesn't provide monster damage to replicate scoring
         find_winner = false
      elseif Game.time_remaining == 0 then
         -- Kill limit games convert to timed games when limit is
         -- reached, so this check conveniently covers both
         find_winner = true
      end
      
      if find_winner then
         -- send kills, deaths, suicides for complete game
         stats["game suicides"] = local_player.kills[local_player]
         stats["game deaths"] = local_player.deaths
         stats["game kills"] = 0
         for p in Players() do
            stats["game deaths"] = stats["game deaths"] + p.kills[local_player]
            if p ~= local_player then
               stats["game deaths by player " .. p.index] = p.kills[local_player]
               stats["game kills"] = stats["game kills"] + local_player.kills[p]
               stats["game kills of player " .. p.index] = local_player.kills[p]
            end
         end
         
         -- determine scores and rankings
         local scores = {}
         if Game.type == "kill monsters" then
            -- emfh
            for p in Players() do 
               -- emfh score = total kills (excluding suicides) - total deaths
               scores[p] = 0
               -- count up all the player's kills
               for pp in Players() do
                  if p ~= pp then
                     scores[p] = scores[p] + p.kills[pp]
                  end
               end
               -- subtract times he was killed (by other players and himself)
               for pp in Players() do
                  scores[p] = scores[p] - pp.kills[p]
               end
               -- subtract times he died for other reasons
               scores[p] = scores[p] - p.deaths
            end
         else
            local mult = 1
            if Game.type == "tag" or
               (Game.type == "netscript" and
                (Game.scoring_mode == "least points" or
                 Game.scoring_mode == "least_time")) then
               mult = -1
            end
            for p in Players() do
               scores[p] = p.points * mult
            end
         end
         stats["score"] = scores[local_player]
         
         stats["ranking"] = 1
         local tied = 0
         for p in Players() do
            if scores[p] > scores[local_player] then
               increment("ranking")
            elseif p ~= local_player and scores[p] == scores[local_player] then
               tied = 1
            end
         end
         if stats["ranking"] == 1 and tied == 0 then
            stats["winner"] = 1
         end
      end -- find_winner
   end -- #Players > 1
   
   -- count polygons and lines
   counted_lines = {}
   for p in Polygons() do
      increment("polygons")
      if p.visible_on_automap then
         increment("visible polygons")
      end
      for l in p.lines() do
         if not counted_lines[l.index] then
            increment("lines")
            if l.visible_on_automap then
               increment("visible lines")
            end
            counted_lines[l.index] = 1
         end
      end
   end

   Statistics = {}
   Statistics.parameters = stats
end

function Triggers.projectile_created(projectile)
   if projectile.type ~= "fist"
      and projectile.owner == local_player.monster then
      increment(projectile.type.mnemonic .. "s fired")
   end
end

function Triggers.monster_killed(monster, aggressor, projectile)
   if aggressor == local_player then
      increment(monster.type.mnemonic .. " kills")
   
      if projectile.type == "fist" then
         increment(monster.type.mnemonic .. " punch kills")
      end
   end
end

function Triggers.monster_damaged(_, aggressor_monster, _, _, projectile)
   if aggressor_monster == local_player.monster and projectile then
      if projectile.type ~= "fist" and not projectile._hit then
         projectile._hit = true
         increment(projectile.type.mnemonic .. "s hit")
      end
   end
end

function Triggers.player_damaged(_, aggressor_player, _, _, _, projectile)
   if aggressor_player == local_player and projectile then
      if projectile.type ~= "fist" and not projectile._hit then
         projectile._hit = true
         increment(projectile.type.mnemonic .. "s hit")
      end
   end
end

function Triggers.projectile_switch(projectile, side)
   if projectile.type == "fist" and projectile.owner == local_player.monster then
      increment("switches punched")
   end
end

function Triggers.tag_switch(_, player, side)
   if player == local_player and side.control_panel and side.control_panel.uses_item then
      increment("chips inserted")
   end
end

function Triggers.terminal_enter(_, player)
   if player == local_player then
      increment("terminals activated")
   end
end

function Triggers.player_killed(victim, aggressor)
   if victim == local_player then
      increment("deaths")
      
      if aggressor == local_player then
         increment("suicides")
      elseif aggressor then
         increment("deaths by player " .. aggressor.index)
      end

      -- kill zones
      if stats["death locations"] == nil then
         stats["death locations"] = ""
      end
      stats["death locations"] = stats["death locations"] .. 
           string.format(" %.1f,%.1f,%.1f,%d",
                         victim.x, victim.y, victim.z, victim.polygon.index)
      
   elseif aggressor == local_player then
      increment("kills")
      increment("kills of player " .. victim.index)
   end
end

function increment(key)
   if stats[key] then
      stats[key] = stats[key] + 1
   else
      stats[key] = 1
   end
end

function establish_session(restored)
   if Game.ticks == 0 then
      Game._initial_level = Level.index
      Game._saves_loaded = 0
   elseif restored then
      Game.restore_saved()
      if Game._saves_loaded ~= nil then
         Game._saves_loaded = Game._saves_loaded + 1
      end
   else
      Game.restore_passed()
   end 
   
   if Game._stat_session ~= nil then
      Game._parent_session = Game._stat_session
   end
   Game._stat_session = create_session_id()
   
   if Game._initial_level ~= nil then
      stats["initial level"] = Game._initial_level
   end
   if Game._parent_session ~= nil then
      stats["parent session"] = Game._parent_session
   end
   if Game._stat_session ~= nil then
      stats["stat session"] = Game._stat_session
   end
   if Game._saves_loaded ~= nil then
      stats["saves loaded"] = Game._saves_loaded
   end
end

function create_session_id()
   return string.sub(tostring(math.random()), 3)
end
