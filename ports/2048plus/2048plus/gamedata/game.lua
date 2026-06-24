-- Core 2048 Game Logic
-- Ported from MainGame.java

local Grid = require("grid")
local Tile = require("tile")
local save = require("save")

local Game = {}
Game.__index = Game

-- Game states
Game.STATE_PLAYING  = 0
Game.STATE_WON      = 1
Game.STATE_LOST     = 2
Game.STATE_ENDLESS  = 3   -- Continuing after winning
Game.STATE_PAUSED   = 4 -- Confirming accidental restart
Game.STATE_TARGETING_BOMB = 5
Game.STATE_TARGETING_SWAP_1 = 6
Game.STATE_TARGETING_SWAP_2 = 7

-- Direction constants: 0=up, 1=right, 2=down, 3=left
Game.DIR_UP    = 0
Game.DIR_RIGHT = 1
Game.DIR_DOWN  = 2
Game.DIR_LEFT  = 3

-- Direction vectors (dx, dy)
local vectors = {
    [0] = {x =  0, y = -1},  -- up
    [1] = {x =  1, y =  0},  -- right
    [2] = {x =  0, y =  1},  -- down
    [3] = {x = -1, y =  0},  -- left
}

function Game.new(mode)
    local self = setmetatable({}, Game)
    self.mode = mode or "classic"
    save.saveLastMode(self.mode)
    self.size = 4
    self.targetValue = 2048
    if self.mode == "huge" then
        self.size = 5
        self.targetValue = 2048
    end
    self.grid = Grid.new(self.size, self.size)
    self.score = 0
    self.highScore = save.loadHighScore(self.mode)
    self.state = Game.STATE_PLAYING
    self.won = false
    self.moved = false

    -- Time Attack state
    self.timeLeft = nil
    self.totalTime = nil
    self.timeAttackBonus = 0  -- accumulated bonus time for this move
    self.timePopups = {}
    self.timerFlashTimer = 0

    -- Plus Mode state
    local initial_powerups = _G.cheat_max_powerups and 99 or 1
    self.powerups = { undo = initial_powerups, bomb = initial_powerups, swap = initial_powerups }
    self.milestonesReached = {}
    self.floatingNotifications = {}
    self.cursorX = 1
    self.cursorY = 1
    self.swapTarget = nil

    self.bombAnimation = nil
    self.swapAnimation = nil

    -- Undo state
    self.undoHistory = {}
    self.canUndo = false

    -- Animation tracking
    self.animationTimer = 0
    self.animationDuration = 0.12  -- seconds
    if _G.animation_speed == "fast" then
        self.animationDuration = 0.06
    elseif _G.animation_speed == "instant" then
        self.animationDuration = 0
    elseif _G.animation_speed == "slow" then
        self.animationDuration = 0.24
    end

    -- Try to load saved game state
    local savedState = save.loadState(self.mode)
    if savedState and savedState.gridState then
        self.score = savedState.score or 0
        self.state = savedState.state or Game.STATE_PLAYING
        self.won = savedState.won or false
        if self.state == Game.STATE_PAUSED then
            self.state = self.won and Game.STATE_ENDLESS or Game.STATE_PLAYING
        end
        self.canUndo = savedState.canUndo or false
        self.grid:restoreState(savedState.gridState)
        if savedState.undoHistory then
            self.undoHistory = savedState.undoHistory
        else
            self.undoHistory = {}
            if savedState.undoState then
                table.insert(self.undoHistory, {
                    gridState = savedState.undoState,
                    score = savedState.undoScore or 0,
                    rng = savedState.undoRNG
                })
            end
        end

        if savedState.powerups then
            self.powerups = savedState.powerups
        end
        if savedState.milestonesReached then
            self.milestonesReached = savedState.milestonesReached
        end

        -- Restore Time Attack state
        if self.mode == "timeattack" then
            self.timeLeft = savedState.timeLeft or 60.0
            self.totalTime = savedState.totalTime or 60.0
        end
    else
        -- Start a fresh game if no save state exists
        self:addStartTiles()

        if _G.stats then
            _G.stats.games_played = (_G.stats.games_played or 0) + 1
            if self.mode == "classic" then
                _G.stats.classic_games = (_G.stats.classic_games or 0) + 1
            elseif self.mode == "plus" then
                _G.stats.plus_games = (_G.stats.plus_games or 0) + 1
            else
                _G.stats.arcade_games = (_G.stats.arcade_games or 0) + 1
            end
            save.saveStats(_G.stats)
        end

        if _G.achievements then
            _G.achievements.powerups_used_this_run = 0
            save.saveAchievements(_G.achievements)
        end
    end
    -- Trigger "First Steps" achievement
    if _G.unlockAchievement and self.mode ~= "huge" then
        _G.unlockAchievement("ach_first_game")
    end

    -- Time Attack: initialize timer after everything is set up if not loaded from save
    if mode == "timeattack" and not self.timeLeft then
        self.totalTime = tonumber(_G.time_attack_time) or 60.0
        self.timeLeft = self.totalTime
    end

    return self
