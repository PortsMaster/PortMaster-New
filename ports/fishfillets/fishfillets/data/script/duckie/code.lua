
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

        room.osneh = 0
        room.okach = 0
        room.okoh = 0
        room.oanim = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.oanim == 1 then
                    room.oanim = 3
                    addm(random(50) + 20, "odp-m-predmet")
                    switch(random(4)){
                        [0] = function()
                            addv(5, "odp-v-pozadi")
                        end,
                        [1] = function()
                            addv(5, "odp-v-pohni")
                        end,
                        default = function()
                            addv(5, "odp-v-coja")
                            planSet(big, "xichtit", 1)
                            adddel(random(20) + 15)
                            planSet(big, "xichtit", 0)
                            addv(3, "odp-v-nestacim")
                        end,
                    }
                elseif room.osneh == 0 and big:isLeft() and small:isLeft() and random(1000) < 2 then
                    addv(5, "odp-v-snehulak")
                    addm(random(10), "odp-m-blaznis")
                    room.osneh = 1
                    if room.oanim == 0 and random(100) < 60 then
                        room.oanim = 1
                    end
                elseif room.okoh == 0 and math.abs(xdist(kohoutek, big)) <= 1 and random(1000) < 3 then
                    addm(10, "odp-m-kohout")
                    addv(10, "odp-v-vtip")
                    room.okoh = 1
                elseif room.okach == 0 and random(1000) < 1 then
                    addv(100, "odp-v-kachna")
                    addm(5, "odp-m-zda" ..random(2))
                    room.okach = 1
                    if room.oanim == 0 and random(100) < 90 then
                        room.oanim = 1
                    end
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false
        local xicht = 0

        big.xichtit = 0

        return function()
            if big.xichtit == 1 then
                xicht = random(9)
            else
                xicht = 0
            end
            if xicht ~= 0 then
                big:useSpecialAnim("head_all", xicht)
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

