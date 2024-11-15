
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky06.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.olebce = 0
        room.odrackovi = 0
        if pokus > 1 and random(100) < 50 then
            room.odrackovi = 1
        end
        room.osklebakovi = random(2000) + 500
        room.osklebu = 0
        room.opadu = 0
        if pokus == 1 then
            room.uvod = 1
        else
            room.uvod = random(3)
        end

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                pom1 = 0
                for key, model in pairs(getModelsTable()) do
                    if model ~= konik then
                        if model.dir == dir_down and model.Y >= 10 then
                            if model:getW() + model:getH() == 3 then
                                pom1 = pom1 + 1
                            end
                        end
                    end
                end
                if room.osklebakovi > 0 then
                    room.osklebakovi = room.osklebakovi - 1
                end
                if room.uvod == 1 then
                    room.uvod = 0
                    addm(random(40) + 20, "bot-m-vidis")
                    addv(random(10), "bot-v-uveznen"..random(2))
                    addm(random(50) + 10, "bot-m-zajem")
                    addv(random(10), "bot-v-podivat")
                elseif room.uvod == 2 and small.Y <= 9 then
                    room.uvod = 0
                    addm(random(40) + 20, "bot-m-vidis")
                    addv(random(10), "bot-v-uveznen"..random(2))
                elseif room.olebce == 0 and dist(small, lebzna) < 4 then
                    room.olebce = 1
                    switch(random(2)){
                        [0] = function()
                            addv(5, "bot-v-lebka")
                        end,
                        [1] = function()
                            addm(5, "bot-m-vidim")
                        end,
                    }
                elseif room.odrackovi == 0 and look_at(small, zlaty) and dist(small, zlaty) < 4 and random(100) < 6 then
                    room.odrackovi = 1
                    addm(5, "bot-m-zivy")
                elseif room.osklebakovi == 0 then
                    addv(50, "bot-v-vsim")
                    addm(random(20), "bot-m-vypada")
                    planSet(sklebak, "cinnost", 10)
                    room.osklebakovi = -1
                elseif room.osklebu == 0 and sklebak:isTalking() then
                    room.osklebu = 1
                elseif room.osklebu == 1 and not sklebak:isTalking() then
                    if dist(small, sklebak) < 3 then
                        room.osklebu = 2
                        addm(10, "bot-m-ble")
                        if random(100) < 60 then
                            addv(random(10) + 5, "bot-v-totem")
                        end
                    else
                        room.osklebu = 0
                    end
                elseif room.opadu == 0 and pom1 == 1 and random(100) < 5 then
                    room.opadu = 1
                    addm(10, "bot-m-padaji")
                    addv(random(20), "bot-v-vsak"..random(2))
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sklebak()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sklebak.cinnost = 0

        return function()
            switch(sklebak.cinnost){
                [0] = function()
                    sklebak.afaze = 0
                    if random(1000) < 5 then
                        switch(random(2)){
                            [0] = function()
                                sklebak.cinnost = 10
                            end,
                            [1] = function()
                                sklebak.cinnost = 20
                            end,
                        }
                    end
                end,
                [10] = function()
                    setanim(sklebak, "a2a3a4R")
                    sklebak:talk("bot-x-smich", VOLUME_FULL)
                    sklebak.cinnost = sklebak.cinnost + 1
                end,
                [11] = function()
                    goanim(sklebak)
                    if not sklebak:isTalking() then
                        sklebak.cinnost = 100
                    end
                end,
                [20] = function()
                    sklebak.afaze = 5
                    sklebak:talk("bot-x-gr"..random(2), VOLUME_FULL)
                    sklebak.cinnost = sklebak.cinnost + 1
                end,
                [21] = function()
                    if not sklebak:isTalking() then
                        sklebak.cinnost = 100
                    end
                end,
                [100] = function()
                    sklebak.afaze = 0
                    sklebak.cinnost = sklebak.cinnost + 1
                end,
                [120] = function()
                    sklebak.cinnost = 0
                end,
                default = function()
                    sklebak.cinnost = sklebak.cinnost + 1
                end,
            }
            sklebak:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_zlaty()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        setanim(zlaty, "a0d2a1d2R")

        return function()
            goanim(zlaty)
            zlaty:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_lebzna()
        return function()
            if odd(game_getCycles()) then
                lebzna.afaze = math.mod(lebzna.afaze + 1, 4)
                lebzna:updateAnim()
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
    subinit = prog_init_sklebak()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_zlaty()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_lebzna()
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

