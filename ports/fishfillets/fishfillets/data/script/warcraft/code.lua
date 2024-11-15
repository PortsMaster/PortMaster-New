
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky09.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        if pokus == 1 then
            room.uvod = 3
        else
            room.uvod = random(3)
        end
        room.oregistry = random(5000) + 500
        room.odolech = 0
        room.oblizardu = 0

        return function()
            if room.oblizardu == 0 and isReady(big) and big.X == 47 and big.Y == 11 then
                room.oblizardu = 1
                big:setBusy(true)
                addv(5, "war-v-blizzard")
                if isReady(small) then
                    small:setBusy(true)
                    addm(4, "war-m-hodiny")
                end
                planBusy(big, false)
                planBusy(small, false)
            end
            if no_dialog() and isReady(small) and isReady(big) then
                for pom1 = 1, 10 do
                    if room.oregistry > 0 then
                        room.oregistry = room.oregistry - 1
                    end
                end
                if room.uvod > 0 then
                    if room.uvod == 1 or room.uvod == 3 then
                        addm(random(30) + 10, "war-m-kam")
                        addv(random(30) + 10, "war-v-povedome")
                    end
                    if room.uvod == 2 or room.uvod == 3 then
                        switch(random(2)){
                            [0] = function()
                                addm(random(30) + 20, "war-m-hrad")
                            end,
                            [1] = function()
                                addm(random(30) + 20, "war-m-ocel")
                            end,
                        }
                        if random(100) < 50 or pokus == 1 then
                            addv(random(200) + 10, "war-v-vesnicane")
                            addm(4, "war-m-peoni")
                        end
                    end
                    room.uvod = 0
                elseif room.odolech == 0 and (dul1.dir ~= dir_no or dul2.dir ~= dir_no) and random(100) < 10 then
                    room.odolech = 0
                    addv(random(30) + 10, "war-v-doly")
                    addm(random(20), "war-m-povazuji")
                elseif room.oregistry == 0 then
                    room.oregistry = -1
                    addv(20, "war-v-pohadka")
                    addm(random(40) + 10, "war-m-pichat")
                    addv(2, "war-v-prozradit")
                    addm(4, "war-m-aznato")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_knight1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        knight1.hybese = 0
        knight1.unejvelka = 1
        knight1.unejmala = 0

        return function()
            pom2 = 0
            if dist(big, knight1) <= 1 then
                pom1 = 1
            else
                pom1 = 0
            end
            if knight1.unejvelka == 0 and pom1 == 1 then
                pom2 = 1
            end
            knight1.unejvelka = pom1
            if dist(small, knight1) <= 1 then
                pom1 = 1
            else
                pom1 = 0
            end
            if knight1.unejmala == 0 and pom1 == 1 then
                pom2 = 1
            end
            knight1.unejmala = pom1
            if knight1.dir ~= dir_no and knight1.hybese == 0 then
                pom2 = 2
            end
            if knight1.dir ~= dir_no then
                knight1.hybese = 1
            else
                knight1.hybese = 0
            end
            switch(pom2){
                [1] = function()
                    knight1:talk("war-k-ready"..random(3), VOLUME_FULL)
                end,
                [2] = function()
                    knight1:talk("war-k-move" ..random(3), VOLUME_FULL)
                end,
            }
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_knight2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        knight2.hybese = 0
        knight2.unejvelka = 0
        knight2.unejmala = 0

        return function()
            pom2 = 0
            if dist(big, knight2) <= 1 then
                pom1 = 1
            else
                pom1 = 0
            end
            if knight2.unejvelka == 0 and pom1 == 1 then
                pom2 = 1
            end
            knight2.unejvelka = pom1
            if dist(small, knight2) <= 1 then
                pom1 = 1
            else
                pom1 = 0
            end
            if knight2.unejmala == 0 and pom1 == 1 then
                pom2 = 1
            end
            knight2.unejmala = pom1
            if knight2.dir ~= dir_no and knight2.hybese == 0 then
                pom2 = 2
            end
            if knight2.dir ~= dir_no then
                knight2.hybese = 1
            else
                knight2.hybese = 0
            end
            switch(pom2){
                [1] = function()
                    knight2:talk("war-k-ready"..random(3), VOLUME_FULL)
                end,
                [2] = function()
                    knight2:talk("war-k-move"..random(3), VOLUME_FULL)
                end,
            }
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_archer1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        archer1.hybese = 0
        archer1.unejvelka = 1
        archer1.unejmala = 0

        return function()
            pom2 = 0
            if dist(big, archer1) <= 1 then
                pom1 = 1
            else
                pom1 = 0
            end
            if archer1.unejvelka == 0 and pom1 == 1 then
                pom2 = 1
            end
            archer1.unejvelka = pom1
            if dist(small, archer1) <= 1 then
                pom1 = 1
            else
                pom1 = 0
            end
            if archer1.unejmala == 0 and pom1 == 1 then
                pom2 = 1
            end
            archer1.unejmala = pom1
            if archer1.dir ~= dir_no and archer1.hybese == 0 then
                pom2 = 2
            end
            if archer1.dir ~= dir_no then
                archer1.hybese = 1
            else
                archer1.hybese = 0
            end
            switch(pom2){
                [1] = function()
                    archer1:talk("war-a-ready"..random(2), VOLUME_FULL)
                end,
                [2] = function()
                    archer1:talk("war-a-move"..random(2), VOLUME_FULL)
                end,
            }
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_archer2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        archer2.hybese = 0
        archer2.unejvelka = 1
        archer2.unejmala = 0

        return function()
            pom2 = 0
            if dist(big, archer2) <= 1 then
                pom1 = 1
            else
                pom1 = 0
            end
            if archer2.unejvelka == 0 and pom1 == 1 then
                pom2 = 1
            end
            archer2.unejvelka = pom1
            if dist(small, archer2) <= 1 then
                pom1 = 1
            else
                pom1 = 0
            end
            if archer2.unejmala == 0 and pom1 == 1 then
                pom2 = 1
            end
            archer2.unejmala = pom1
            if archer2.dir ~= dir_no and archer2.hybese == 0 then
                pom2 = 2
            end
            if archer2.dir ~= dir_no then
                archer2.hybese = 1
            else
                archer2.hybese = 0
            end
            switch(pom2){
                [1] = function()
                    archer2:talk("war-a-ready"..random(2), VOLUME_FULL)
                end,
                [2] = function()
                    archer2:talk("war-a-move"..random(2), VOLUME_FULL)
                end,
            }
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_knight1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_knight2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_archer1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_archer2()
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

