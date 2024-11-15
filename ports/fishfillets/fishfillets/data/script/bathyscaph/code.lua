

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky07.ogg")
    local pokus = getRestartCount()
    local main = {}
    local roompole = createArray(2)


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.aktivni = main
        room.poc = random(50 + pokus) + 100
        room.halo = 0
        room.mikros = 0
        room.nemam = 200
        room.odsud = 0
        room.pronej = 10 + random(50)
        room.uhnu = 500 + random(500)
        room.teduz = 0

        return function()
            switch(room.aktivni){
                [main] = function()
                    if room.poc > 0 then
                        room.poc = room.poc - 1
                    else
                        pomb1 = zluty.X == ztel.X and zluty.Y + 3 == ztel.Y
                        pomb2 = modry.X == mtel.X and modry.Y + 3 == mtel.Y
                        room.poc = random(80) + 50
                        room.zvon = 0
                        if pomb1 then
                            if pomb2 then
                                if odd(random(10)) then
                                    room.aktivni = zluty
                                else
                                    room.aktivni = modry
                                end
                            else
                                room.aktivni = zluty
                            end
                        elseif pomb2 then
                            room.aktivni = modry
                        else
                            room.aktivni = ibudik
                        end
                    end
                end,
                [zluty] = function()
                    if room.poc == 0 then
                        zluty:killSound()
                        room.poc = random(30) + 30
                        room.aktivni = main
                        zluty.afaze = 0
                    else
                        room.poc = room.poc - 1
                        if room.pronej > 0 then
                            room.pronej = room.pronej - 1
                        end
                        if zluty.X == ztel.X and zluty.Y + 3 == ztel.Y then
                            if zluty:isTalking() then
                                room.zvon = room.zvon + 1
                                if odd(room.zvon) then
                                    zluty.afaze = 1
                                else
                                    zluty.afaze = 2
                                end
                            elseif room.zvon > 0 then
                                room.zvon = room.zvon - 1
                                zluty.afaze = 0
                            else
                                zluty:talk("bat-t-phone0", VOLUME_FULL)
                            end
                        else
                            zluty:killSound()
                            zluty.afaze = 0
                            room.aktivni = ztel
                            room.halo = 1
                        end
                    end
                    zluty:updateAnim()
                end,
                [modry] = function()
                    if room.poc == 0 then
                        modry:killSound()
                        room.poc = random(30) + 30
                        room.aktivni = main
                        modry.afaze = 0
                    else
                        room.poc = room.poc - 1
                        if room.pronej > 0 then
                            room.pronej = room.pronej - 1
                        end
                        if modry.X == mtel.X and modry.Y + 3 == mtel.Y then
                            if modry:isTalking() then
                                room.zvon = room.zvon + 1
                                if odd(room.zvon) then
                                    modry.afaze = 1
                                else
                                    modry.afaze = 2
                                end
                            elseif room.zvon > 0 then
                                room.zvon = room.zvon - 1
                                modry.afaze = 0
                            else
                                modry:talk("bat-t-phone1", VOLUME_FULL)
                            end
                        else
                            modry:killSound()
                            modry.afaze = 0
                            room.aktivni = mtel
                            room.halo = 1
                        end
                    end
                    modry:updateAnim()
                end,
                [ztel] = function()
                    if room.halo ~= 2 then
                        room.aktivni = main
                        room.poc = random(100) + 30
                    end
                end,
                [mtel] = function()
                    if room.halo ~= 2 then
                        room.aktivni = main
                        room.poc = random(100) + 30
                    end
                end,
                [ibudik] = function()
                    if room.poc > 0 then
                        room.poc = room.poc - 1
                    elseif not ibudik:isTalking() then
                        ibudik:talk("bat-t-budik", VOLUME_FULL, -1)
                    elseif ibudik.dir ~= dir_no then
                        ibudik:killSound()
                        room.aktivni = -1
                    end
                end,
            }
            if room.halo == 1 then
                room.halo = 2
                if pokus > 5 then
                    pom1 = random(11)
                else
                    pom1 = random(8)
                end
                local bin_table = {}
                switch(pom1){
                    [0] = function()
                        bin_table[0] = true
                        bin_table[1] = true
                    end,
                    [1] = function()
                        bin_table[0] = true
                        bin_table[2] = true
                        bin_table[4] = true
                    end,
                    [2] = function()
                        bin_table[0] = true
                        bin_table[3] = true
                    end,
                    [3] = function()
                        bin_table[5] = true
                    end,
                    [4] = function()
                        bin_table[4] = true
                        bin_table[5] = true
                    end,
                    [5] = function()
                        bin_table[1] = true
                        bin_table[2] = true
                    end,
                    [6] = function()
                        bin_table[0] = true
                        bin_table[3] = true
                        bin_table[4] = true
                    end,
                    [7] = function()
                        bin_table[1] = true
                    end,
                    default = function()
                        bin_table = {}
                    end,
                }
                if bin_table[0] then
                    room:planDialog(5, "bat-p-0")
                end
                if bin_table[1] then
                    room:planDialog(5, "bat-p-1")
                end
                if bin_table[2] then
                    room:planDialog(5, "bat-p-2")
                end
                if bin_table[3] then
                    room:planDialog(5, "bat-p-3")
                end
                if bin_table[5] then
                    room:planDialog(5, "bat-p-5")
                end
                if bin_table[4] then
                    room:planDialog(5, "bat-p-4")
                end
                if countPairs(bin_table) == 0 then
                    room:planDialog(5, "bat-p-zhov"..random(2))
                end
                planSet(room, "halo", 0)
            end
            if no_dialog() and isReady(small) and isReady(big) then
                if game_getCycles() == 20 and random(pokus) < 3 then
                    addm(5, "bat-m-tohle")
                elseif room.mikros == 0 and dist(small, mikroskop) < 3 and mikroskop.dir ~= dir_no and random(10) == 1 then
                    room.mikros = 1
                    addm(6, "bat-m-mikro")
                elseif room.odsud == 0 and zluty.X > 32 and dist(small, zluty) < 4 and random(30) == 1 then
                    room.odsud = 1
                    addm(7, "bat-m-sluch")
                elseif room.teduz == 0 and room.aktivni == -1 and random(70) == 1 then
                    room.teduz = 1
                    addv(8, "bat-v-klid")
                elseif room.nemam > 0 then
                    room.nemam = room.nemam - 1
                else
                    switch(room.aktivni){
                        [ibudik] = function()
                            if random(100) == 1 then
                                room.nemam = 200 + random(200)
                                addv(1, "bat-v-vyp")
                            end
                        end,
                        default = function()
                            if room.aktivni == zluty or room.aktivni == modry then
                                if random(100) == 1 then
                                    room.nemam = 200 + random(200)
                                    if dist(small, room.aktivni) < dist(big, room.aktivni) then
                                        addv(1, "bat-v-zved1")
                                    else
                                        addv(1, "bat-v-zved0")
                                    end
                                end
                            end
                        end,
                    }
                end
            end
            if no_dialog() then
                if room.pronej == 0 and (room.aktivni == zluty or room.aktivni == modry) and random(30) == 1 then
                    room.pronej = random(100)
                    planDialogSet(3, "bat-s-prome"..random(3), 111, snek, "mluvi")
                elseif room.uhnu == 0 and (room.aktivni == -1 or room.poc > 30 and room.aktivni == main) then
                    room.uhnu = 300 + random(300)
                    pom2 = random(4)
                    if pom2 ~= 1 or roompole[1] > 0 then
                        planDialogSet(12, "bat-s-snek"..pom2, 111, snek, "mluvi")
                    end
                    roompole[1] = roompole[1] + 1
                end
            end
            if room.uhnu > 0 then
                room.uhnu = room.uhnu - 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dhled()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dhled.padal = 0

        return function()
            if dhled.padal == 4 then
                dhled.afaze = 0
                dhled.padal = 0
            elseif dhled.padal == 3 then
                dhled.padal = 4
            elseif dhled.padal == 2 then
                dhled.padal = 3
            elseif dhled.dir == dir_down then
                dhled.padal = 1
            elseif dhled.padal == 1 then
                dhled.afaze = 1
                dhled.padal = 2
            end
            dhled:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snek()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        snek.mluvi = 0

        return function()
            if odd(game_getCycles()) and snek.mluvi ~= 0 then
                snek.afaze = random(2)
            else
                snek.afaze = 0
            end
            snek:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_ibudik()
        return function()
            if odd(game_getCycles()) and ibudik:isTalking() then
                ibudik.afaze = 1
            else
                ibudik.afaze = 0
            end
            ibudik:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_mikroskop()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        mikroskop.poc = 0

        return function()
            if mikroskop.poc > 0 then
                mikroskop.poc = mikroskop.poc - 1
            else
                mikroskop.afaze = random(3)
                mikroskop.poc = random(6)
            end
            if mikroskop.dir ~= dir_no then
                mikroskop.poc = 0
            end
            mikroskop:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dhled()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_snek()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_ibudik()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_mikroskop()
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