end

function Game:saveGameState()
    if _G.stats then
        local maxVal = 0
        for x = 1, self.size do
            for y = 1, self.size do
                local cell = self.grid:cellContent(x, y)
                if cell and type(cell.value) == "number" and cell.value > maxVal then
                    maxVal = cell.value
                end
            end
        end
        if maxVal > (_G.stats.highest_tile or 0) then
            _G.stats.highest_tile = maxVal
        end
        if self.score > (_G.stats.highest_score or 0) then
            _G.stats.highest_score = self.score
        end
        save.saveStats(_G.stats)
    end

    local stateTable = {
        score = self.score,
        state = self.state,
        won = self.won,
        canUndo = self.canUndo,
        gridState = self.grid:saveState(),
        undoHistory = self.undoHistory,
        powerups = self.powerups,
        milestonesReached = self.milestonesReached
    }
    if self.mode == "timeattack" then
        stateTable.timeLeft = self.timeLeft
        stateTable.totalTime = self.totalTime
    end
    save.saveState(stateTable, self.mode)
end

function Game:addStartTiles()
    if _G.cheat_debug_layout == "Fill Board" then
        _G.cheat_debug_layout = "None"
        local val = 2
        for r = 1, 4 do
            for c = 1, 4 do
                local tile = Tile.new(c, r, val)
                tile.isNew = true
                self.grid:insertTile(tile)
                val = val * 2
            end
        end
        return
    end

    if _G.cheat_debug_layout == "Two 1024s" then
        _G.cheat_debug_layout = "None"
        local tile1 = Tile.new(1, 1, 1024)
        tile1.isNew = true
        self.grid:insertTile(tile1)

        local tile2 = Tile.new(2, 1, 1024)
        tile2.isNew = true
        self.grid:insertTile(tile2)
        return
    end

    local starting_tiles = 2

    if self.mode == "goose" then
        local cell = self.grid:randomAvailableCell()
        if cell then
            local goose = Tile.new(cell.x, cell.y, "goose")
            goose.isNew = true
            self.grid:insertTile(goose)
        end
        starting_tiles = 1
    end

    if self.mode == "classic" and _G.cheat_start_1024_classic then
        _G.cheat_start_1024_classic = false
        if self.grid:cellsAvailable() then
            local cell = self.grid:randomAvailableCell()
            if cell then
                local tile = Tile.new(cell.x, cell.y, 1024)
                tile.isNew = true
                self.grid:insertTile(tile)
                starting_tiles = starting_tiles - 1
            end
        end
    elseif self.mode == "plus" and _G.cheat_start_1024_plus then
        _G.cheat_start_1024_plus = false
        if self.grid:cellsAvailable() then
            local cell = self.grid:randomAvailableCell()
            if cell then
                local tile = Tile.new(cell.x, cell.y, 1024)
                tile.isNew = true
                self.grid:insertTile(tile)
                starting_tiles = starting_tiles - 1
            end
        end
    end

    for _ = 1, starting_tiles do
        self:addRandomTile()
    end
end

function Game:addRandomTile()
    if self.grid:cellsAvailable() then
        local value = love.math.random() < 0.9 and 2 or 4

        local cell = self.grid:randomAvailableCell()
        if cell then
            local tile = Tile.new(cell.x, cell.y, value)
            tile.isNew = true
            self.grid:insertTile(tile)
        end
    end
end

function Game:prepareTiles()
    self.grid:eachCell(function(x, y, tile)
        if tile then
            tile.mergedFrom = nil
            tile.isNew = false
            tile.isMerged = false
            tile.undoSourcePosition = nil
            tile:savePosition()
        end
    end)
end

function Game:moveTile(tile, x, y)
    self.grid.cells[tile.x][tile.y] = nil
    tile:setPosition(x, y)
    self.grid.cells[x][y] = tile
end

