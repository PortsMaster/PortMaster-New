local folder = "funkin.gameplay.notemods."

NoteModifier = require(folder .. "notemodifier")

local NoteMods = {
	beat   = require(folder .. "notemodbeat"),
	column = require(folder .. "notemodcolumn"),
	scale  = require(folder .. "notemodscale"),
	scroll = require(folder .. "notemodscroll"),
	tipsy  = require(folder .. "notemodtipsy")
}

return NoteMods
