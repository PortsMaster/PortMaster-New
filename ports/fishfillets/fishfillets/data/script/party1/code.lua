
--NOTE: glasses must be together in models.lua
--NOTE: last glass is the plate
local glasses = {}
for i = 0, 8 do
    glasses[i] = getModelsTable()[sklenka.index + i]
end

local function setViewShiftX(model, reference, shift_x)
    model_setViewShift(model.index,
        reference.X + shift_x - model.X, 0)
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky15.ogg")
    local pokus = getRestartCount()
    room.globpole = createArray(1024)


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod1 = 0
        room.uvod2 = 0
        room.nevylit = 0
        room.ovalci = 0
        if random(100) >= 130 - pokus * 30 then
            room.uvod1 = 2
        end
        if random(100) >= 130 - pokus * 30 then
            room.uvod2 = 2
        end
        if random(100) >= 120 - pokus * 20 then
            room.nevylit = 2
        end
        if random(100) >= 120 - pokus * 20 then
            room.ovalci = 2
        end
        if room.uvod2 == 0 then
            room.globpole[1] = 1
            room.globpole[2] = 1
        else
            room.globpole[1] = 0
            room.globpole[2] = 0
        end
        room.bojise = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                pomb1 = false
                for pom1, glass in pairs(glasses) do
                    if glass.dir == dir_left or glass.dir == dir_right then
                        pomb1 = true
                    end
                end
                pomb2 = false
                --NOTE: glass num.8(=plate) is not used here
                for pom1 = 0, 7 do
                    local glass = glasses[pom1]
                    if glass.Y == 27 and glass.X == 36 and ocel.X == 37 then
                        pomb2 = true
                    end
                end
                if room.uvod1 == 0 then
                    addm(random(20) + 20, "pt1-m-parnicek")
                    room.uvod1 = 1
                elseif room.uvod2 == 0 then
                    addv(random(20) + 20, "pt1-v-predtucha")
                    addm(0, "pt1-m-predtucha")
                    planTimeAction(0, function() room.globpole[1] = 0 end)
                    planTimeAction(0, function() room.globpole[2] = 0 end)
                    room.uvod2 = 1
                elseif room.uvod2 == 1 and (room.globpole[1] ~= 0 or room.globpole[2] ~= 0) then
                    room.uvod2 = 2
                    addm(10 + random(10), "pt1-m-kostlivec")
                elseif room.bojise == 0 and room.uvod2 == 2 and (room.globpole[1] ~= 0 or room.globpole[2] ~= 0) and random(1000) < 3 then
                    room.bojise = 1
                    addm(20, "pt1-m-vylezt"..random(3))
                    addv(random(10) + 5, "pt1-v-pryc"..random(2))
                elseif room.ovalci == 0 and pomb2 then
                    room.ovalci = 1
                    addv(3, "pt1-v-valec")
                    addm(random(5), "pt1-m-nemuzu")
                elseif room.nevylit == 0 and pomb1 and random(100) < 1 then
                    room.nevylit = 1
                    addv(0, "pt1-v-pozor")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_frkavec()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        frkavec.cinnost = 0
        frkavec:setEffect("invisible")

        return function()
            switch(frkavec.okno){
                [1] = function()
                    setViewShiftX(frkavec, kabina, 2)
                end,
                [2] = function()
                    setViewShiftX(frkavec, kabina, 8)
                end,
            }
            if frkavec.cinnost > 0 then
                if frkavec.strana == 1 then
                    frkavec:setEffect("reverse")
                else
                    frkavec:setEffect("none")
                end
            else
                frkavec:setEffect("invisible")
            end
            switch(frkavec.cinnost){
                [0] = function()
                    if random(1000) < 8 then
                        frkavec.okno = random(2) + 1
                        if room.globpole[frkavec.okno] == 0 then
                            frkavec.cinnost = 1
                            frkavec.faze = 0
                            frkavec.strana = random(2)
                            room.globpole[frkavec.okno] = 1
                        end
                    end
                end,
                [1] = function()
                    local anim_table = {
                        [0] = function()
                            frkavec.afaze = frkavec.faze
                            frkavec.faze = frkavec.faze + 1
                        end,
                        [5] = function()
                            frkavec.afaze = 5
                            frkavec.delay = random(10) + 5
                            frkavec.faze = frkavec.faze + 1
                        end,
                        [6] = function()
                            if frkavec.delay > 0 then
                                frkavec.delay = frkavec.delay - 1
                            else
                                frkavec.afaze = 6
                                frkavec.delay = 10
                                frkavec.faze = frkavec.faze + 1
                            end
                        end,
                        [7] = function()
                            if frkavec.delay > 0 then
                                frkavec.delay = frkavec.delay - 1
                            else
                                frkavec.afaze = 5
                                if random(100) < 75 then
                                    frkavec.delay = 2 + random(10)
                                    frkavec.faze = 6
                                else
                                    frkavec.faze = frkavec.faze + 1
                                end
                            end
                        end,
                        [8] = function()
                            frkavec.faze = frkavec.faze + 1
                        end,
                        [9] = function()
                            room.globpole[frkavec.okno] = 0
                            frkavec.faze = frkavec.faze + 1
                        end,
                        [10] = function()
                            frkavec.afaze = 14 - frkavec.faze
                            frkavec.faze = frkavec.faze + 1
                            if frkavec.faze == 15 then
                                frkavec.cinnost = 0
                            end
                        end,
                    }
                    anim_table[1] = anim_table[0]
                    anim_table[2] = anim_table[0]
                    anim_table[3] = anim_table[0]
                    anim_table[4] = anim_table[0]
                    anim_table[11] = anim_table[10]
                    anim_table[12] = anim_table[10]
                    anim_table[13] = anim_table[10]
                    anim_table[14] = anim_table[10]

                    switch(frkavec.faze)(anim_table)
                end,
            }

            frkavec:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dama()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dama:setEffect("invisible")
        dama.kdeje = random(3)
        dama.cinnost = 0

        return function()
            switch(dama.okno){
                [1] = function()
                    setViewShiftX(dama, kabina, 2)
                end,
                [2] = function()
                    setViewShiftX(dama, kabina, 8)
                end,
            }
            if dama.cinnost > 0 then
                if dama.strana == 1 then
                    dama:setEffect("reverse")
                else
                    dama:setEffect("none")
                end
            else
                dama:setEffect("invisible")
            end
            local cinnost_table = {
                [0] = function()
                    if random(1000) < 8 then
                        switch(dama.kdeje){
                            [0] = function()
                                dama.okno = 1
                                dama.strana = 1
                                dama.kdebude = 1
                            end,
                            [1] = function()
                                dama.strana = random(2)
                                dama.okno = dama.strana + 1
                                dama.kdebude = dama.strana * 2
                            end,
                            [2] = function()
                                dama.okno = 2
                                dama.strana = 0
                                dama.kdebude = 1
                            end,
                        }
                        if room.globpole[dama.okno] == 0 then
                            room.globpole[dama.okno] = 1
                            dama.cinnost = random(2) + 1
                            dama.faze = 0
                            dama.delay = 3
                        end
                    end
                end,
                [1] = function()
                    local anim_table = {
                        [20] = function()
                            dama.faze = dama.faze + 1
                        end,
                        [24] = function()
                            dama.afaze = 15
                            dama.faze = dama.faze + 1
                        end,
                        [28] = function()
                            dama.afaze = 6
                            dama.faze = dama.faze + 1
                        end,
                        [30] = function()
                            dama.faze = 7
                        end,
                        default = function()
                            if dama.faze >= 0 and dama.faze <= 14 then
                                dama.afaze = dama.faze
                                if dama.delay > 0 then
                                    dama.delay = dama.delay - 1
                                else
                                    dama.delay = 3
                                    dama.faze = dama.faze + 1
                                    if dama.faze == 7 and dama.cinnost == 2 then
                                        dama.faze = 20
                                    end
                                end
                                if dama.faze == 15 then
                                    dama.cinnost = 0
                                    room.globpole[dama.okno] = 0
                                    dama.kdeje = dama.kdebude
                                end
                            end
                        end,
                    }

                    anim_table[21] = anim_table[20]
                    anim_table[22] = anim_table[20]
                    anim_table[23] = anim_table[20]
                    anim_table[25] = anim_table[24]
                    anim_table[26] = anim_table[24]
                    anim_table[27] = anim_table[24]
                    anim_table[29] = anim_table[28]

                    switch(dama.faze)(anim_table)
                end,
            }

            cinnost_table[2] = cinnost_table[1]

            switch(dama.cinnost)(cinnost_table)

            dama:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_kapitan()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        kapitan:setEffect("invisible")
        kapitan.kdeje = random(3)
        kapitan.cinnost = 0

        return function()
            switch(kapitan.okno){
                [1] = function()
                    setViewShiftX(kapitan, kabina, 2)
                end,
                [2] = function()
                    setViewShiftX(kapitan, kabina, 8)
                end,
            }
            if kapitan.cinnost > 0 then
                if kapitan.strana == 0 then
                    kapitan:setEffect("reverse")
                else
                    kapitan:setEffect("none")
                end
            else
                kapitan:setEffect("invisible")
            end
            local cinnost_table = {
                [0] = function()
                    if random(1000) < 8 then
                        switch(kapitan.kdeje){
                            [0] = function()
                                kapitan.okno = 1
                                kapitan.strana = 1
                                kapitan.kdebude = 1
                            end,
                            [1] = function()
                                kapitan.strana = random(2)
                                kapitan.okno = kapitan.strana + 1
                                kapitan.kdebude = kapitan.strana * 2
                            end,
                            [2] = function()
                                kapitan.okno = 2
                                kapitan.strana = 0
                                kapitan.kdebude = 1
                            end,
                        }
                        if room.globpole[kapitan.okno] == 0 then
                            room.globpole[kapitan.okno] = 1
                            kapitan.cinnost = random(2) + 1
                            kapitan.faze = 0
                            kapitan.delay = 2
                        end
                    end
                end,
                [1] = function()
                    local anim_table = {
                        [20] = function()
                            kapitan.afaze = kapitan.faze - 20 + 15
                            kapitan.faze = kapitan.faze + 1
                        end,
                        [24] = function()
                            kapitan.afaze = 27 - kapitan.faze + 15
                            kapitan.faze = kapitan.faze + 1
                        end,
                        [28] = function()
                            kapitan.faze = 8
                        end,
                        default = function()
                            if kapitan.faze >= 0 and kapitan.faze <= 14 then
                                kapitan.afaze = kapitan.faze
                                if kapitan.delay > 0 then
                                    kapitan.delay = kapitan.delay - 1
                                else
                                    kapitan.delay = 2
                                    kapitan.faze = kapitan.faze + 1
                                    if kapitan.faze == 8 and kapitan.cinnost == 2 then
                                        kapitan.faze = 20
                                    end
                                end
                                if kapitan.faze == 15 then
                                    kapitan.cinnost = 0
                                    room.globpole[kapitan.okno] = 0
                                    kapitan.kdeje = kapitan.kdebude
                                end
                            end
                        end,
                    }

                    anim_table[21] = anim_table[20]
                    anim_table[22] = anim_table[20]
                    anim_table[23] = anim_table[20]
                    anim_table[25] = anim_table[24]
                    anim_table[26] = anim_table[24]
                    anim_table[27] = anim_table[24]

                    switch(kapitan.faze)(anim_table)
                end,
            }

            cinnost_table[2] = cinnost_table[1]

            switch(kapitan.cinnost)(cinnost_table)

            kapitan:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_lodnik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        lodnik:setEffect("invisible")
        lodnik.kdeje = random(3)
        lodnik.cinnost = 0

        return function()
            switch(lodnik.okno){
                [1] = function()
                    setViewShiftX(lodnik, kabina, 2)
                end,
                [2] = function()
                    setViewShiftX(lodnik, kabina, 8)
                end,
            }
            if lodnik.cinnost > 0 then
                if lodnik.strana == 1 then
                    lodnik:setEffect("reverse")
                else
                    lodnik:setEffect("none")
                end
            else
                lodnik:setEffect("invisible")
            end
            switch(lodnik.cinnost){
                [0] = function()
                    if random(1000) < 8 then
                        switch(lodnik.kdeje){
                            [0] = function()
                                lodnik.okno = 1
                                lodnik.strana = 1
                                lodnik.kdebude = 1
                            end,
                            [1] = function()
                                lodnik.strana = random(2)
                                lodnik.okno = lodnik.strana + 1
                                lodnik.kdebude = lodnik.strana * 2
                            end,
                            [2] = function()
                                lodnik.okno = 2
                                lodnik.strana = 0
                                lodnik.kdebude = 1
                            end,
                        }
                        if room.globpole[lodnik.okno] == 0 then
                            room.globpole[lodnik.okno] = 1
                            lodnik.cinnost = random(2) + 1
                            lodnik.faze = 0
                            lodnik.delay = (lodnik.cinnost - 1) * 2
                        end
                    end
                end,
                [1] = function()
                    if lodnik.faze >= 0 and lodnik.faze <= 9 then
                        lodnik.afaze = lodnik.faze
                        if lodnik.delay > 0 then
                            lodnik.delay = lodnik.delay - 1
                        else
                            lodnik.delay = 1 + (lodnik.cinnost - 1) * 2
                            lodnik.faze = lodnik.faze + 1
                        end
                        if lodnik.faze == 10 then
                            lodnik.cinnost = 0
                            room.globpole[lodnik.okno] = 0
                            lodnik.kdeje = lodnik.kdebude
                        end
                    end
                end,
                [2] = function()
                    if lodnik.faze >= 0 and lodnik.faze <= 12 then
                        lodnik.afaze = lodnik.faze + 10
                        if lodnik.delay > 0 then
                            lodnik.delay = lodnik.delay - 1
                        else
                            lodnik.delay = 1 + (lodnik.cinnost - 1) * 2
                            lodnik.faze = lodnik.faze + 1
                        end
                        if lodnik.faze == 13 then
                            lodnik.cinnost = 0
                            room.globpole[lodnik.okno] = 0
                            lodnik.kdeje = lodnik.kdebude
                        end
                    end
                end,
            }

            lodnik:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sklenka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        for pom1 = 0, 8 do
            room.globpole[1000 + pom1] = 0
        end

        return function()
            for pom1, glass in pairs(glasses) do
                pom2 = room.globpole[1000 + pom1]
                if glass.dir ~= dir_no then
                    if pom2 == 0 then
                        pom2 = 9
                    elseif pom2 <= 6 then
                        pom2 = pom2 + 6
                    end
                end
                if pom2 == 0 then
                    glass.afaze = 0
                else
                    pom2 = pom2 - 1
                    glass.afaze = 2 - math.mod(math.floor(pom2 / 3), 2)
                end
                room.globpole[1000 + pom1] = pom2
                glass:updateAnim()
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
    subinit = prog_init_frkavec()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dama()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_kapitan()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_lodnik()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sklenka()
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