-- Build traversal order based on direction
function Game:buildTraversals(direction)
    local traversalsX = {}
    local traversalsY = {}

    for i = 1, self.size do
        table.insert(traversalsX, i)
        table.insert(traversalsY, i)
    end

    -- If moving right, traverse right-to-left
    if vectors[direction].x == 1 then
        local reversed = {}
        for i = #traversalsX, 1, -1 do
            table.insert(reversed, traversalsX[i])
        end
        traversalsX = reversed
    end

    -- If moving down, traverse bottom-to-top
    if vectors[direction].y == 1 then
        local reversed = {}
        for i = #traversalsY, 1, -1 do
            table.insert(reversed, traversalsY[i])
        end
        traversalsY = reversed
    end

    return traversalsX, traversalsY
end

-- Find the farthest position a tile can move to
function Game:findFarthestPosition(x, y, direction)
    local vec = vectors[direction]
    local prevX, prevY = x, y
    local nextX, nextY = x + vec.x, y + vec.y

    while self.grid:withinBounds(nextX, nextY) and self.grid:cellAvailable(nextX, nextY) do
        prevX, prevY = nextX, nextY
        nextX = nextX + vec.x
        nextY = nextY + vec.y
    end

    return prevX, prevY, nextX, nextY
end

function Game:move(direction)
    if self.state == Game.STATE_LOST or self.state == Game.STATE_WON then
        return false
    end

    -- Save undo state before the move, but only apply it if the board actually changes
    local pendingUndoState = self.grid:saveState()
    local pendingUndoScore = self.score
    local pendingUndoRNG = love.math.getRandomState()

    local traversalsX, traversalsY = self:buildTraversals(direction)
    local moved = false

    self:prepareTiles()

    for _, x in ipairs(traversalsX) do
        for _, y in ipairs(traversalsY) do
            local tile = self.grid:cellContent(x, y)
            if tile and tile.value ~= "goose" then
                local farthestX, farthestY, nextX, nextY = self:findFarthestPosition(x, y, direction)
                local nextTile = self.grid:cellContent(nextX, nextY)

                -- Can we merge with the next tile?
                if nextTile and nextTile.value == tile.value and nextTile.mergedFrom == nil then
                    -- Merge!
                    if _G.stats then
                        _G.stats.tiles_merged = (_G.stats.tiles_merged or 0) + 1
                    end
                    local merged = Tile.new(nextX, nextY, tile.value * 2)
                    merged.mergedFrom = {tile, nextTile}
                    merged.isMerged = true
                    merged.previousPosition = {x = tile.x, y = tile.y}

                    self.grid:insertTile(merged)
                    self.grid:removeTile(tile)

                    -- Update score
                    self.score = self.score + merged.value
                    if self.score > self.highScore then
                        self.highScore = self.score
                        save.saveHighScore(self.highScore, self.mode)
                    end

                    -- Check milestones for powerup replenishment (Plus Mode) - once per milestone value per run
                    if self.mode == "plus" and merged.value >= 128 then
                        local m_str = tostring(merged.value)
                        if not self.milestonesReached[m_str] then
                            self.milestonesReached[m_str] = true

                            local function grantRandomPowerup(g)
                                local p = love.math.random(1, 3)
                                if p == 1 then
                                    g.powerups.undo = g.powerups.undo + 1
                                    return "Undo"
                                elseif p == 2 then
                                    g.powerups.swap = g.powerups.swap + 1
                                    return "Swap"
                                else
                                    g.powerups.bomb = g.powerups.bomb + 1
                                    return "Bomb"
                                end
                            end

                            if merged.value == 128 then
                                local name = grantRandomPowerup(self)
                                self:addFloatingNotification("+" .. name, merged.x, merged.y)
                            elseif merged.value == 256 then
                                local name = grantRandomPowerup(self)
                                self.powerups.undo = self.powerups.undo + 1
                                self:addFloatingNotification("+" .. name .. " & +1 Undo", merged.x, merged.y)
                            elseif merged.value == 512 then
                                self.powerups.undo = self.powerups.undo + 1
                                self.powerups.bomb = self.powerups.bomb + 1
                                self.powerups.swap = self.powerups.swap + 1
                                self:addFloatingNotification("All Powerups +1", merged.x, merged.y)
                            elseif merged.value == 1024 then
                                self.powerups.undo = self.powerups.undo + 2
                                self.powerups.bomb = self.powerups.bomb + 2
                                self.powerups.swap = self.powerups.swap + 2
                                self:addFloatingNotification("All Powerups +2", merged.x, merged.y)
                            elseif merged.value == 2048 then
                                self.powerups.undo = self.powerups.undo + 2
                                self.powerups.bomb = self.powerups.bomb + 2
                                self.powerups.swap = self.powerups.swap + 2
                                self:addFloatingNotification("All Powerups +2", merged.x, merged.y)
                            elseif merged.value >= 4096 then
                                self.powerups.undo = self.powerups.undo + 3
                                self.powerups.bomb = self.powerups.bomb + 3
                                self.powerups.swap = self.powerups.swap + 3
                                self:addFloatingNotification("All Powerups +3", merged.x, merged.y)
                            end
                        end
                    end

                    -- Check for win (target tile!)
                    if merged.value == self.targetValue and self.state == Game.STATE_PLAYING and self.mode ~= "timeattack" then
                        self.won = true
                        self.state = Game.STATE_WON
                        local sound = require("sound")
                        sound.playVictory()
                    end

                    if self.mode == "classic" and merged.value >= 2048 and _G.unlockAchievement then
                        _G.unlockAchievement("ach_2048")
                    end

                    if merged.value >= 512 and _G.unlockAchievement and self.mode ~= "huge" then
                        _G.unlockAchievement("ach_merge_512")
                    end

                    if merged.value >= 1024 and _G.unlockAchievement and self.mode ~= "huge" then
                        _G.unlockAchievement("ach_merge_1024")
                    end

                    if merged.value >= 4096 and _G.unlockAchievement and self.mode ~= "huge" then
                        _G.unlockAchievement("ach_4096")
                    end

                    if merged.value >= 1024 and _G.achievements.powerups_used_this_run == 0 and _G.unlockAchievement and self.mode ~= "huge" then
                        _G.unlockAchievement("ach_untouchable")
                    end

                    if self.mode == "plus" and merged.value >= 2048 and _G.unlockAchievement then
                        _G.unlockAchievement("ach_2048_plus")
                    end

                    if merged.value >= 2048 and _G.achievements.powerups_used_this_run == 0 and _G.unlockAchievement and self.mode ~= "huge" then
                        _G.unlockAchievement("ach_untouchable_2048")
                    end

                    if self.mode == "huge" and merged.value >= 2048 and _G.unlockAchievement then
                        _G.unlockAchievement("ach_huge_2048")
                    end
                    if self.mode == "nomercy" and merged.value >= 512 and _G.unlockAchievement then
                        _G.unlockAchievement("ach_nomercy_512")
                    end
                    if self.mode == "goose" and merged.value >= 2048 and _G.unlockAchievement then
                        _G.unlockAchievement("ach_goose_2048")
                    end

                    -- Time Attack: add bonus time for merges (challenging balance)
                    if self.mode == "timeattack" and self.timeLeft then
                        local bonus = 0
                        if merged.value == 32 then
                            bonus = 2
                        elseif merged.value == 64 then
                            bonus = 4
                        elseif merged.value == 128 then
                            bonus = 6
                        elseif merged.value == 256 then
                            bonus = 8
                        elseif merged.value == 512 then
                            bonus = 15
                        elseif merged.value == 1024 then
                            bonus = 25
                        elseif merged.value >= 2048 then
                            bonus = 50
                        end
                        -- Special: hitting 2048 gives a massive bonus + achievement
                        if merged.value == 2048 then
                            if _G.unlockAchievement then
                                _G.unlockAchievement("ach_timeattack_2048")
                            end
                        end
                        self.timeAttackBonus = (self.timeAttackBonus or 0) + bonus
                    end

                    moved = true
                else
                    -- Just move to farthest available position
                    if farthestX ~= x or farthestY ~= y then
                        self:moveTile(tile, farthestX, farthestY)
                        moved = true
                    end
                end
            end
        end
    end

    if moved then
        if _G.stats then
            _G.stats.moves_made = (_G.stats.moves_made or 0) + 1
            if self.score > (_G.stats.highest_score or 0) then
                _G.stats.highest_score = self.score
            end
        end
        -- Apply accumulated time attack bonus (capped at 30s per move for balance)
        if self.mode == "timeattack" and self.timeLeft and (self.timeAttackBonus or 0) > 0 then
            local cap = 30.0
            -- 2048 merge bypasses cap
            local merged_2048 = self.timeAttackBonus >= 50
            local bonus = merged_2048 and self.timeAttackBonus or math.min(self.timeAttackBonus, cap)
            self.timeLeft = math.min(self.totalTime, self.timeLeft + bonus)

            -- Trigger visual feedback (floating text + flash timer)
            self.timePopups = self.timePopups or {}
            table.insert(self.timePopups, {
                text = "+" .. tostring(math.floor(bonus)) .. "s",
                y_offset = 0,
                alpha = 1.0
            })
            self.timerFlashTimer = 0.3

            self.timeAttackBonus = 0
        end
        local pending = {
            gridState = pendingUndoState,
            score = pendingUndoScore,
            rng = pendingUndoRNG
        }
        if _G.undo_mode == "unlimited" then
            table.insert(self.undoHistory, pending)
            if #self.undoHistory > 100 then
                table.remove(self.undoHistory, 1)
            end
            self.canUndo = true
        elseif _G.undo_mode == "classic" then
            self.undoHistory = { pending }
            self.canUndo = true
        else
            self.undoHistory = {}
            self.canUndo = false
        end

        self.animationDuration = 0.12
        if _G.animation_speed == "fast" then
            self.animationDuration = 0.06
        elseif _G.animation_speed == "instant" then
            self.animationDuration = 0
        elseif _G.animation_speed == "slow" then
            self.animationDuration = 0.24
        end

        if self.mode == "goose" then
            self:walkGoose()
        end
        self:addRandomTile()
        if self.mode == "nomercy" then
            self:addRandomTile()
        end
        if self.mode == "goose" then
            self.animationTimer = self.animationDuration * 2
        else
            self.animationTimer = self.animationDuration
        end
        if _G.achievements.powerups_used_this_run == nil then
            _G.achievements.powerups_used_this_run = 0
        end
        if _G.unlockAchievement and self.mode ~= "huge" then
            if self.score >= 1000 then _G.unlockAchievement("ach_score_1k") end
            if self.score >= 2000 then _G.unlockAchievement("ach_score_2k") end
            if self.score >= 5000 then _G.unlockAchievement("ach_score_5k") end
            if self.score >= 7500 then _G.unlockAchievement("ach_score_7k") end
            if self.score >= 10000 then _G.unlockAchievement("ach_score_10k") end
            if self.score >= 25000 then _G.unlockAchievement("ach_score_25k") end
            if self.score >= 50000 then _G.unlockAchievement("ach_score_50k") end
            if self.score >= 100000 then _G.unlockAchievement("ach_score_100k") end
        end
        self:saveGameState()
        -- Check for loss
        if not self:movesAvailable() then
            self.state = Game.STATE_LOST
            local sound = require("sound")
            sound.playGameOver()
        end
    end

    self.moved = moved
    self:saveGameState()
    return moved
