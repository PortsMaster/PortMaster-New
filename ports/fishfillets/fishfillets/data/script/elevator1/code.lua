
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky01.ogg")
    local pokus = getRestartCount()
    local roompole = createArray(1)


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.lebzna = 0
        room.lastura = 0
        room.jizdam = random(15) + 3
        room.jizdav = random(50) + 10
        if pokus > 1 then
            if random(100) < 30 then
                room.uvod = 1
            end
            if random(100) < 50 then
                room.lastura = 1
            end
            if random(100) < 60 then
                room.lebzna = 1
            end
            if random(100) < 20 then
                room.jizdam = -1
            end
            if random(100) < 30 then
                room.jizdav = -1
            end
        end
        room.huhuh = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.uvod == 0 then
                    addv(random(20) + 50, "zd1-v-civil")
                    switch(roompole[0]){
                        [0] = function()
                            addm(random(10), "zd1-m-dolu")
                        end,
                        [1] = function()
                            addm(random(10), "zd1-m-tlac")
                            roompole[0] = roompole[0] + 1
                        end,
                        [2] = function()
                            if random(2) == 0 then
                                addm(random(10), "zd1-m-tlac")
                            else
                                addm(random(10), "zd1-m-dolu")
                            end
                        end,
                    }
                    room.uvod = 1
                end
                if room.lastura == 0 and look_at(small, shelka) and math.abs(ydist(small, shelka)) < 3 and random(100) < 1 then
                    if random(2) == 0 then
                        addm(0, "zd1-m-last")
                    else
                        addm(0, "zd1-m-poved")
                    end
                    if random(2) == 0 then
                        addv(random(10), "zd1-v-talis")
                    else
                        addv(random(3), "zd1-v-styd")
                    end
                    room.lastura = 1
                elseif room.lebzna == 0 and look_at(big, llebka) and math.abs(ydist(big, llebka)) < 3 and random(100) < 1 then
                    addv(20, "zd1-v-lebka")
                    addm(random(8), "zd1-m-stejne")
                    room.lebzna = 1
                elseif small.jede == room.jizdam then
                    addm(0, "zd1-m-cesta")
                    room.jizdam = -1
                elseif big.jede == room.jizdav then
                    addv(0, "zd1-v-krecek")
                    addm(3, "zd1-m-slap")
                    room.jizdav = -1
                elseif random(1000) < 8 then
                    pom1 = room.huhuh
                    if room.huhuh == 0 then
                        room.huhuh = random(3) + 1
                    else
                        room.huhuh = random(4) + 1
                    end
                    if pom1 == room.huhuh then
                        room.huhuh = 5
                    end
                    planDialogSet(5, "zd1-x-huhu"..room.huhuh, 101, dedek, "mluvi")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_vytah()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        --NOTE: double rope
        game_addDecor("rope", vytah.index, stroj.index, 43, 0, 58, 27)
        game_addDecor("rope", vytah.index, stroj.index, 43 + 3, 0, 58 + 3, 27)

        return function()
            if vytah.dir == dir_up then
                if roompole[0] == 0 then
                    roompole[0] = 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_stroj()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        return function()
            if stroj.X == vytah.X - 1 then
                if stroj.dir == dir_no and vytah.dir == dir_down then
                    pom1 = 2
                elseif stroj.dir == dir_up and vytah.dir == dir_no then
                    pom1 = 1
                elseif stroj.dir == dir_no and vytah.dir == dir_up then
                    pom1 = -1
                elseif stroj.dir == dir_down and vytah.dir == dir_no then
                    pom1 = -2
                else
                    pom1 = 0
                end
                stroj.afaze = stroj.afaze + pom1
                if stroj.afaze > 5 then
                    stroj.afaze = stroj.afaze - 6
                elseif stroj.afaze < 0 then
                    stroj.afaze = stroj.afaze + 6
                end
            end

            stroj:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlavicka()
        return function()
            if hlavicka.afaze == 0 and random(100) < 2 or hlavicka.afaze ~= 0 and random(100) < 5 then
                hlavicka.afaze = random(3)
            end

            hlavicka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dedek()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dedek.mluvi = 0

        return function()
            if dedek.mluvi ~= 0 then
                dedek.afaze = random(2) + 1
            else
                dedek.afaze = 0
            end

            dedek:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        small.jede = 0

        return function()
            if vytah.dir == dir_up and small.X >= vytah.X and small.X < vytah.X + 4 and small.Y > vytah.Y and small.Y < vytah.Y + 6 then
                small.jede = small.jede + 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        big.jede = 0

        return function()
            if vytah.dir == dir_up and big.X >= vytah.X and big.X < vytah.X + 3 and big.Y > vytah.Y and big.Y < vytah.Y + 5 then
                big.jede = big.jede + 1
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
    subinit = prog_init_vytah()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_stroj()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlavicka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dedek()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_small()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_big()
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

