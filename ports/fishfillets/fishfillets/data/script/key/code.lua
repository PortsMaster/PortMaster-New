local bore = -5

local function move_cactus()
    if small.dir ~= dir_no then
        addm(0, "cactus-0small")
        addv(1, "cactus-1small")
        addm(2, "cactus-2small")
    else
        addv(0, "cactus-0big")
        addm(1, "cactus-1big")
        addv(2, "cactus-2big")
    end
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky09.ogg")
    local num_starts = getRestartCount()
    -- Saved variables
    room.was_intro = false
    room.moved_cactus = false
    room.moved_coral = false
    room.keyupdown = 0

    -- -------------------------------------------------------------
    local function prog_init_room()
        return function()
            if num_starts < 3 and not room.was_intro then
                room.was_intro = true
                addm(20, "start-0")
                addv(27, "start-1")
                addm(34, "start-2")
                addv(41, "start-3")
                addm(48, "start-4")
            end

            if no_dialog() and item_named_cactus.dir ~= dir_no and not room.moved_cactus then
                move_cactus()
                room.moved_cactus = true
            end
            if item_named_coral.dir ~= dir_no then
                room.moved_coral = true
            end

            if item_named_A.Y == 1 and item_named_B.Y == 1 and item_named_C.Y == 1 then
                if math.mod(room.keyupdown, 2) == 0 then
                    room.keyupdown = room.keyupdown + 1
                    if room.keyupdown < 2 then
                        addv(0, "up-0-0")
                        addm(7, "up-0-1")
                        addm(14, "up-0-2")
                        addv(21, "up-0-3")
                    else
                        addv(0, "up-1-0")
                        addm(7, "up-1-1")
                    end
                end
            else
                if math.mod(room.keyupdown, 2) == 1 then
                    room.keyupdown = room.keyupdown + 1
                    if room.keyupdown < 3 then
                        addv(0, "down-0-0")
                        addm(7, "down-0-1")
                    else
                        addv(0, "down-1-0")
                        addm(7, "down-1-1")
                    end
                end
            end
            if no_dialog() and random(200) < 4 then
                bore = bore + 1
                if bore > 10 then
                    switch(random(7)){
                        [0] = function()
                            addv(0, "rd-0-0")
                            addm(7, "rd-0-1")
                        end,
                        [1] = function()
                            addv(0, "rd-1-0")
                            addm(5, "rd-1-1")
                            addv(14, "rd-1-2")
                            addm(21, "rd-1-3")
                        end,
                        [2] = function()
                            addm(0, "rd-2-0")
                            addv(7, "rd-2-1")
                        end,
                        [3] = function()
                            addm(0, "rd-3-0")
                            addv(7, "rd-3-1")
                            addm(14, "rd-3-2")
                            addv(21, "rd-3-3")
                            addm(28, "rd-3-4")
                            addv(35, "rd-3-5")
                        end,
                        [4] = function()
                            addm(0, "rd-4-0")
                            addv(7, "rd-4-1")
                        end,
                        [5] = function()
                            if not room.moved_coral then
                                addm(0, "rdopt-0-0")
                                addv(7, "rdopt-0-1")
                            end
                        end,
                        [6] = function()
                            if icicle.Y <= 1 then
                                addm(0, "rdopt-1-0")
                                addv(7, "rdopt-1-1")
                                addm(14, "rdopt-1-2")
                                addv(21, "rdopt-1-3")
                            end
                        end,
                    }
                    bore=0
                end
            end
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    return update_table
end
local update_table = prog_init()


-- -----------------------------------------------------------------
-- Update
-- -----------------------------------------------------------------
function prog_update()
    for key, subupdate in pairs(update_table) do
        subupdate()
    end
end

