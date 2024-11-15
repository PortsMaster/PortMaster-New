
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky04.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false
        local roompole = createArray(1)

        if roompole[0] == 0 then
            roompole[0] = random(2) + 1
        end
        room.uvod = 0
        room.osundavani = 0
        room.otvaru = 0
        room.rikanka = random(600) + 200 * pokus

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.rikanka > 30 then
                    room.rikanka = room.rikanka - 1
                elseif room.rikanka > 10 and look_at(small, snecek) then
                    room.rikanka = room.rikanka - 1
                elseif room.rikanka > 0 and look_at(small, snecek) and small.Y == snecek.Y then
                    room.rikanka = room.rikanka - 1
                end
                if room.uvod == 0 then
                    adddel(random(20) + 10)
                    switch(random(2)){
                        [0] = function()
                            addm(0, "bl-m-zvlastni0")
                        end,
                        [1] = function()
                            addv(0, "bl-v-zvlastni1")
                        end,
                    }
                    if pokus == roompole[0] then
                        addm(10, "bl-m-funkce")
                        addv(3, "bl-v-pozadi")
                    end
                    room.uvod = 1
                elseif room.osundavani == 0 and muchoblud.dir ~= dir_no and random(100) < 8 then
                    room.osundavani = 1
                    if pokus == 1 then
                        pom1 = 3
                    else
                        pom1 = random(4)
                    end
                    adddel(20)
                    if pom1 >= 1 then
                        switch(random(2)){
                            [0] = function()
                                addm(0, "bl-m-koral0")
                            end,
                            [1] = function()
                                addv(0, "bl-v-koral1")
                            end,
                        }
                    end
                    if pom1 >= 2 then
                        addm(random(10) + 3, "bl-m-visi")
                    end
                    if pom1 >= 3 then
                        addv(random(10) + 3, "bl-v-nevim"..random(2))
                    end
                elseif room.osundavani < 2 and muchoblud.X <= 14 and random(100) < 5 then
                    room.osundavani = 2
                    addv(30, "bl-v-proc")
                    addm(7, "bl-m-zeptej")
                elseif room.otvaru == 0 and muchoblud.X <= 14 and muchoblud.Y <= 6 and random(100) < 1 then
                    room.otvaru = 1
                    addm(random(100), "bl-m-tvar")
                    addv(5, "bl-v-pestovany")
                elseif room.rikanka == 0 and look_at(small, snecek) then
                    room.rikanka = -1
                    adddel(10)
                    planSet(snecek, "zprava", 1)
                    addm(0, "bl-m-snecku0")
                    planSet(snecek, "zprava", 3)
                    addv(0, "bl-v-dost0")
                    adddel(10)
                    planSet(snecek, "zprava", 2)
                    addm(0, "bl-m-snecku1")
                    planSet(snecek, "zprava", 3)
                    addv(0, "bl-v-dost1")
                    adddel(10)
                    planSet(snecek, "zprava", 2)
                    addm(10, "bl-m-snecku2")
                    planSet(snecek, "zprava", 3)
                    addv(0, "bl-v-dost2")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snecek()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        anim = ""
        snecek.zprava = 0

        return function()
            switch(snecek.zprava){
                [1] = function()
                    snecek.zprava = 0
                    setanim(snecek, "d4a1d1a2")
                end,
                [2] = function()
                    snecek.zprava = 0
                    setanim(snecek, "d11a1d1a2")
                end,
                [3] = function()
                    snecek.zprava = 0
                    setanim(snecek, "d3a1d2a0")
                end,
            }
            if anim ~= "" then
                goanim(snecek)
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