end

function Game:walkGoose()
    local gooseTile = nil
    self.grid:eachCell(function(x, y, tile)
        if tile and tile.value == "goose" then
            gooseTile = tile
        end
    end)

    if not gooseTile then return end

    local adjacentEmpties = {}
    local dirs = {
        {x = -1, y = 0},
        {x = 1, y = 0},
        {x = 0, y = -1},
        {x = 0, y = 1}
    }
    for _, dir in ipairs(dirs) do
        local nx = gooseTile.x + dir.x
        local ny = gooseTile.y + dir.y
        if self.grid:withinBounds(nx, ny) and self.grid:cellAvailable(nx, ny) then
            table.insert(adjacentEmpties, {x = nx, y = ny})
        end
    end

    local target
    if #adjacentEmpties > 0 then
        target = adjacentEmpties[love.math.random(1, #adjacentEmpties)]
    else
        target = self.grid:randomAvailableCell()
    end

    if target then
        gooseTile:savePosition()
        self:moveTile(gooseTile, target.x, target.y)
    end
end

function Game:movesAvailable()
    if self.grid:cellsAvailable() then
        return true
    end

    -- Check if any adjacent tiles can merge
    for x = 1, self.size do
        for y = 1, self.size do
            local tile = self.grid:cellContent(x, y)
            if tile then
                for dir = 0, 3 do
                    local vec = vectors[dir]
                    local nx, ny = x + vec.x, y + vec.y
                    local other = self.grid:cellContent(nx, ny)
                    if other and other.value == tile.value then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function Game:undo()
    if _G.undo_mode == "disabled" then return end
    if not self.canUndo or #self.undoHistory == 0 then return end

    if self.mode == "plus" then
        if self.powerups.undo <= 0 then return end
        self.powerups.undo = self.powerups.undo - 1
    end
    if _G.achievements.powerups_used_this_run then
        _G.achievements.powerups_used_this_run = _G.achievements.powerups_used_this_run + 1
        save.saveAchievements(_G.achievements)
    end
    if _G.stats then
        _G.stats.undos_used = (_G.stats.undos_used or 0) + 1
        save.saveStats(_G.stats)
    end

    local state = table.remove(self.undoHistory)
    if _G.undo_mode == "classic" or #self.undoHistory == 0 then
        self.canUndo = false
    end

    -- Snapshot the current tiles before restoring the old grid
    local current_cells = {}
    for x = 1, self.size do
        current_cells[x] = {}
        for y = 1, self.size do
            current_cells[x][y] = self.grid.cells[x][y]
        end
    end

    self.grid:restoreState(state.gridState)
    self.score = state.score

    if state.rng then
        love.math.setRandomState(state.rng)
    end

    -- Reset game state if we were lost/won
    if self.state == Game.STATE_LOST then
        self.state = self.won and Game.STATE_ENDLESS or Game.STATE_PLAYING
    elseif self.state == Game.STATE_WON then
        self.state = Game.STATE_PLAYING
        self.won = false
    end

    -- Clear animation states from newly restored grid
    self.grid:eachCell(function(x, y, tile)
        if tile then
            tile.isNew = false
            tile.isMerged = false
            tile.undoSourcePosition = nil
        end
    end)

    -- Apply reverse animation data using the restored tiles' history
    for x = 1, self.size do
        for y = 1, self.size do
            local c_tile = current_cells[x][y]
            if c_tile then
                if c_tile.isMerged and c_tile.mergedFrom then
                    local t1 = c_tile.mergedFrom[1]
                    local t2 = c_tile.mergedFrom[2]
                    if t1 and t1.previousPosition then
                        local r_t1 = self.grid:cellContent(t1.previousPosition.x, t1.previousPosition.y)
                        if r_t1 then r_t1.undoSourcePosition = {x = x, y = y} end
                    end
                    if t2 and t2.previousPosition then
                        local r_t2 = self.grid:cellContent(t2.previousPosition.x, t2.previousPosition.y)
                        if r_t2 then r_t2.undoSourcePosition = {x = x, y = y} end
                    end
                elseif not c_tile.isNew then
                    if c_tile.previousPosition then
                        local r_t = self.grid:cellContent(c_tile.previousPosition.x, c_tile.previousPosition.y)
                        if r_t then r_t.undoSourcePosition = {x = x, y = y} end
                    end
                end
            end
        end
    end

    self.animationDuration = 0.12
    if _G.animation_speed == "fast" then
        self.animationDuration = 0.06
    elseif _G.animation_speed == "instant" then
        self.animationDuration = 0
    elseif _G.animation_speed == "slow" then
        self.animationDuration = 0.24
    end

    -- Trigger animation timer
    self.animationTimer = self.animationDuration

    self:saveGameState()
end

function Game:continueGame()
    -- Continue playing after winning (endless mode)
    if self.state == Game.STATE_WON then
        self.state = Game.STATE_ENDLESS
        self:saveGameState()
    end
end

function Game:restart()
    self.grid:clear()
    self.score = 0
    self.state = Game.STATE_PLAYING
    self.won = false
    self.canUndo = false
    self.undoHistory = {}
    self.animationTimer = 0
    if self.mode == "plus" then
        local initial_powerups = _G.cheat_max_powerups and 99 or 1
        self.powerups = { undo = initial_powerups, bomb = initial_powerups, swap = initial_powerups }
        self.milestonesReached = {}
    end
    -- Reset Time Attack timer
    if self.mode == "timeattack" then
        self.totalTime = tonumber(_G.time_attack_time) or 60.0
        self.timeLeft = self.totalTime
        self.timeAttackBonus = 0
        self.shownUrgentWarning = false
        self.timesUp = false
        self.timePopups = {}
        self.timerFlashTimer = 0
    end
    self:addStartTiles()
    if _G.stats then
        _G.stats.games_played = (_G.stats.games_played or 0) + 1
        if self.mode == "classic" then
            _G.stats.classic_games = (_G.stats.classic_games or 0) + 1
        elseif self.mode == "plus" then
            _G.stats.plus_games = (_G.stats.plus_games or 0) + 1
        else
            _G.stats.arcade_games = (_G.stats.arcade_games or 0) + 1
        end
        save.saveStats(_G.stats)
    end
    if _G.achievements then
        _G.achievements.powerups_used_this_run = 0
        save.saveAchievements(_G.achievements)
    end
    self:saveGameState()
end

function Game:togglePause()
    if self.state == Game.STATE_PLAYING or self.state == Game.STATE_ENDLESS then
        self.prevState = self.state
        self.state = Game.STATE_PAUSED
    elseif self.state == Game.STATE_PAUSED then
        self.state = self.prevState or (self.won and Game.STATE_ENDLESS or Game.STATE_PLAYING)
    else
        self:restart()
    end
end

function Game:cancelPause()
    if self.state == Game.STATE_PAUSED then
        self.state = self.prevState or (self.won and Game.STATE_ENDLESS or Game.STATE_PLAYING)
    end
end

-- ============================================================================
-- Targeting / Powerups
-- ============================================================================

function Game:startBombTargeting()
    if self.mode ~= "plus" or self.powerups.bomb <= 0 then return end
    if not self:isPlaying() then return end
    self.state = Game.STATE_TARGETING_BOMB
    self.cursorX = 2
    self.cursorY = 2
end

function Game:startSwapTargeting()
    if self.mode ~= "plus" or self.powerups.swap <= 0 then return end
    if not self:isPlaying() then return end
    self.state = Game.STATE_TARGETING_SWAP_1
    self.cursorX = 2
    self.cursorY = 2
    self.swapTarget = nil
end

function Game:moveCursor(dx, dy)
    local nx = self.cursorX + dx
    local ny = self.cursorY + dy
    if nx >= 1 and nx <= self.size and ny >= 1 and ny <= self.size then
        self.cursorX = nx
        self.cursorY = ny
    end
end

function Game:cancelTargeting()
    self.state = self.won and Game.STATE_ENDLESS or Game.STATE_PLAYING
    self.swapTarget = nil
end

function Game:confirmTarget()
    local cx, cy = self.cursorX, self.cursorY

    if self.state == Game.STATE_TARGETING_BOMB then
        if self.grid.cells[cx][cy] then
            -- Delete the tile
            local pending = {
                gridState = self.grid:saveState(),
                score = self.score,
                rng = love.math.getRandomState()
            }
            if _G.undo_mode == "unlimited" then
                table.insert(self.undoHistory, pending)
                if #self.undoHistory > 100 then
                    table.remove(self.undoHistory, 1)
                end
                self.canUndo = true
            elseif _G.undo_mode == "classic" then
                self.undoHistory = { pending }
                self.canUndo = true
            else
                self.undoHistory = {}
                self.canUndo = false
            end

            local t = self.grid.cells[cx][cy]
            self.bombAnimation = {x = cx, y = cy, tileValue = t.value, timer = 0.15, duration = 0.15}

            self.grid.cells[cx][cy] = nil
            self.powerups.bomb = self.powerups.bomb - 1
            if _G.stats then
                _G.stats.bombs_used = (_G.stats.bombs_used or 0) + 1
            end

            if _G.achievements.bombs_used then
                _G.achievements.bombs_used = _G.achievements.bombs_used + 1
                if _G.unlockAchievement then
                    if _G.achievements.bombs_used >= 1 then
                        _G.unlockAchievement("ach_first_bomb")
                    end
                    if _G.achievements.bombs_used >= 10 then
                        _G.unlockAchievement("ach_demolition")
                    end
                end
            end
            if _G.achievements.powerups_used_this_run then
                _G.achievements.powerups_used_this_run = _G.achievements.powerups_used_this_run + 1
            end
            save.saveAchievements(_G.achievements)

            self.state = self.won and Game.STATE_ENDLESS or Game.STATE_PLAYING
            self:saveGameState()
        end
    elseif self.state == Game.STATE_TARGETING_SWAP_1 then
        if self.grid.cells[cx][cy] then
            self.swapTarget = {x = cx, y = cy}
            self.state = Game.STATE_TARGETING_SWAP_2
        end
    elseif self.state == Game.STATE_TARGETING_SWAP_2 then
        if (self.swapTarget.x ~= cx or self.swapTarget.y ~= cy) then
            local pending = {
                gridState = self.grid:saveState(),
                score = self.score,
                rng = love.math.getRandomState()
            }
            if _G.undo_mode == "unlimited" then
                table.insert(self.undoHistory, pending)
                if #self.undoHistory > 100 then
                    table.remove(self.undoHistory, 1)
                end
                self.canUndo = true
            elseif _G.undo_mode == "classic" then
                self.undoHistory = { pending }
                self.canUndo = true
            else
                self.undoHistory = {}
                self.canUndo = false
            end

            local t1 = self.grid.cells[self.swapTarget.x][self.swapTarget.y]
            local t2 = self.grid.cells[cx][cy]

            -- Swap them in grid
            self.grid.cells[self.swapTarget.x][self.swapTarget.y] = t2
            self.grid.cells[cx][cy] = t1

            -- Start animation
            self.swapAnimation = {
                t1 = t1 and {val = t1.value, startX = self.swapTarget.x, startY = self.swapTarget.y, endX = cx, endY = cy} or nil,
                t2 = t2 and {val = t2.value, startX = cx, startY = cy, endX = self.swapTarget.x, endY = self.swapTarget.y} or nil,
                t1Ref = t1,
                t2Ref = t2,
                timer = 0.20,
                duration = 0.20
            }
            if t1 then t1.isSwapping = true end
            if t2 then t2.isSwapping = true end

            -- Update tile coordinates
            if t1 then t1:setPosition(cx, cy) end
            if t2 then t2:setPosition(self.swapTarget.x, self.swapTarget.y) end

            self.powerups.swap = self.powerups.swap - 1
            if _G.stats then
                _G.stats.swaps_used = (_G.stats.swaps_used or 0) + 1
            end
            self.swapTarget = nil

            if _G.achievements.powerups_used_this_run then
                _G.achievements.powerups_used_this_run = _G.achievements.powerups_used_this_run + 1
            end
            save.saveAchievements(_G.achievements)

            self.state = self.won and Game.STATE_ENDLESS or Game.STATE_PLAYING
            self:saveGameState()
        else
            -- Cannot swap with self; cancel
            self.swapTarget = nil
            self.state = Game.STATE_TARGETING_SWAP_1
        end
    end
end

function Game:update(dt)
    if self.state == Game.STATE_PLAYING or self.state == Game.STATE_ENDLESS then
        if _G.stats then
            _G.stats.time_played = (_G.stats.time_played or 0) + dt
        end
    end

    if self.animationTimer > 0 then
        self.animationTimer = self.animationTimer - dt
        if self.animationTimer < 0 then
            self.animationTimer = 0
        end
    end

    -- Time Attack: countdown
    if self.mode == "timeattack" and self.timeLeft ~= nil then
        if self.state == Game.STATE_PLAYING or self.state == Game.STATE_ENDLESS then
            self.timeLeft = self.timeLeft - dt
            if self.timeLeft <= 10 and not self.shownUrgentWarning then
                self.shownUrgentWarning = true
                -- Toast is shown by renderer's pulse; no explicit toast here to avoid spam
            end
            if self.timeLeft <= 0 then
                self.timeLeft = 0
                self.state = Game.STATE_LOST
                self.timesUp = true  -- flag for renderer to show "Time's Up!"
                local sound = require("sound")
                sound.playGameOver()
                self:saveGameState()  -- saves high score only (saveGameState returns early for timeattack)
                save.saveHighScore(self.highScore, self.mode)
            end
        end
    end

    if self.bombAnimation then
        self.bombAnimation.timer = self.bombAnimation.timer - dt
        if self.bombAnimation.timer <= 0 then
            self.bombAnimation = nil
        end
    end

    if self.swapAnimation then
        self.swapAnimation.timer = self.swapAnimation.timer - dt
        if self.swapAnimation.timer <= 0 then
            if self.swapAnimation.t1Ref then self.swapAnimation.t1Ref.isSwapping = false end
            if self.swapAnimation.t2Ref then self.swapAnimation.t2Ref.isSwapping = false end
            self.swapAnimation = nil
        end
    end

    -- Update floating time popups
    if self.timePopups then
        for i = #self.timePopups, 1, -1 do
            local p = self.timePopups[i]
            p.y_offset = p.y_offset - dt * 35 * _G.scale
            p.alpha = p.alpha - dt * 1.8
            if p.alpha <= 0 then
                table.remove(self.timePopups, i)
            end
        end
    end

    -- Update timer flash
    if self.timerFlashTimer and self.timerFlashTimer > 0 then
        self.timerFlashTimer = self.timerFlashTimer - dt
        if self.timerFlashTimer < 0 then
            self.timerFlashTimer = 0
        end
    end

    if self.floatingNotifications then
        for i = #self.floatingNotifications, 1, -1 do
            local n = self.floatingNotifications[i]
            n.timer = n.timer - dt
            if n.timer <= 0 then
                table.remove(self.floatingNotifications, i)
            end
        end
    end
end

function Game:addFloatingNotification(text, col, row)
    if not self.floatingNotifications then
        self.floatingNotifications = {}
    end
    table.insert(self.floatingNotifications, {
        text = text,
        col = col,
        row = row,
        timer = 1.0,
        max_life = 1.0
    })
end

function Game:getAnimationProgress()
    if self.animationDuration <= 0 then return 1 end
    local progress = 1 - (self.animationTimer / self.animationDuration)
    return math.max(0, math.min(1, progress))
end

function Game:isAnimating()
    return self.animationTimer > 0
end

function Game:isPlaying()
    return self.state == Game.STATE_PLAYING or self.state == Game.STATE_ENDLESS or
           self.state == Game.STATE_TARGETING_BOMB or self.state == Game.STATE_TARGETING_SWAP_1 or self.state == Game.STATE_TARGETING_SWAP_2
end

return Game
