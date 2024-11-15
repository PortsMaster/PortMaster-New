
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky13.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        switch(pokus){
            [1] = function()
                room.uvod = 1
            end,
            [2] = function()
                room.uvod = 2
            end,
            default = function()
                room.uvod = random(4)
            end,
        }
        room.hlaska1 = random(2) + 1
        room.hlaska2 = 3 - room.hlaska1
        room.hlaskacount = -1

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.hlaskacount > 0 then
                    room.hlaskacount = room.hlaskacount - 1
                end
                pom1 = 0
                if room.uvod > 0 then
                    if odd(room.uvod) then
                        addv(20 + random(20), "ufo-v-znicilo")
                        addm(random(10) + 2, "ufo-m-osmy")
                    end
                    if room.uvod >= 2 then
                        adddel(random(300) + 40)
                        if random(2) == 0 then
                            addm(0, "ufo-m-valce")
                        else
                            addm(0, "ufo-m-moc")
                        end
                        addv(10, "ufo-v-hur")
                        addm(1, "ufo-m-ne")
                        addv(3, "ufo-v-vpredu")
                    end
                    room.uvod = 0
                elseif room.hlaska1 > 0 and dlouha.Y > 9 then
                    pom1 = room.hlaska1
                    adddel(random(200) + 50)
                    room.hlaska1 = 0
                    room.hlaskacount = 1000 + random(2000)
                elseif room.hlaskacount == 0 then
                    pom1 = room.hlaska2
                    adddel(20)
                    room.hlaska2 = 0
                    room.hlaskacount = -1
                end
                switch(pom1){
                    [1] = function()
                        addm(0, "ufo-m-zvlastni")
                        addv(5 + random(15), "ufo-v-rikam")
                        planBusy(small, true)
                        addm(10, "ufo-m-vidim")
                        planBusy(small, false)
                    end,
                    [2] = function()
                        addv(0, "ufo-v-dovnitr")
                        addm(5 + random(10), "ufo-m-tajemstvi")
                        addv(10 + random(90), "ufo-v-zjistit"..random(2))
                        if random(2) == 0 then
                            addm(5, "ufo-m-tady")
                        else
                            addm(5, "ufo-m-nevim")
                        end
                    end,
                }
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

