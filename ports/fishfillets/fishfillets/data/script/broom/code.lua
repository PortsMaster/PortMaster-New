
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
        room.namet = 0

        return function()
            if metla.X == 12 and (metla.Y == 12 or metla.Y == 13 or metla.Y == 14) and not isReady(big) and not small:isOut() then
                roompole[0] = 1
            end
            if isReady(small) and isReady(big) and no_dialog() then
                if room.uvod == 0 then
                    addm(random(40) + 10, "kos-m-uklid" ..random(3))
                    addv(random(20), "kos-v-poradek"..random(3))
                    room.uvod = random(150) + 50
                elseif room.uvod == 2 then
                    room.uvod = 1
                    switch(roompole[0]){
                        [0] = function()
                            pom1 = random(2)
                        end,
                        [1] = function()
                            pom1 = 2
                            roompole[0] = roompole[0] + 1
                        end,
                        [2] = function()
                            pom1 = random(5)
                        end,
                    }
                    if pom1 < 3 then
                        addv(0, "kos-v-koste"..pom1)
                    end
                elseif room.namet == 0 and random(100) < 3 and metla.Y >= 15 then
                    room.namet = 1
                    pom1 = random(3)
                    if pom1 > 0 then
                        pom1 = pom1 + 1
                    end
                    addm(40, "kos-m-zamet"..pom1)
                    if random(100) < 70 then
                        addm(random(20) + 10, "kos-m-zamet1")
                    end
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_metla()
        return function()
            if odd(game_getCycles()) then
                switch(metla.afaze){
                    [0] = function()
                        if metla.dir == dir_left or metla.dir == dir_right then
                            metla.afaze = 2
                        end
                    end,
                    [1] = function()
                        if metla.dir == dir_left or metla.dir == dir_right then
                            metla.afaze = 3 - metla.afaze
                        else
                            metla.afaze = 0
                        end
                    end,
                    [2] = function() 
                        if metla.dir == dir_left or metla.dir == dir_right then
                            metla.afaze = 3 - metla.afaze
                        else
                            metla.afaze = 0
                        end
                    end,
                }
            end
            metla:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_metla()
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

