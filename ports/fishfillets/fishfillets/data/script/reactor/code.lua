
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky07.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.pldpred = random(2)
        room.zacni = 0
        room.tyce = random(5) + 4

        return function()
            if room.pldpred == 1 and room.zacni == 0 or room.pldpred == 0 and room.zacni == 1 then
                room.pldpred = -1
                if room.zacni == 0 then
                    addm(random(30) + 20, "rea-m-proboha")
                else
                    addm(random(100) + 50, "rea-m-proboha")
                end
                addv(14, "rea-v-coto")
                addm(6, "rea-m-nevim")
                planSet(pld, "smutny", 60)
                pld:planDialog(3, "rea-x-pldik")
            end
            if room.zacni == 0 then
                room.zacni = 1
                if room.pldpred == 1 then
                    addm(random(150) + 60, "rea-m-comyslis")
                else
                    addm(random(30) + 20, "rea-m-comyslis")
                end
                addv(6, "rea-v-patrne")
                addv(random(130) + 30, "rea-v-ledaze")
                addm(random(70), "rea-m-mohl")
                addv(6, "rea-v-tozni")
                addm(random(200) + 20, "rea-m-anebo")
                addv(2, "rea-v-acoby")
                addm(12, "rea-m-cojavim")
                addv(random(20) + 2, "rea-v-radeji")
                addm(5, "rea-m-jakmuzes")
                addv(4, "rea-v-kolik")
                addv(random(10) + 15, "rea-v-takvidis")
            end
            if isReady(small) and isReady(big) then
                if room.zacni == 1 and no_dialog() and tyc.padlo >= room.tyce and tyc:isTalking() then
                    room.tyce = 1000
                    addm(9, "rea-m-doufam")
                    addv(5, "rea-v-nemudruj")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_tyc()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        tyc.padlo = 0
        local tyce = {}
        for index = 0, 12 do
            tyce[index] = getModelsTable()[tyc.index + index]
            tyce[index].pada = false
        end

        return function()
            local count = game_getCycles()
            for index, model in pairs(tyce) do
                model.afaze = 2 - math.floor(math.mod(count, 6) / 2)
                model:updateAnim()
            end
            for pom1, model in pairs(tyce) do
                switch(model.dir){
                    [dir_down] = function()
                        model.pada = true
                    end,
                    default = function()
                        if model.pada then
                            model.pada = false
                            tyc:talk("rea-x-reakttyc", VOLUME_FULL)
                            tyc.padlo = tyc.padlo + 1
                        end
                    end,
                }
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pld()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pld.vlnit = 0
        pld.del = 0
        pld.ocko = 0
        pld.smer = 0
        pld.faze = 0
        pld.smutny = 0

        return function()
            switch(pld.dir){
                [dir_no] = function()
                    if pld.vlnit == -1 then
                        pld.vlnit = 8
                    end
                end,
                [dir_down] = function()
                    pld.vlnit = -1
                end,
                default = function()
                    pld.vlnit = 8
                end,
            }
            if pld.vlnit > 0 then
                pld.smutny = 0
            end
            if pld.vlnit > 0 then
                if pld.del == 0 then
                    if pld.vlnit < 3 then
                        pld.del = 3
                    elseif pld.vlnit < 6 then
                        pld.del = 2
                    else
                        pld.del = 1
                    end
                    if random(2) == 0 then
                        pld.afaze = math.mod(pld.afaze + 1, 4)
                    else
                        pld.afaze = math.mod(pld.afaze + 3, 4)
                    end
                    pld.vlnit = pld.vlnit - 1
                    if pld.vlnit == 0 then
                        pld.del = 0
                    end
                    if pld.vlnit == 0 then
                        pld.afaze = 0
                    elseif pld.vlnit == 1 then
                        pld.afaze = 3
                    end
                else
                    pld.del = pld.del - 1
                end
            elseif pld.smutny > 0 then
                if pld.ocko == 0 then
                    if random(100) < 10 then
                        pld.ocko = 3
                    end
                end
                if pld.ocko > 0 then
                    pld.ocko = pld.ocko - 1
                end
                if pld.ocko > 0 then
                    pld.afaze = 15
                else
                    pld.afaze = 14
                end
                pld.smutny = pld.smutny - 1
            else
                if random(100) < 10 then
                    pld.smer = 1 - pld.smer
                end
                switch(pld.faze){
                    [0] = function()
                        pld.afaze = 0
                        if random(100) < 10 then
                            pld.faze = 1
                        end
                    end,
                    [5] = function()
                        pld.afaze = 0
                        pld.faze = 0
                    end,
                    default = function()
                        if pld.faze == 1 or pld.faze == 4 then
                            pld.faze = pld.faze + 1
                            pld.afaze = 4
                        elseif pld.faze == 2 or pld.faze == 3 then
                            pld.faze = pld.faze + 1
                            pld.afaze = 5
                        end
                    end,
                }
                switch(pld.afaze){
                    [0] = function()
                        if pld.smer == 1 then
                            pld.afaze = 6
                        end
                    end,
                    [4] = function()
                        if pld.smer == 1 then
                            pld.afaze = 7
                        end
                    end,
                }
                if pld.ocko == 0 then
                    if random(100) < 10 then
                        pld.ocko = 3
                    end
                end
                if pld.ocko > 0 then
                    pld.ocko = pld.ocko - 1
                end
                if pld.ocko > 0 then
                    if pld.afaze == 0 then
                        pld.afaze = 9
                    else
                        pld.afaze = pld.afaze + 6
                    end
                end
            end
            pld:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_tyc()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pld()
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

