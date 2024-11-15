
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky09.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        switch(pokus){
            [1] = function()
                room.uvod = pokus
            end,
            [2] = function()
                room.uvod = pokus
            end,
            default = function()
                room.uvod = random(pokus)
            end,
        }
        room.omunici = 0
        room.ozebriku = random(3)
        room.otanku = random(1000 * pokus) + 1000

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.otanku > 0 then
                    room.otanku = room.otanku - 1
                end
                if room.uvod > 0 then
                    switch(room.uvod){
                        [1] = function()
                            if pokus == 1 or random(100) < 30 then
                                addm(10, "sv-m-pomohli")
                            end
                            addv(5 + random(10), "sv-v-bezsneku")
                            addm(5, "sv-m-utecha")
                        end,
                        [2] = function()
                            addv(30 + random(70), "sv-v-chtel")
                            addm(5, "sv-m-doscasu")
                        end,
                    }
                    room.uvod = 0
                elseif room.otanku == 0 then
                    room.otanku = -1
                    addm(30, "sv-m-tank")
                    addv(5, "sv-v-obojzivelny")
                    addm(5, "sv-m-kecy")
                    addv(0, "sv-v-proc")
                    addv(random(40) + 20, "sv-v-potopena")
                    addm(5, "sv-m-pravdepodob")
                elseif room.omunici == 0 and random(100) < 10 and (dist(small, mun1) <= 1 or dist(small, mun2) <= 1 or dist(small, mun3) <= 1) then
                    room.omunici = 1
                    addm(random(20), "sv-m-munice")
                    addv(5, "sv-v-nevim")
                elseif room.ozebriku == 0 and dist(big, zebr) <= 2 and random(100) < 10 then
                    room.ozebriku = 1
                    addv(10, "sv-v-zebrik")
                    addm(6, "sv-m-ven")
                    addv(4, "sv-v-ucpat")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_zebr()
        return function()
            if zebr.Y < zebr.YStart then
                room.ozebriku = 1
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
    subinit = prog_init_zebr()
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

