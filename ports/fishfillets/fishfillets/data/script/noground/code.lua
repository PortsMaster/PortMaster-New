
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

        room.uvod = 0
        room.smet = random(1000) + 200
        if random(100) < 10 * pokus - 10 then
            room.uvod = 1
        end
        if random(100) < 10 * pokus - 10 then
            room.smet = -1
        end

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.smet > 0 then
                    room.smet = room.smet - 1
                end
                if room.uvod == 0 then
                    addv(10 + random(30), "nog-v-zvlastni")
                    switch(random(6)){
                        [0] = function()
                            addm(random(5), "nog-m-uvedom0")
                        end,
                        [1] = function()
                            addm(random(5), "nog-m-uvedom0")
                        end,
                        [2] = function()
                            addm(random(5), "nog-m-uvedom1")
                        end,
                        [3] = function()
                            addm(random(5), "nog-m-uvedom1")
                        end,
                        [4] = function()
                            addm(random(5), "nog-m-uvedom0")
                            addm(random(5), "nog-m-uvedom1")
                        end,
                    }
                    room.uvod = 1
                elseif room.smet == 0 then
                    switch(random(2)){
                        [0] = function()
                            addv(0, "nog-v-smetiste0")
                        end,
                        [1] = function()
                            addv(0, "nog-v-smetiste1")
                        end,
                    }
                    room.smet = -1
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

