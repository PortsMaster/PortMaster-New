
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky01.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.okrikla = 0
        room.maxdrzost = 20
        room.kuk = 0
        room.kobyla = 0
        room.prekazka = 0
        room.okriknuti = 2
        room.vsichni = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if valec.X == 7 and valec.Y == 9 and valec.dir == dir_no and room.prekazka == 0 then
                    switch(random(2)){
                        [0] = function()
                            addv(0, "mik-v-sakra")
                        end,
                        [1] = function()
                            addv(random(4), "mik-v-projet")
                        end,
                    }
                    room.prekazka = 1
                elseif room.okrikla ~= 1 and room.vsichni == 1 then
                    switch(random(room.okriknuti)){
                        [0] = function()
                            addv(random(5), "mik-v-ticho0")
                        end,
                        [1] = function()
                            addv(random(5), "mik-v-ticho1")
                        end,
                        [2] = function()
                            addv(random(5), "mik-v-ticho2")
                        end,
                    }
                    planSet(room, "okrikla", 1)
                elseif room.okrikla == 1 then
                    krab1:killSound()
                    krab2:killSound()
                    krab3:killSound()
                    krab4:killSound()

                    room.vsichni = 0
                    dialog_table = {
                        [0] = function()
                            addm(20 + random(15), "mik-m-krab")
                            if random(100) < 50 then
                                addm(random(6), "mik-m-poust")
                            end
                        end,
                        [1] = function()
                            addm(10 + random(25), "mik-m-tusit")
                        end,
                        [2] = function()
                            switch(random(2)){
                                [0] = function()
                                    addv(10 + random(15), "mik-v-proto")
                                end,
                                [1] = function()
                                    addv(10 + random(15), "mik-v-tak")
                                end,
                            }
                            if room.okriknuti == 3 then
                                switch(random(6)){
                                    [0] = function()
                                        addm(6 + random(5), "mik-m-nezlob")
                                    end,
                                    [1] = function()
                                        addm(10 + random(25), "mik-m-myslit")
                                    end,
                                    [2] = function()
                                        addm(random(5), "mik-m-nezlob")
                                        addm(5 + random(15), "mik-m-myslit")
                                    end,
                                }
                            end
                            room.okriknuti = 3
                        end,
                    }

                    dialog_table[3] = dialog_table[2]
                    dialog_table[4] = dialog_table[2]
                    switch(random(7))(dialog_table)

                    room.okrikla = 0
                    krab1.drzej = 0
                    krab2.drzej = 0
                    krab3.drzej = 0
                    krab4.drzej = 0
                    adddel(random(20) + 30)
                    planSet(krab1, "drzej", 1)
                    planSet(krab2, "drzej", 1)
                    planSet(krab3, "drzej", 1)
                    planSet(krab4, "drzej", 1)
                elseif look_at(small, rybusa) and rybusa.afaze > 0 and random(100) < 10 and room.kuk == 0 then
                    addm(random(5), "mik-m-proc")
                    addv(random(5), "mik-v-videt")
                    room.kuk = 1
                elseif look_at(small, kun) and room.kobyla == 0 and (small.Y == kun.Y or small.Y == kun.Y + 1) and xdist(small, kun) < 2 and kun.dir == dir_no and random(200) < 1 then
                    addm(0, "mik-m-konik")
                    room.kobyla = 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_kun()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        kun.pauza = random(10)

        return function()
            if kun.pauza > 0 then
                kun.pauza = kun.pauza - 1
            else
                switch(kun.afaze){
                    [0] = function()
                        kun.afaze = random(2) + 2
                        kun.pauza = 10 - kun.afaze + random((5 - kun.afaze) * 20)
                    end,
                    [1] = function()
                        kun.afaze = random(4)
                        kun.pauza = 10 + random(10)
                    end,
                    [2] = function()
                        kun.pauza = random(150)
                        if kun.pauza < 20 then
                            kun.afaze = 3
                        else
                            kun.afaze = 1
                        end
                    end,
                    [3] = function()
                        kun.afaze = 0
                        kun.pauza = random(20)
                    end,
                }
            end

            kun:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_rybusa()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        rybusa.pauza = random(50)

        return function()
            if rybusa.pauza > 0 then
                rybusa.pauza = rybusa.pauza - 1
            else
                switch(rybusa.afaze){
                    [0] = function()
                        rybusa.afaze = 1
                        rybusa.pauza = 10 + random(20)
                    end,
                    [1] = function()
                        rybusa.afaze = random(4)
                        if rybusa.afaze == 0 then
                            rybusa.pauza = 20 + random(100)
                        else
                            rybusa.pauza = 10 + random(5)
                        end
                    end,
                    [2] = function()
                        rybusa.afaze = 1 + random(2) * 2
                        rybusa.pauza = 10 + random(5)
                    end,
                    [3] = function()
                        rybusa.afaze = 1 + random(2)
                        rybusa.pauza = 10 + random(5)
                    end,
                }
            end

            rybusa:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sepie()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sepie.mrk = 0
        sepie.pozice = 0

        return function()
            if random(7) < 4 then
                sepie.pozice = random(3)
            end
            if random(10) < 4 then
                sepie.mrk = random(2)
            end
            sepie.afaze = sepie.mrk * 3 + sepie.pozice

            sepie:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab4()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab4.drzej = 1
        krab4.keca = 0

        return function()
            if krab4:isTalking() then
                krab4.keca = 1
            else
                krab4.keca = 0
            end
            if krab4.keca == 0 and random(200) < krab4.drzej then
                if krab1.keca == 1 and krab2.keca == 1 and krab3.keca == 1 then
                    room.vsichni = 1
                end
                switch(random(4)){
                    [0] = function()
                        krab4:talk("mik-x-stebet0")
                    end,
                    [1] = function()
                        krab4:talk("mik-x-stebet1")
                    end,
                    [2] = function()
                        krab4:talk("mik-x-stebet2")
                    end,
                    [3] = function()
                        krab4:talk("mik-x-stebet3")
                    end,
                }
                krab4.drzej = krab4.drzej + 1
                krab4.keca = 1
            end
            if krab4.keca == 1 then
                krab4.afaze = random(2) * 2
            else
                krab4.afaze = 0
            end
            if random(100) < 5 then
                krab4.afaze = krab4.afaze + 1
            end
            if room.okrikla == 1 then
                krab4.drzej = 1
            end

            krab4:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab3.drzej = 1
        krab3.keca = 0

        return function()
            if krab3:isTalking() then
                krab3.keca = 1
            else
                krab3.keca = 0
            end
            if krab3.keca == 0 and random(200) < krab3.drzej then
                if krab1.keca == 1 and krab2.keca == 1 and krab4.keca == 1 then
                    room.vsichni = 1
                end
                switch(random(4)){
                    [0] = function()
                        krab3:talk("mik-x-stebet0")
                    end,
                    [1] = function()
                        krab3:talk("mik-x-stebet1")
                    end,
                    [2] = function()
                        krab3:talk("mik-x-stebet2")
                    end,
                    [3] = function()
                        krab3:talk("mik-x-stebet3")
                    end,
                }
                krab3.drzej = krab3.drzej + 1
                krab3.keca = 1
            end
            if krab3.keca == 1 then
                krab3.afaze = random(2) * 2
            else
                krab3.afaze = 0
            end
            if random(100) < 5 then
                krab3.afaze = krab3.afaze + 1
            end
            if room.okrikla == 1 then
                krab3.drzej = 1
            end

            krab3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab2.drzej = 1
        krab2.keca = 0

        return function()
            if krab2:isTalking() then
                krab2.keca = 1
            else
                krab2.keca = 0
            end
            if krab2.keca == 0 and random(200) < krab2.drzej then
                if krab1.keca == 1 and krab3.keca == 1 and krab4.keca == 1 then
                    room.vsichni = 1
                end
                switch(random(4)){
                    [0] = function()
                        krab2:talk("mik-x-stebet0")
                    end,
                    [1] = function()
                        krab2:talk("mik-x-stebet1")
                    end,
                    [2] = function()
                        krab2:talk("mik-x-stebet2")
                    end,
                    [3] = function()
                        krab2:talk("mik-x-stebet3")
                    end,
                }
                krab2.drzej = krab2.drzej + 1
                krab2.keca = 1
            end
            if krab2.keca == 1 then
                krab2.afaze = random(2) * 2
            else
                krab2.afaze = 0
            end
            if random(100) < 5 then
                krab2.afaze = krab2.afaze + 1
            end
            if room.okrikla == 1 then
                krab2.drzej = 1
            end

            krab2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snek()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        snek.pauza = 3

        return function()
            if snek.pauza > 0 then
                snek.pauza = snek.pauza - 1
            else
                switch(snek.afaze){
                    [0] = function()
                        snek.afaze = random(2) * 2
                    end,
                    [1] = function()
                        snek.afaze = random(4)
                    end,
                    [2] = function()
                        snek.afaze = 1 + 2 * random(2)
                    end,
                    [3] = function()
                        snek.afaze = random(3)
                    end,
                }
                snek.pauza = random(20) + 5
            end

            snek:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab1.drzej = 1
        krab1.keca = 0

        return function()
            if krab1:isTalking() then
                krab1.keca = 1
            else
                krab1.keca = 0
            end
            if krab1.keca == 0 and random(300) < krab1.drzej then
                if krab2.keca == 1 and krab3.keca == 1 and krab4.keca == 1 then
                    room.vsichni = 1
                end
                switch(random(4)){
                    [0] = function()
                        krab1:talk("mik-x-stebet0")
                    end,
                    [1] = function()
                        krab1:talk("mik-x-stebet1")
                    end,
                    [2] = function()
                        krab1:talk("mik-x-stebet2")
                    end,
                    [3] = function()
                        krab1:talk("mik-x-stebet3")
                    end,
                }
                krab1.drzej = krab1.drzej + 1
                krab1.keca = 1
            end
            if krab1.keca == 1 then
                krab1.afaze = random(2) * 2
            else
                krab1.afaze = 0
            end
            if random(100) < 5 then
                krab1.afaze = krab1.afaze + 1
            end
            if room.okrikla == 1 then
                krab1.drzej = 1
            end

            krab1:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_kun()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_rybusa()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sepie()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab4()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_snek()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab1()
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

