
-- -----------------------------------------------------------------
-- actor codes:
-- 111 ... piskac
-- 121 ... basak
-- 131 ... melodak1, melodak2
local PISKAC_SONG = 111
local BASAK_SONG = 121
local MELODAK_SONG = 131

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.blok = -1
        room.startblok = 0
        room.uvod = 0
        room.dohrat = randint(300, 700)
        sound_playMusic("music/rybky04.ogg")

        return function()
            room.startblok = 0
            if room.blok >= 0 then
                if not model_isTalking(PISKAC_SONG) then
                    room.blok = room.blok + 1
                    if room.blok == 17 then
                        room.blok = 1
                    end
                    room.startblok = 1
                end
            end
            if room.blok > 0 then
                sound_stopMusic()
            end
            if no_dialog() and isReady(small) and isReady(big) then
                if room.dohrat > 0 then
                    room.dohrat = room.dohrat - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    switch(pokus){
                        [1] = function()
                            pom1 = 4
                        end,
                        [2] = function()
                            pom1 = random(5)
                        end,
                        [3] = function()
                            pom1 = random(5)
                        end,
                        default = function()
                            if random(2) == 0 then
                                pom1 = 0
                            else
                                pom1 = random(5)
                            end
                        end,
                    }
                    if pom1 > 0 then
                        addm(20, "dr-m-tojesnad")
                        if random(2) == 0 then
                            addv(3, "dr-v-jiste")
                        end
                    end
                    if pom1 >= 2 then
                        addm(random(20) + 5, "dr-m-musela")
                    end
                    if pom1 >= 4 then
                        addv(random(15) + 3, "dr-v-mozna")
                    else
                        adddel(random(20) + 25)
                    end
                    if pom1 >= 3 then
                        addm(0, "dr-m-hruza")
                    end
                elseif room.dohrat == 0 then
                    room.dohrat = -1
                    sound_stopMusic()
                    adddel(10)
                    planSet(melodak1, "afaze", 3)
                    melodak1:planDialog(random(10) + 5, "d1-1-hudba"..random(3))
                    adddel(5)
                    planSet(basak, "hlasky", 2)
                    planSet(piskac, "hlasky", 2)
                    adddel(10)
                    planSet(melodak1, "hlasky", 1)
                    hlavni:planDialog(30 + random(10), "d1-5-nevadi"..random(3))
                    adddel(10)
                    planSet(room, "blok", 0)
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_melodak1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        melodak1.hrat = -1
        melodak1.mrk = 0
        melodak1.hlasky = 0
        melodak1.posl = -1

        return function()
            if melodak1.hlasky > 0 and not melodak1:isTalking() then
                repeat
                    pom1 = random(3)
                until pom1 ~= melodak1.posl
                melodak1.posl = pom1
                melodak1:talk("d1-2-brb"..pom1)
                melodak1.hlasky = melodak1.hlasky - 1
            end
            if room.startblok == 1 then
                if isIn(room.blok, {7, 8, 11, 12, 15, 16}) then
                    melodak1.hrat = 0
                else
                    melodak1.hrat = -1
                end
                if melodak1.hrat > -1 then
                    model_killSound(MELODAK_SONG)
                    model_talk(MELODAK_SONG, "d1-z-v"..melodak1.hrat)
                    setanim(melodak1, "a4a2a4a2a4a2a4a2a4a2d2a4a2d2a4a2d2a4a2d2a4a2d2a4a2d2" .. "a4a2a4a2a4a2a4a2a4a2d2a4a2d2a4a2d2a4a2d2a4a2d4a4")
                else
                    setanim(melodak1, "d?5-10a0")
                end
            end
            if melodak1.mrk == 1 and melodak1.afaze ~= 0 then
                melodak1.afaze = melodak1.afaze + 1
            end
            goanim(melodak1)
            if melodak1:isTalking() then
                melodak1.afaze = random(2) * 2 + 2
            elseif room.blok < 0 and random(100) < 5 then
                melodak1.afaze = 0
            end
            if random(100) < 5 then
                melodak1.mrk = 1
            else
                melodak1.mrk = 0
            end
            if melodak1.mrk == 1 and melodak1.afaze > 0 then
                melodak1.afaze = melodak1.afaze - 1
            end
            melodak1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlavni()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        return function()
            if hlavni:isTalking() then
                hlavni.afaze = random(3)
            else
                hlavni.afaze = 0
            end
            hlavni:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_basak()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        basak.hrat = -1
        basak.mrk = 0
        basak.afaze = 2
        basak.hlasky = 0
        basak.posl = -1

        return function()
            if basak.hlasky > 0 and not basak:isTalking() then
                repeat
                    pom1 = random(3)
                until pom1 ~= basak.posl
                basak.posl = pom1
                basak:talk("d1-4-brb"..pom1)
                basak.hlasky = basak.hlasky - 1
            end
            if room.startblok == 1 then
                if isIn(room.blok, {1, 2, 3}) then
                    basak.hrat = -1
                elseif room.blok == 4 then
                    basak.hrat = 1
                elseif isIn(room.blok, {5, 6, 9, 10, 13, 14}) then
                    basak.hrat = 2
                else
                    basak.hrat = 3
                end
                if basak.hrat > -1 then
                    model_killSound(BASAK_SONG)
                    model_talk(BASAK_SONG, "d1-z-b"..basak.hrat)
                    if basak.hrat == 1 then
                        setanim(basak, "a0d3a2d3a0d19a2d3a0d3a2d3a0d19a2d3")
                    else
                        setanim(basak, "a0d3a2d3a0d19a2d3a0d3a2d3a0d6a2a0d3a2d3a0d6a2")
                    end
                end
            end
            if basak.mrk == 1 then
                basak.afaze = basak.afaze - 1
            end
            if basak:isTalking() then
                basak.afaze = random(2) * 2
            elseif room.blok < 0 then
                basak.afaze = 2
            end
            goanim(basak)
            if random(100) < 5 then
                basak.mrk = 1
            else
                basak.mrk = 0
            end
            if basak.mrk == 1 then
                basak.afaze = basak.afaze + 1
            end
            basak:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_piskac()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        piskac.hrat = -1
        piskac.xicht = 0
        piskac.hlasky = 0
        piskac.posl = -1

        return function()
            if piskac.hlasky > 0 and not piskac:isTalking() then
                repeat
                    pom1 = random(3)
                until pom1 ~= piskac.posl
                piskac.posl = pom1
                piskac:talk("d1-3-brb"..pom1)
                piskac.hlasky = piskac.hlasky - 1
            end
            if piskac:isTalking() then
                piskac.xicht = random(2) * 2
            else
                piskac.xicht = 0
            end
            if room.blok > -1 then
                piskac.xicht = 6
            end
            if room.startblok == 1 then
                if isIn(room.blok, {1, 2, 5, 6, 9, 10, 13, 14}) then
                    piskac.hrat = 1
                else
                    piskac.hrat = 2
                end
                piskac.xicht = 4
                model_killSound(PISKAC_SONG)
                model_talk(PISKAC_SONG, "d1-z-p"..piskac.hrat)
            end
            if random(100) < 5 then
                piskac.afaze = piskac.xicht + 1
            else
                piskac.afaze = piskac.xicht
            end
            piskac:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_melodak2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        melodak2.hrat = -1
        melodak2.mrk = 0

        return function()
            if room.startblok == 1 then
                if isIn(room.blok, {9, 13}) then
                    melodak2.hrat = 1
                elseif isIn(room.blok, {10, 14}) then
                    melodak2.hrat = 2
                else
                    melodak2.hrat = -1
                end
                if melodak2.hrat > -1 then
                    model_killSound(MELODAK_SONG)
                    model_talk(MELODAK_SONG, "d1-z-v"..melodak2.hrat)
                    if melodak2.hrat == 1 then
                        setanim(melodak2, "a2d15a3d15a2d28a0")
                    else
                        setanim(melodak2, "a3d15a2d15a3d15a2d7")
                    end
                else
                    melodak2.afaze = 0
                end
            end
            if melodak2.mrk == 1 and melodak2.afaze == 1 then
                melodak2.afaze = melodak2.afaze - 1
            end
            goanim(melodak2)
            if random(100) < 5 then
                melodak2.mrk = 1
            else
                melodak2.mrk = 0
            end
            if melodak2.mrk == 1 and melodak2.afaze == 0 then
                melodak2.afaze = melodak2.afaze + 1
            end
            melodak2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snecek()
        return function()
            if room.blok > 0 then
                if snecek.afaze < 2 then
                    snecek.afaze = snecek.afaze + 1
                end
            end
            snecek:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_melodak1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlavni()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_basak()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_piskac()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_melodak2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_snecek()
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

