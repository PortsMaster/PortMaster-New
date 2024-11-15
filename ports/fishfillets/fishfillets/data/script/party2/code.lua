
local function setViewShift(model, reference, shift_x, shift_y)
    model_setViewShift(model.index,
        reference.X + shift_x - model.X,
        reference.Y + shift_y - model.Y)
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky15.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.okno1 = 0
        room.okno2 = 0
        room.okna = 0
        room.uvod = 0
        room.opikniku = random(8) + 1
        repeat
            room.ounave = random(16) + 5
        until math.abs(room.ounave - room.opikniku) > 3
        repeat
            room.oublizeni = random(24) + 9
        until math.abs(room.oublizeni - room.opikniku) > 3 and math.abs(room.oublizeni - room.ounave) > 3
        room.otezkosti = random(500)

        return function()
            if (room.okno1 == 0 or room.okno2 == 0) and random(1000) < 25 then
                if room.okno1 == 0 and room.okno2 == 0 and random(2) == 0 then
                    pom1 = 1
                elseif room.okno1 == 0 and room.okno2 == 0 then
                    pom1 = 2
                elseif room.okno1 == 0 then
                    pom1 = 1
                else
                    pom1 = 2
                end
                switch(random(5)){
                    [0] = function()
                        if frkavec.zprava == 0 then
                            frkavec.zprava = pom1
                            switch(pom1){
                                [1] = function()
                                    room.okno1 = 1
                                end,
                                [2] = function()
                                    room.okno2 = 1
                                end,
                            }
                        end
                    end,
                    [1] = function()
                        if hnat.zprava == 0 then
                            hnat.zprava = pom1
                            switch(pom1){
                                [1] = function()
                                    room.okno1 = 1
                                end,
                                [2] = function()
                                    room.okno2 = 1
                                end,
                            }
                        end
                    end,
                    [2] = function()
                        if lahev.zprava == 0 then
                            lahev.zprava = pom1
                            switch(pom1){
                                [1] = function()
                                    room.okno1 = 1
                                end,
                                [2] = function()
                                    room.okno2 = 1
                                end,
                            }
                        end
                    end,
                    [3] = function()
                        if kuk.zprava == 0 then
                            kuk.zprava = pom1
                            switch(pom1){
                                [1] = function()
                                    room.okno1 = 1
                                end,
                                [2] = function()
                                    room.okno2 = 1
                                end,
                            }
                        end
                    end,
                    [4] = function()
                        if ruka.zprava == 0 then
                            ruka.zprava = pom1
                            switch(pom1){
                                [1] = function()
                                    room.okno1 = 1
                                end,
                                [2] = function()
                                    room.okno2 = 1
                                end,
                            }
                        end
                    end,
                }
            end
            if no_dialog() and isReady(small) and isReady(big) then
                if room.okno1 + room.okno2 == 2 and room.okna < 2 then
                    if room.opikniku > 0 then
                        room.opikniku = room.opikniku - 1
                    end
                    if room.ounave > 0 then
                        room.ounave = room.ounave - 1
                    end
                    if room.oublizeni > 0 then
                        room.oublizeni = room.oublizeni - 1
                    end
                end
                if ocel.X >= 23 and room.otezkosti > 0 then
                    room.otezkosti = room.otezkosti - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    switch(pokus){
                        [1] = function()
                            pom1 = 1
                        end,
                        [2] = function()
                            pom1 = random(3) + 1
                        end,
                        default = function()
                            pom1 = random(5)
                        end,
                    }
                    if pom1 > 3 then
                        pom1 = 0
                    end
                    adddel(10 + random(10))
                    if pom1 >= 1 then
                        addm(0, "pt2-m-parnik")
                    end
                    if pom1 >= 2 then
                        addv(random(30) + 10, "pt2-v-zmena")
                    end
                    if pom1 >= 3 then
                        planBusy(small, true)
                        addm(5, "pt2-m-hrac")
                        adddel(10)
                        planBusy(small, false)
                    end
                elseif room.opikniku == 0 then
                    room.opikniku = random(50) + 50
                    addm(20, "pt2-m-piknik"..random(4))
                elseif room.ounave == 0 then
                    room.ounave = random(50) + 50
                    addv(20, "pt2-v-unaveni"..random(2))
                elseif room.oublizeni == 0 then
                    room.oublizeni = random(50) + 50
                    addv(20, "pt2-v-nemohou"..random(2))
                elseif room.otezkosti == 0 then
                    room.otezkosti = -1
                    addv(20, "pt2-v-minule"..random(2))
                end
            end
            room.okna = room.okno1 + room.okno2
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_kuk()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        kuk:setEffect("invisible")
        kuk.zprava = 0
        kuk.strana = 0
        kuk.okno = 0

        return function()
            if kuk.zprava >= 1 and kuk.zprava <= 2 then
                kuk.okno = kuk.zprava
                kuk.zprava = 3
                kuk.strana = random(2)
                switch(random(3)){
                    [0] = function()
                        kuk.anim = "a0a1a2a3a4a5d?1-10a4a3a2a1a0"
                    end,
                    [1] = function()
                        kuk.anim = "a6a7a8a9a10"
                        switch(random(3)){
                            [0] = function()
                                kuk.anim = kuk.anim.."d?1-10"
                            end,
                            [1] = function()
                                kuk.anim = kuk.anim.."d?1-4a11a12a13a14a15a16d4a15a14d?5-10a13a12a11"
                            end,
                            [2] = function()
                                kuk.anim = kuk.anim.."d?1-4a11a12a13a14a15a16d?3-10a15a14a13a12a11"
                            end,
                        }
                        kuk.anim = kuk.anim.."a10a9a8a7a6"
                    end,
                    [2] = function()
                        kuk.anim = "a17a18a19a20a21a22a23d?1-10a22a21a20a19a18a17"
                    end,
                }
                resetanim(kuk)
            end
            if kuk.anim == "" or endanim(kuk) then
                if kuk.zprava == 3 then
                    if kuk.okno == 1 then
                        room.okno1 = 0
                    else
                        room.okno2 = 0
                    end
                    kuk.zprava = 0
                    kuk.okno = 0
                    kuk:setEffect("invisible")
                end
            else
                goanim(kuk)
            end
            switch(kuk.okno){
                [0] = function()
                    setViewShift(kuk, kabina, 3, 1)
                end,
                [1] = function()
                    setViewShift(kuk, kabina, 3, 1)
                end,
                [2] = function()
                    setViewShift(kuk, kabina, 9, 1)
                end,
            }
            if kuk.okno == 0 then
                kuk:setEffect("invisible")
            else
                if kuk.strana == 1  then
                    kuk:setEffect("reverse")
                else
                    kuk:setEffect("none")
                end
            end
            kuk:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_ruka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        ruka:setEffect("invisible")
        ruka.zprava = 0
        ruka.strana = 0
        ruka.okno = 0

        return function()
            if ruka.zprava >= 1 and ruka.zprava <= 2 then
                ruka.okno = ruka.zprava
                ruka.zprava = 3
                ruka.strana = random(2)
                ruka.anim = ""
                pom2 = 0
                for pom1 = 1, random(14) + 2 do
                    ruka.anim = ruka.anim.."a"..pom2
                    if pom2 >= 5 then
                        ruka.anim = ruka.anim.."d1"
                    end
                    if pom2 == 6 then
                        pom2 = 5
                    else
                        pom2 = pom2 + 1
                    end
                end
                for pom1 = pom2 - 1, 0, -1 do
                    ruka.anim = ruka.anim.."a"..pom1
                end
                resetanim(ruka)
            end
            if ruka.anim == "" or endanim(ruka) then
                if ruka.zprava == 3 then
                    if ruka.okno == 1 then
                        room.okno1 = 0
                    else
                        room.okno2 = 0
                    end
                    ruka.zprava = 0
                    ruka.okno = 0
                    ruka:setEffect("invisible")
                end
            else
                goanim(ruka)
            end
            switch(ruka.okno){
                [0] = function()
                    setViewShift(ruka, kabina, 3, 1)
                end,
                [1] = function()
                    setViewShift(ruka, kabina, 3, 1)
                end,
                [2] = function()
                    setViewShift(ruka, kabina, 9, 1)
                end,
            }
            if ruka.okno == 0 then
                ruka:setEffect("invisible")
            else
                if ruka.strana == 1  then
                    ruka:setEffect("reverse")
                else
                    ruka:setEffect("none")
                end
            end
            ruka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_frkavec()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        frkavec:setEffect("invisible")
        frkavec.zprava = 0
        frkavec.strana = 0
        frkavec.okno = 0
        frkavec.frkacka = 0

        return function()
            if frkavec.zprava >= 1 and frkavec.zprava <= 2 then
                frkavec.okno = frkavec.zprava
                frkavec.zprava = 3
                frkavec.strana = random(2)
                frkavec.anim = "a0a1a2a3a4a5"
                for pom1 = 1, random(5) + 1 do
                    if random(2) == 0 then
                        frkavec.anim = frkavec.anim.."d?5-20a6d6a5"
                    else
                        frkavec.anim = frkavec.anim.."d?5-20a6s[zprava],1s[zprava],2d6s[zprava],1s[zprava],0,a5"
                    end
                end
                frkavec.anim = frkavec.anim.."a4a3a2a1a0"
                resetanim(frkavec)
            end
            if frkavec.anim == "" or endanim(frkavec) then
                if frkavec.zprava == 3 then
                    if frkavec.okno == 1 then
                        room.okno1 = 0
                    else
                        room.okno2 = 0
                    end
                    frkavec.zprava = 0
                    frkavec.okno = 0
                    frkavec:setEffect("invisible")
                end
            else
                goanim(frkavec)
            end
            switch(frkavec.okno){
                [0] = function()
                    setViewShift(frkavec, kabina, 3, 1)
                end,
                [1] = function()
                    setViewShift(frkavec, kabina, 3, 1)
                end,
                [2] = function()
                    setViewShift(frkavec, kabina, 9, 1)
                end,
            }
            if frkavec.okno == 0 then
                frkavec:setEffect("invisible")
            else
                if frkavec.strana == 1 then
                    frkavec:setEffect("reverse")
                else
                    frkavec:setEffect("none")
                end
            end
            frkavec:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hnat()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        hnat.drazdit = random(5) + 1
        hnat:setEffect("invisible")
        hnat.zprava = 0
        hnat.strana = 0
        hnat.okno = 0

        return function()
            if hnat.zprava >= 1 and hnat.zprava <= 2 then
                hnat.okno = hnat.zprava
                hnat.zprava = 3
                hnat.strana = random(2)
                if hnat.drazdit > 0 then
                    hnat.drazdit = hnat.drazdit - 1
                    switch(random(4)){
                        [0] = function()
                            hnat.anim = "a0a1a2a3a4a5a6a7d1a6a4"
                        end,
                        [1] = function()
                            hnat.anim = "a0a1a2a3a4a5a6a7a8d1a6a4"
                        end,
                        [2] = function()
                            hnat.anim = "a0a1a2a3a4a5a6a7a8a9d1a8a6a4"
                        end,
                        [3] = function()
                            hnat.anim = "a0a1a2a3a4a5a6a7a8a9a10d1a8a6a4"
                        end,
                    }
                    for pom1 = 1, random(5) do
                        hnat.anim = hnat.anim.."d1a3d1a4"
                    end
                    hnat.anim = hnat.anim.."a3a2a1a0"
                elseif hnat.drazdit == 0 then
                    hnat.anim = "a0a1a2a3a4a5a6a7a8a9a10a11a12a13"
                    switch(random(3)){
                        [0] = function()
                            hnat.anim = hnat.anim.."a14a15a16a17a18a19a20a21"
                        end,
                        [1] = function()
                            hnat.anim = hnat.anim.."d3a15a17a19a21"
                        end,
                        [2] = function()
                            hnat.anim = hnat.anim.."d7a15a18a21"
                        end,
                    }
                    hnat.drazdit = -random(5) - 2
                elseif hnat.drazdit < 0 then
                    hnat.drazdit = hnat.drazdit + 1
                    if hnat.drazdit == 0 then
                        hnat.drazdit = random(5) + 1
                    end
                end
                resetanim(hnat)
            end
            if hnat.anim == "" or endanim(hnat) then
                if hnat.zprava == 3 then
                    if hnat.okno == 1 then
                        room.okno1 = 0
                    else
                        room.okno2 = 0
                    end
                    hnat.zprava = 0
                    hnat.okno = 0
                end
            else
                goanim(hnat)
            end
            switch(hnat.okno){
                [0] = function()
                    setViewShift(hnat, kabina, 3, 1)
                end,
                [1] = function()
                    setViewShift(hnat, kabina, 3, 1)
                end,
                [2] = function()
                    setViewShift(hnat, kabina, 9, 1)
                end,
            }
            if hnat.okno == 0 then
                hnat:setEffect("invisible")
            else
                if hnat.strana == 1 then
                    hnat:setEffect("reverse")
                else
                    hnat:setEffect("none")
                end
            end
            hnat:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_lahev()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        lahev:setEffect("invisible")
        lahev.zprava = 0
        lahev.strana = 0
        lahev.okno = 0

        return function()
            if lahev.zprava >= 1 and lahev.zprava <= 2 then
                lahev.okno = lahev.zprava
                lahev.zprava = 3
                lahev.strana = random(2)
                lahev.anim = "a0a1a2a3a4a5a6a7a8"
                for pom1 = 1, random(4) do
                    for pom1 = 1, random(3) + 1 do
                        lahev.anim = lahev.anim.."a9a10"
                    end
                    lahev.anim = lahev.anim.."a11a12a13a14a9d?1-6"
                end
                lahev.anim = lahev.anim.."a8a7a6a5a4a3a2a1a0"
                resetanim(lahev)
            end
            if lahev.anim == "" or endanim(lahev) then
                if lahev.zprava == 3 then
                    if lahev.okno == 1 then
                        room.okno1 = 0
                    else
                        room.okno2 = 0
                    end
                    lahev.zprava = 0
                    lahev.okno = 0
                end
            else
                goanim(lahev)
            end
            switch(lahev.okno){
                [0] = function()
                    setViewShift(lahev, kabina, 3, 1)
                end,
                [1] = function()
                    setViewShift(lahev, kabina, 3, 1)
                end,
                [2] = function()
                    setViewShift(lahev, kabina, 9, 1)
                end,
            }
            if lahev.okno == 0 then
                lahev:setEffect("invisible")
            else
                if lahev.strana == 1 then
                    lahev:setEffect("reverse")
                else
                    lahev:setEffect("none")
                end
            end
            lahev:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_frk()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        frk:setEffect("invisible")

        return function()
            frk.okno = 0
            if frkavec.frkacka > 0 then
                if frkavec.strana == 0 and frkavec.okno == 2 or frkavec.strana == 1 and frkavec.okno == 1 then
                    frk.okno = 3 - frkavec.okno
                    frk.afaze = frkavec.frkacka - 1
                end
            end
            switch(frk.okno){
                [0] = function()
                    setViewShift(frk, kabina, 3, 1)
                end,
                [1] = function()
                    setViewShift(frk, kabina, 3, 1)
                end,
                [2] = function()
                    setViewShift(frk, kabina, 9, 1)
                end,
            }
            if frk.okno == 0 then
                frk:setEffect("invisible")
            else
                if frk.strana == 1 then
                    frk:setEffect("reverse")
                else
                    frk:setEffect("none")
                end
            end
        end
    end
    -- -------------------------------------------------------------
    local function prog_init_glass1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        local glasses = {glass1, glass_plate}
        for pom1, glass in pairs(glasses) do
            glass.wav = 0
        end

        return function()
            for pom1, glass in pairs(glasses) do
                pom2 = glass.wav
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
                glass.wav = pom2
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
    subinit = prog_init_kuk()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_ruka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_frkavec()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hnat()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_lahev()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_frk()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_glass1()
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

