
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky03.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        switch(pokus){
            [1] = function()
                room.uvod = 0
            end,
            [2] = function()
                room.uvod = 1
            end,
            default = function()
                room.uvod = random(4)
            end,
        }
        room.setk = 0
        if pokus == 1 then
            room.prehnala = 22
        else
            room.prehnala = 21
        end

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.uvod < 3 then
                    switch(room.uvod){
                        [0] = function()
                            addm(random(30), "sch-m-spadlo")
                        end,
                        [1] = function()
                            addm(random(30), "sch-m-spadlo")
                            addv(random(30), "sch-v-lastura")
                        end,
                        [2] = function()
                            addv(random(30), "sch-v-lastura")
                        end,
                    }
                    room.uvod = 3
                elseif plzik.X >= room.prehnala then
                    addm(random(40), "sch-m-moc"..random(3))
                    room.prehnala = 100
                elseif room.setk == 0 and plzik.X == 10 and plzik.Y == 14 then
                    addv(random(40), "sch-v-setkani")
                    room.setk = 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_plzik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        plzik.stav = 0

        return function()
            if plzik.dir ~= dir_no then
                plzik.stav = 15
            end
            if isWater(plzik.X + 1, plzik.Y + 2) then
                plzik.stav = 10
            end
            switch(plzik.stav){
                [0] = function()
                    plzik.afaze = 0
                    if random(100) < 2 then
                        plzik.stav = plzik.stav + 1
                    end
                end,
                [1] = function()
                    plzik.afaze = 5
                    plzik.stav = plzik.stav + 1
                end,
                [2] = function()
                    plzik.afaze = random(3) + 1
                    plzik.stav = plzik.stav + 1
                end,
                [3] = function()
                    if odd(game_getCycles()) then
                        if random(100) < 20 then
                            plzik.afaze = random(3) + 1
                        end
                    end
                    if random(1000) < 5 then
                        plzik.stav = plzik.stav + 1
                    end
                end,
                [4] = function()
                    plzik.afaze = 5
                    plzik.stav = 0
                end,
                [10] = function()
                    plzik.afaze = 4
                    if isWater(plzik.X + 1, plzik.Y + 2) then
                        plzik.stav = 21 + random(20)
                    end
                end,
                [15] = function()
                    plzik.afaze = 5
                    if plzik.dir == dir_no then
                        plzik.stav = 21 + random(20)
                    end
                end,
                [20] = function()
                    plzik.stav = 3
                end,
                default = function()
                    if plzik.stav >= 21 or plzik.stav <= 100 then 
                        plzik.stav = plzik.stav - 1
                    end
                end,
            }
            plzik:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snecek()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        snecek.cinnost = 0
        snecek.sour = random(6) * 3
        snecek.smer = random(2) * 2 - 1

        return function()
            switch(snecek.cinnost){
                [0] = function()
                    if random(100) < 1 then
                        snecek.cinnost = 1
                    elseif random(100) < 2 then
                        snecek.cinnost = 2
                    end
                end,
                [1] = function()
                    if random(100) < 3 then
                        snecek.cinnost = 0
                    end
                end,
                [2] = function()
                    if math.mod(snecek.sour, 3) == 0 and random(100) < 30 then
                        snecek.cinnost = 0
                    elseif math.mod(snecek.sour, 3) == 0 and random(100) < 10 then
                        snecek.cinnost = 3
                    elseif random(100) < 2 or snecek.smer == -1 and snecek.sour == 0 or snecek.smer == 1 and snecek.sour == 15 then
                        snecek.smer = -snecek.smer
                    elseif snecek.smer < 0 then
                        snecek.sour = snecek.sour - 1
                    elseif snecek.smer > 0 then
                        snecek.sour = snecek.sour + 1
                    end
                end,
                [3] = function()
                    if random(100) < 3 then
                        snecek.cinnost = 2
                    end
                end,
            }
            switch(snecek.cinnost){
                [0] = function()
                    if snecek.smer < 0 then
                        snecek.afaze = 15 - snecek.sour
                    else
                        snecek.afaze = 22 + snecek.sour
                    end
                end,
                [2] = function()
                    if snecek.smer < 0 then
                        snecek.afaze = 15 - snecek.sour
                    else
                        snecek.afaze = 22 + snecek.sour
                    end
                end,
                [1] = function()
                    if snecek.smer < 0 then
                        snecek.afaze = 21 - math.floor(snecek.sour / 3)
                    else
                        snecek.afaze = 38 + math.floor(snecek.sour / 3)
                    end
                end,
                [3] = function()
                    if snecek.smer < 0 then
                        snecek.afaze = 21 - math.floor(snecek.sour / 3)
                    else
                        snecek.afaze = 38 + math.floor(snecek.sour / 3)
                    end
                end,
            }
            snecek:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_plzik()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_snecek()
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

