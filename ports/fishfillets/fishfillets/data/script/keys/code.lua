local bore = -5

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky06.ogg")
    local num_starts = getRestartCount()
    room.was_intro = false

    -- -------------------------------------------------------------
    local function prog_init_room()
        return function()
            local pocetodemk = 0
            for i = 0,3 do
                if (klic[i].Y <= 10 and klic[i].dir == dir_up) or (klic[i].afaze ~= 0 and klic[i].afaze ~= 3) then
                    klic[i].afaze = klic[i].afaze+1
                    if klic[i].afaze == 6 then klic[i].afaze = 0 end
                    klic[i]:updateAnim()
                    pocetodemk = pocetodemk+1
                end
            end
            if pocetodemk > 0 and not klic[0]:isTalking() then
                klic[0]:talk("unlocking-"..random(4), pocetodemk*VOLUME_FULL/4)
            end

            if num_starts < 3 and not room.was_intro then
                room.was_intro = true
                addm(20, "init-0-0")
                addv(7, "init-0-1")
                addm(randint(9, 20), "init-0-2")
                addv(randint(9, 20), "init-0-3")
                addm(randint(9, 20), "init-0-4")
                addv(randint(9, 20), "init-0-5")
                addm(randint(9, 20), "init-0-6")
                addv(randint(9, 20), "init-0-7")
            end

            if no_dialog() and random(200) < 4 then
                bore = bore + 1
                if bore > 10 then
                switch(random(8)){
                    [0] = function()
                        addm(0, "rand-0-0")
                        addv(9, "rand-0-1")
                        addm(16, "rand-0-2")
                        addv(randint(9, 20), "rand-0-3")
                        addm(randint(9, 20), "rand-0-4")
                        local get1 = random(6)
                        local get2 = random(5)
                        if get1 <= get2 then
                            get2 = get2 + 1
                        end
                        addv(20 + randint(9, 20), "rand-0-5-"..get1)
                        addm(randint(9, 20), "rand-0-6")
                        addv(20 + randint(9, 20), "rand-0-5-"..get2)
                        addm(randint(9, 20), "rand-0-7")
                    end,
                    [1] = function()
                        addv(0, "rand-1-0")
                        addm(7, "rand-1-1")
                    end,
                    [2] = function()
                        addv(0, "rand-2-0")
                    end,
                    [3] = function()
                        addm(0, "rand-3-0")
                        addv(7, "rand-3-1")
                        addm(14, "rand-3-2")
                        addv(randint(9, 20), "rand-3-3-"..random(2))
                        addm(randint(9, 20), "rand-3-4-"..random(2))
                    end,
                    [4] = function()
                        addv(0, "rand-4-0")
                        addm(7, "rand-4-1")
                        addv(14, "rand-4-2")
                        addm(randint(9, 20), "rand-4-3")
                        addv(randint(9, 20), "rand-4-4-"..random(3))
                        addm(randint(9, 20), "rand-4-5")
                        addv(randint(9, 20), "rand-4-6")
                    end,
                    [5] = function()
                        addv(0, "rand-5-0")
                        addm(7, "rand-5-1")
                    end,
                    [6] = function()
                        addv(0, "rand-6-0")
                        addm(7, "rand-6-1")
                    end,
                    [7] = function()
                        addv(0, "rand-7-0")
                        addm(7, "rand-7-1")
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

