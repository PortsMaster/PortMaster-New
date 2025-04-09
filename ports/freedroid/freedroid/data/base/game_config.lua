--[[

  Copyright (c) 2017 Samuel Degrande

  This file is part of Freedroid

  Freedroid is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  Freedroid is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Freedroid; see the file COPYING. If not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
  MA  02111-1307  USA

]]--

game_acts{
	-- id: Unique identifier
	-- name: Act name
	-- intro: text displayed when the game act is started (use \n for multilines text)
	-- sudbir: Subdir name in MAP_DIR (data/storyline)
	-- is_starting_act: True if this act is the starting one
	{ id = "act1", name = "Return Of Tux",
	  intro = _"-= Start of Act 1 =-",
	  subdir = "act1", is_starting_act = true  },
	{ id = "act2", name = "Dvorak, First AI",
	  intro = _"-= Start of Act 2 =-",
	  subdir = "act2", is_starting_act = false },
}
