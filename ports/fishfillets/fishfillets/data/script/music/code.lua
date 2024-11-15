
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    local pokus = getRestartCount()
    local updateCycles = 0


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.hlaskam = 0
        room.hlaskav = 0
        --TODO: allow to ask for music_volume
        local startVolume = optionsGetAsInt("volume_sound")
        room.rozbito = 0

        return function()
            updateCycles = updateCycles + 1
            if isReady(small) and isReady(big) and no_dialog() then
                if amp1:isTalking() or amp2:isTalking() or amp3:isTalking() then
                    if room.hlaskam == 0 and random(1000) < 1 then
                        room.hlaskam = 1
                        addm(10, "ves-m-krab")
                    elseif room.hlaskav == 0 and random(1000) < 2 then
                        room.hlaskav = 1
                        switch(random(2)){
                            [0] = function()
                                addv(10, "ves-v-veci")
                            end,
                            [1] = function()
                                addv(10, "ves-v-vyp")
                            end,
                        }
                    elseif startVolume > optionsGetAsInt("volume_sound") and optionsGetAsInt("volume_sound") < 16 then
                        startVolume = 0
                        addm(15, "ves-m-dik")
                        addv(random(20) + 10, "ves-v-stejne")
                    end
                elseif room.rozbito == 3 then
                    room.rozbito = room.rozbito + 1
                    addv(10, "ves-v-pokoj")
                elseif room.rozbito == 5 then
                    addm(3, "ves-m-uz")
                    room.rozbito = room.rozbito + 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_amp1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        amp1.stav = 0

        return function()
            if amp1.stav == 1 and updateCycles == 2 and not amp1:isTalking() then
                amp1:talk("ves-ampliony", VOLUME_LOW, -1)
            end
            switch(amp1.stav){
                [0] = function()
                    if updateCycles == hlava.zac2 then
                        amp1.faze = 0
                        amp1:talk("ves-ampliony", VOLUME_LOW, -1)
                        amp1.stav = amp1.stav + 1
                    end
                end,
                [1] = function()
                    if amp1.dir == dir_down then
                        amp1.stav = amp1.stav + 1
                        amp1.afaze = 7
                    elseif odd(game_getCycles()) then
                    local anim_table = {
                            [0] = function()
                                amp1.afaze = amp1.afaze + 1
                            end,
                            [1] = function()
                                amp1.afaze = amp1.afaze - 1
                            end,
                            [2] = function()
                                amp1.afaze = amp1.afaze + 2
                            end,
                            [8] = function()
                                amp1.afaze = amp1.afaze - 2
                            end,
                            [13] = function()
                                amp1.faze = -1
                                amp1.afaze = 0
                            end,
                        }
                        anim_table[3] = anim_table[0]
                        anim_table[4] = anim_table[0]
                        anim_table[7] = anim_table[0]
                        anim_table[12] = anim_table[0]
                        anim_table[6] = anim_table[1]
                        anim_table[9] = anim_table[1]
                        anim_table[10] = anim_table[1]
                        anim_table[5] = anim_table[2]
                        anim_table[11] = anim_table[8]
                        switch(amp1.faze)(anim_table)

                        amp1.faze = amp1.faze + 1
                    end
                end,
                [2] = function()
                    if amp1.dir ~= dir_down then
                        amp1:killSound()
                        room:talk("sp-smrt", VOLUME_FULL)
                        amp1.afaze = 9
                        amp1.stav = amp1.stav + 1
                        room.rozbito = room.rozbito + 1
                    elseif odd(game_getCycles()) then
                        amp1.afaze = 15 - amp1.afaze
                    end
                end,
            }

            amp1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_amp2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        amp2.stav = 0
        amp2.afaze = 3

        return function()
            if amp2.stav == 1 and updateCycles == 2 + 3 and not amp2:isTalking() then
                amp2:talk("ves-ampliony", VOLUME_LOW, -1)
            end
            switch(amp2.stav){
                [0] = function()
                    if updateCycles == hlava.zac2 + 3 then
                        amp2.faze = 4
                        amp2:talk("ves-ampliony", VOLUME_LOW, -1)
                        amp2.stav = amp2.stav + 1
                    end
                end,
                [1] = function()
                    if amp2.dir == dir_down then
                        amp2.stav = amp2.stav + 1
                        amp2.afaze = 7
                    elseif odd(game_getCycles()) then
                        local anim_table = {
                            [0] = function()
                                amp2.afaze = amp2.afaze + 1
                            end,
                            [1] = function()
                                amp2.afaze = amp2.afaze - 1
                            end,
                            [2] = function()
                                amp2.afaze = amp2.afaze + 2
                            end,
                            [8] = function()
                                amp2.afaze = amp2.afaze - 2
                            end,
                            [13] = function()
                                amp2.faze = -1
                                amp2.afaze = 0
                            end,
                        }
                        anim_table[3] = anim_table[0]
                        anim_table[4] = anim_table[0]
                        anim_table[7] = anim_table[0]
                        anim_table[12] = anim_table[0]
                        anim_table[6] = anim_table[1]
                        anim_table[9] = anim_table[1]
                        anim_table[10] = anim_table[1]
                        anim_table[5] = anim_table[2]
                        anim_table[11] = anim_table[8]
                        switch(amp2.faze)(anim_table)

                        amp2.faze = amp2.faze + 1
                    end
                end,
                [2] = function()
                    if amp2.dir ~= dir_down then
                        amp2:killSound()
                        room:talk("sp-smrt", VOLUME_FULL)
                        amp2.afaze = 9
                        amp2.stav = amp2.stav + 1
                        room.rozbito = room.rozbito + 1
                    elseif odd(game_getCycles()) then
                        amp2.afaze = 15 - amp2.afaze
                    end
                end,
            }

            amp2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_amp3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        amp3.stav = 0
        amp3.afaze = 6

        return function()
            if amp3.stav == 1 and updateCycles == 2 + 5 and not amp3:isTalking() then
                amp3:talk("ves-ampliony", VOLUME_LOW, -1)
            end
            switch(amp3.stav){
                [0] = function()
                    if updateCycles == hlava.zac2 + 5 then
                        amp3.faze = 6
                        amp3:talk("ves-ampliony", VOLUME_LOW, -1)
                        amp3.stav = amp3.stav + 1
                    end
                end,
                [1] = function()
                    if amp3.dir == dir_down then
                        amp3.stav = amp3.stav + 1
                        amp3.afaze = 7
                    elseif odd(game_getCycles()) then
                    local anim_table = {
                            [0] = function()
                                amp3.afaze = amp3.afaze + 1
                            end,
                            [1] = function()
                                amp3.afaze = amp3.afaze - 1
                            end,
                            [2] = function()
                                amp3.afaze = amp3.afaze + 2
                            end,
                            [8] = function()
                                amp3.afaze = amp3.afaze - 2
                            end,
                            [13] = function()
                                amp3.faze = -1
                                amp3.afaze = 0
                            end,
                        }
                        anim_table[3] = anim_table[0]
                        anim_table[4] = anim_table[0]
                        anim_table[7] = anim_table[0]
                        anim_table[12] = anim_table[0]
                        anim_table[6] = anim_table[1]
                        anim_table[9] = anim_table[1]
                        anim_table[10] = anim_table[1]
                        anim_table[5] = anim_table[2]
                        anim_table[11] = anim_table[8]
                        switch(amp3.faze)(anim_table)

                        amp3.faze = amp3.faze + 1
                    end
                end,
                [2] = function()
                    if amp3.dir ~= dir_down then
                        amp3:killSound()
                        room:talk("sp-smrt", VOLUME_FULL)
                        amp3.afaze = 9
                        amp3.stav = amp3.stav + 1
                        room.rozbito = room.rozbito + 1
                    elseif odd(game_getCycles()) then
                        amp3.afaze = 15 - amp3.afaze
                    end
                end,
            }

            amp3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlava()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        hlava.stav = 0
        hlava.zac1 = 30
        hlava.zac2 = 65

        return function()
            switch(hlava.stav){
                [0] = function()
                    if updateCycles == hlava.zac1 then
                        hlava.stav = hlava.stav + 1
                        hlava:talk("ves-hs-hrajeme", VOLUME_FULL)
                    end
                end,
                [1] = function()
                    if hlava:isTalking() then
                        switch(random(3)){
                            [0] = function()
                                hlava.afaze = 0
                            end,
                            [1] = function()
                                hlava.afaze = 17
                            end,
                            [2] = function()
                                hlava.afaze = 14
                            end,
                        }
                    else
                        hlava.stav = hlava.stav + 1
                        hlava.afaze = 5
                    end
                end,
                [2] = function()
                    if updateCycles >= hlava.zac2 + 10 then
                        hlava.stav = hlava.stav + 1
                    end
                end,
                [3] = function()
                    if room.rozbito < 3 then
                        if odd(math.floor(game_getCycles() / 2)) then
                            hlava.afaze = 10
                        else
                            hlava.afaze = 11
                        end
                    else
                        hlava.afaze = 13
                        hlava.stav = hlava.stav + 1
                    end
                end,
                [51] = function()
                    hlava:talk("ves-hs-papa")
                    room.rozbito = room.rozbito + 1
                    hlava.stav = 100
                end,
                [100] = function()
                    if hlava:isTalking() then
                        if odd(math.floor(game_getCycles() / 2)) then
                            hlava.afaze = 4
                        else
                            hlava.afaze = 18
                        end
                    else
                        room.rozbito = room.rozbito + 1
                        hlava.afaze = 5
                        hlava.stav = hlava.stav + 1
                    end
                end,
                default = function()
                    if hlava.stav >= 4 and  hlava.stav <= 50 then
                        hlava.stav = hlava.stav + 1
                    end
                end,
            }

            hlava:updateAnim()

        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krabik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krabik.afaze = 1

        return function()
            if amp1:isTalking() or amp2:isTalking() or amp3:isTalking() or hlava:isTalking() then
                krabik.afaze = random(5)
                if krabik.afaze == 1 then
                    krabik.afaze = 5
                end
            elseif random(20) == 0 then
                krabik.afaze = 1
            end

            krabik:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_amp1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_amp2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_amp3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlava()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krabik()
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

