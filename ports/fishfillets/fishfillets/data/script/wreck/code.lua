
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky02.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.ooceli = 0
        room.maladole = 0
        room.velkadole = random(2)

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.uvod == 0 then
                    adddel(random(15) + 10)
                    switch(random(5)){
                        [0] = function()
                            addv(0, "pot-v-slus")
                            addm(random(8), "pot-m-dik")
                        end,
                        [1] = function()
                            addv(0, "pot-v-cepic")
                            addm(random(8), "pot-m-klob")
                        end,
                        [2] = function()
                            addv(0, "pot-v-hlave")
                            addm(random(8), "pot-m-zima")
                        end,
                        [3] = function()
                            addm(0, "pot-m-pujc")
                            addv(random(8), "pot-v-leda")
                        end,
                        [4] = function()
                            addm(0, "pot-m-velik")
                            addv(random(8), "pot-v-kras")
                        end,
                    }
                    if pokus == 1 or random(100) < 15 then
                        room.uvod = 1
                    else
                        room.uvod = 2
                    end
                elseif room.uvod == 1 then
                    addv(20 + random(30), "pot-v-lod")
                    addm(9, "pot-m-soud")
                    addv(2, "pot-v-jmeno")
                    adddel(10)
                    room.uvod = 2
                elseif room.ooceli == 0 and (big.X == 16 and big.Y == 3 and big:isLeft() or big.X < 16 and big.Y == 4) then
                    switch(random(2)){
                        [0] = function()
                            addv(0, "pot-v-nehnu")
                        end,
                        [1] = function()
                            addv(0, "pot-v-trub")
                        end,
                    }
                    switch(random(2)){
                        [0] = function()
                            addm(15, "pot-m-nezb")
                        end,
                        [1] = function()
                            addm(15, "pot-m-dovn")
                        end,
                    }
                    room.ooceli = 1
                elseif room.maladole == 0 and small.Y >= 12 and random(100) < 5 then
                    switch(random(2)){
                        [0] = function()
                            addm(5, "pot-m-zatuch")
                        end,
                        [1] = function()
                            addm(5, "pot-m-moc")
                        end,
                    }
                    if random(100) < 50 or pokus == 1 then
                        addv(random(10), "pot-v-plav")
                    end
                    room.maladole = 1
                elseif room.velkadole == 0 and big.Y > 11 then
                    addv(random(10), "pot-v-nikdo")
                    room.velkadole = 1
                elseif room.velkadole < 2 and big.Y >= 14 and not big:isLeft() and random(100) < 8 then
                    if small.Y < 14 or random(100) < 40 then
                        addm(5, "pot-m-vidis")
                        addv(random(3), "pot-v-vidim")
                    else
                        addv(5, "pot-v-ponur")
                        addm(random(5), "pot-m-hnil")
                    end
                    room.velkadole = 2
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_meduza()
        return function()
            meduza.afaze = random(3)
            meduza:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_meduza()
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

