---Variable defined by the current gamestate
---@class state:PlayState
local state

---The current beat the conductor is on
---@type number
local curBeat

---The current step the conductor is on
---@type number
local curStep

---The current section the conductor is on
---@type number
local curSection

---The current bpm defined by conductor
---@type number
local bpm

---Interval between beat hits
---Needs to be corrected by doing
---```lua
---crochet * 0.001
---crochet / 1000
---```
---@type number
local crochet
