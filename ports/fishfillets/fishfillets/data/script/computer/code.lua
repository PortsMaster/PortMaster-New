
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky14.ogg")
    local pokus = getRestartCount()
    local roompole = createArray(1)

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.opocitaci1 = random(300) + 100
        room.opocitaci2 = random(2000) + 1500
        room.onachazeni = 0
        room.okramu = 0
        room.ovyvrtce = 1

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.opocitaci1 > 0 then
                    room.opocitaci1 = room.opocitaci1 - 1
                end
                if room.opocitaci2 > 0 then
                    room.opocitaci2 = room.opocitaci2 - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    if random(100) < math.floor(200 / pokus) then
                        addm(random(10) + 5, "poc-m-lezt"..random(3))
                        addv(random(10), "poc-v-kam"..random(4))
                    end
                elseif room.onachazeni == 0 and dist(big, monitoor) <= 1 and look_at(big, monitoor) and random(100) < 7 then
                    room.onachazeni = 1
                    if random(100) < 60 then
                        addv(5, "poc-v-nenajde")
                    end
                elseif room.opocitaci1 == 0 or room.opocitaci2 == 0 then
                    if room.opocitaci1 == 0 then
                        room.opocitaci1 = random(5000) + 5000
                    else
                        room.opocitaci2 = random(5000) + 5000
                    end
                    if roompole[0] == 0 then
                        roompole[0] = random(2) + 1
                    else
                        roompole[0] = 3 - roompole[0]
                    end
                    switch(roompole[0]){
                        [1] = function()
                            addm(30, "poc-m-myslis")
                            addv(4, "poc-v-multimed")
                            addv(random(20) + 5, "poc-v-vyresil")
                            addm(random(10) + 5, "poc-m-kcemu")
                            addv(0, "poc-v-pssst")
                        end,
                        [2] = function()
                            addv(30, "poc-v-napad")
                            addm(5 + random(20), "poc-m-mohlby")
                            addv(2, "poc-v-stahni")
                            addm(random(10) + 4, "poc-m-ukryta")
                            switch(random(3)){
                                [0] = function()
                                    addv(random(200) + 20, "poc-v-dira")
                                    addm(5, "poc-m-mechanika")
                                    addm(random(30) + 5, "poc-m-zezadu")
                                end,
                                [1] = function()
                                    addm(random(60) + 20, "poc-m-zezadu")
                                end,
                                [2] = function()
                                    addm(random(30) + 5, "poc-m-zezadu")
                                    addv(random(50) + 20, "poc-v-dira")
                                    addm(5, "poc-m-mechanika")
                                end,
                            }
                            room.ovyvrtce = 0
                        end,
                    }
                elseif room.ovyvrtce == 0 and big.Y == vrtidlo.Y + 2 and dist(big, vrtidlo) == 0 and dist(small, vrtidlo) > 2 and random(100) < 2 then
                    room.ovyvrtce = 1
                    addm(4, "poc-m-vyvrtka")
                elseif room.okramu == 0 and (monitoor.dir == dir_up or pociitac.dir == dir_up) and random(100) < 8 then
                    room.okramu = 1
                    addm(10, "poc-m-kram")
                    addv(5, "poc-v-mono")
                end
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

