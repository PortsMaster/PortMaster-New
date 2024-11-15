
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

        room.odjel = 0
        room.qopatrne = 0
        room.hulakat = random(30) + 10 * pokus
        room.oci = 0
        room.reklopatrne = 0

        return function()
            if small:isTalking() or big:isTalking() then
                room.hulakat = -1
            end
            if room.odjel == 0 and big:isOut() and isReady(small) then
                room.odjel = 1
                switch(random(3)){
                    [0] = function()
                        addm(10, "zr-m-takfajn")
                    end,
                    [1] = function()
                        addm(10, "zr-m-tojeon")
                    end,
                    [2] = function()
                        addm(10, "zr-m-pockej")
                    end,
                }
            elseif room.qopatrne < 2 and room.reklopatrne == 1 and not small:isAlive() and small.X == 8 and isReady(big) then
                addv(3, "zr-v-vzdyt")
                room.qopatrne = 2
            end
            if room.qopatrne < 2 then
                if isReady(small) and small.X == 9 and isReady(big) and lahev.X == 8 and small:isLeft() and room.qopatrne == 0 then
                    if no_dialog() then
                        addv(1, "zr-v-opatrne")
                        room.reklopatrne = 1
                    else
                        room.reklopatrne = 0
                    end
                    room.qopatrne = 1
                end
            end
            if room.qopatrne == 1 and not small:isLeft() then
                room.qopatrne = 0
            end
            if isReady(small) and isReady(big) and no_dialog() then
                if room.hulakat > 0 then
                    room.hulakat = room.hulakat - 1
                elseif room.hulakat == 0 then
                    room.hulakat = -1
                    switch(random(3)){
                        [0] = function()
                            addv(3, "zr-v-hej")
                        end,
                        [1] = function()
                            addv(3, "zr-v-halo")
                        end,
                        [2] = function()
                            addv(3, "zr-v-jetunekdo")
                        end,
                    }
                    switch(random(3)){
                        [0] = function()
                            addm(9, "zr-m-nervi")
                        end,
                        [1] = function()
                            addm(9, "zr-m-nepovykuj")
                        end,
                        [2] = function()
                            addm(9, "zr-m-tadyjsem")
                        end,
                    }
                end
                if no_dialog() and small.trpelivost == 0 then
                    switch(random(2)){
                        [0] = function()
                            addm(0, "zr-m-obliceje")
                        end,
                        [1] = function()
                            addm(0, "zr-m-prestan")
                        end,
                    }
                    small.trpelivost = random(600) + 100
                end
                if no_dialog() and peri.cinnost == 7 and room.oci == 0 and random(100) < 50 then
                    addm(5, "zr-m-komu")
                    addv(10, "zr-v-nevim")
                    room.oci = 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_peri()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        peri.cinnost = 0

        return function()
            local anim_table = {
                [0] = function()
                    peri.delay = random(100) + 50
                    peri.cinnost = 1
                    peri.afaze = 0
                end,
                [1] = function()
                    if peri.delay == 0 then
                        peri.cinnost = peri.cinnost + 1
                    else
                        peri.delay = peri.delay - 1
                    end
                end,
                [2] = function()
                    peri.afaze = peri.cinnost - 1
                    peri.cinnost = peri.cinnost + 1
                end,
                [8] = function()
                    peri.delay = random(30) + 15
                    peri.cinnost = peri.cinnost + 1
                end,
                [9] = function()
                    if math.mod(game_getCycles(), 3) == 0 then
                        peri.afaze = 6 + random(2)
                    end
                    if peri.delay == 0 then
                        peri.cinnost = peri.cinnost + 1
                    else
                        peri.delay = peri.delay - 1
                    end
                end,
                [10] = function()
                    if random(100) < 30 then
                        peri.cinnost = 20
                    else
                        peri.cinnost = peri.cinnost + 1
                    end
                end,
                [11] = function()
                    peri.delay = random(5) + 2
                    peri.cinnost = peri.cinnost + 1
                end,
                [12] = function()
                    if random(100) < 20 then
                        peri.cinnost = peri.cinnost + 1
                    end
                end,
                [13] = function()
                    peri.afaze = 18 - peri.cinnost
                    peri.cinnost = peri.cinnost + 1
                end,
                [16] = function()
                    peri.afaze = peri.cinnost - 12
                    peri.cinnost = peri.cinnost + 1
                end,
                [19] = function()
                    if peri.delay == 0 then
                        peri.cinnost = 8
                    else
                        peri.delay = peri.delay - 1
                        peri.cinnost = 12
                    end
                end,
                [20] = function()
                    peri.afaze = 25 - peri.cinnost
                    peri.cinnost = peri.cinnost + 1
                end,
                [26] = function()
                    peri.cinnost = 0
                end,
            }

            anim_table[3] = anim_table[2]
            anim_table[4] = anim_table[2]
            anim_table[5] = anim_table[2]
            anim_table[6] = anim_table[2]
            anim_table[7] = anim_table[2]

            anim_table[14] = anim_table[13]
            anim_table[15] = anim_table[13]

            anim_table[17] = anim_table[16]
            anim_table[18] = anim_table[16]

            anim_table[21] = anim_table[20]
            anim_table[22] = anim_table[20]
            anim_table[23] = anim_table[20]
            anim_table[24] = anim_table[20]
            anim_table[25] = anim_table[20]

            switch(peri.cinnost)(anim_table)
            peri:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_zrcadlo()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        zrcadlo:setEffect("mirror")
    end

    -- -------------------------------------------------------------
    local function prog_init_naboj()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        naboj.nabita = 0

        return function()
            if naboj.nabita == 0 and naboj.X == 12 and naboj.Y == 8 then
                naboj.nabita = 1
                room:talk("zr-x-nabito")
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false
        local xicht = 0

        small.trpelivost = random(50) + 30

        return function()
            if not small:isLeft() and (xdist(small, zrcadlo) == -1 or xdist(small, zrcadlo) == -2) and ydist(small, zrcadlo) == 0 then
                if random(100) < 30 then
                    xicht = random(9)
                end
            else
                xicht = 0
            end
            if xicht ~= 0 then
                small:useSpecialAnim("head_all", xicht)
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local xicht = 0
        return function()
            if not big:isLeft() and (xdist(big, zrcadlo) == -1 or xdist(big, zrcadlo) == -2) and (zrcadlo.Y == big.Y or zrcadlo.Y == big.Y - 1) then
                if random(100) < 30 then
                    xicht = random(8)
                end
                if small.trpelivost > 0 then
                    small.trpelivost = small.trpelivost - 1
                end
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
    subinit = prog_init_peri()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_zrcadlo()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_naboj()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_small()
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

