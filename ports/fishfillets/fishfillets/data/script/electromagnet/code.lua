alienmagnet.animationstate = 0
alienmagnet.doesanimation = 0
alienmagnet.waytobuzz = 0
damage_wall.damagestate = 0

local bore = -5

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky06.ogg")
    local num_starts = getRestartCount()
    room.was_intro = false


    -- -------------------------------------------------------------
    local function prog_init_room()
        return function()
            if num_starts < 3 and not room.was_intro then
                room.was_intro = true
                addv(20, "init-0")
                addm(16, "init-1")
                addv(16, "init-2")
                addm(16, "init-3-"..random(4))
                addv(16, "init-4")
                end
            if no_dialog() and random(200) < 4 and isReady(small) and isReady(big) then
                bore = bore + 1
                if bore > 10 then
                    bore=0
                    switch(random(7)){
                        [0] = function()
                            if lever.X >= 10 then
                                addm(0, "rand-0-0")
                                addv(16, "rand-0-1")
                                addm(16, "rand-0-2")
                                addv(16, "rand-0-3")
                                addm(16, "rand-0-4")
                                addv(16, "rand-0-5")
                                end
                            end,
                        [1] = function()
                            addm(0, "rand-1-0")
                            addv(16, "rand-1-1")
                            addm(16, "rand-1-2")
                            addv(16, "rand-1-3")
                            end,
                        [2] = function()
                            addm(0, "rand-2-0")
                            addv(16, "rand-2-1")
                            addm(16, "rand-2-2")
                            addv(16, "rand-2-3-"..random(3))
                            addm(16, "rand-2-4")
                            end,
                        [3] = function()
                            addv(0, "rand-3-0")
                            addm(16, "rand-3-1")
                            addv(16, "rand-3-2-"..random(6))
                            addm(16, "rand-3-3")
                            end,
                        [4] = function()
                            addv(0, "rand-4-0")
                            addm(16, "rand-4-1")
                            addv(16, "rand-4-2")
                            end,
                        [5] = function()
                            addv(0, "rand-5-0")
                            addm(16, "rand-5-1")
                            addv(16, "rand-5-2")
                            addm(16, "rand-5-3-"..random(2))
                            end,
                        [6] = function()
                            addm(0, "rand-6-0")
                            addv(16, "rand-6-1")
                            addm(16, "rand-6-2")
                            addv(16, "rand-6-3")
                            addm(16, "rand-6-4")
                            addv(16, "rand-6-5")
                            end,
                        }
                    end
                end

            local count = game_getCycles()
            plutonium.afaze=math.mod(count, 12)/3
            plutonium:updateAnim()
            -- very specific because text wouldn't fit otherwise
            if damage_wall.damagestate == 0 and killozap.Y == 2 and killozap.X == 3 and killozap.dir == dir_left and big.X < 9 and big.Y == 3 then
                killozap:talk("laser", VOLUME_FULL)
                damage_wall.damagestate = 1
                addm(8, "shoot-0-"..random(4))
                addv(12,"shoot-1")
                addm(12,"shoot-2-"..random(2))
                addv(12,"shoot-3-"..random(2))
                addm(12,"shoot-4")
                addv(12,"shoot-5")
                addm(12,"shoot-6")
                end
            if damage_wall.damagestate < 9 and damage_wall.damagestate > 0 then
                damage_wall.afaze=damage_wall.damagestate
                damage_wall:updateAnim()
                damage_wall.damagestate = damage_wall.damagestate + 1
                end
            if damage_wall.damagestate == 9 then
                damage_wall.afaze=8
                damage_wall:updateAnim()
                end
            if lever.dir == dir_left then
                if lever.afaze < 5 then
                    lever.afaze = 4
                    end
                lever.afaze = lever.afaze + 1
                lever:updateAnim()
                else
                local addy = 0
                if lever.afaze > 5 then
                    addy = 7
                    end
                lever.afaze = random(5) + addy
                lever:updateAnim()
                end
            if alienmagnet.doesanimation == 0 then
                if random(50) > 47 then
                    alienmagnet.waytobuzz=alienmagnet.waytobuzz+1
                    end
                if alienmagnet.waytobuzz > 12 then
                    alienmagnet.doesanimation = 1 + random(2)
                    alienmagnet.animationstate= 0
                    alienmagnet.waytobuzz = random(3)
                    alienmagnet.runtime = 20 + random(20) + random(20)
                    end
            else
                if alienmagnet.doesanimation == 1 then
                    switch(alienmagnet.animationstate){
                    [0] = function()
                          if alienmagnet.runtime <= 1 then
                              alienmagnet.animationstate = 8
                              else
                              if alienmagnet.Y == small.Y and alienmagnet.X < small.X and alienmagnet.X + 6 > small.X then
                                  addm(0,'s-hurt-'..random(3))
                                  end
                              if (alienmagnet.Y == big.Y or alienmagnet.Y == big.Y+1) and alienmagnet.X < big.X and alienmagnet.X + 6 > big.X then
                                  addv(0,'b-hurt-'..random(3))
                                  end
                              end
                          alienmagnet.afaze = 1
                          end,
                    [1] = function()
                          if alienmagnet.runtime <= 1 then
                              alienmagnet.animationstate = -1
                              end
                          alienmagnet.afaze = 2
                          end,
                    [2] = function()
                          if alienmagnet.runtime <= 1 then
                              alienmagnet.animationstate = 0
                              end
                          alienmagnet.afaze = 3
                          end,
                    [3] = function()
                          if alienmagnet.runtime <= 1 then
                              alienmagnet.animationstate = 1
                              end
                          alienmagnet.afaze = 4
                          end,
                    [4] = function()
                          if alienmagnet.runtime > 1 then
                              alienmagnet.animationstate = 3 + random(4)
                              if alienmagnet.animationstate >= 3 then
                                  alienmagnet.animationstate = alienmagnet.animationstate + 1
                                  end
                              else
                              alienmagnet.animationstate = 2
                              end
                          alienmagnet.afaze = 5
                          end,
                    [5] = function()
                          if alienmagnet.runtime > 1 then
                              alienmagnet.animationstate = 3 + random(4)
                              if alienmagnet.animationstate >= 4 then
                                  alienmagnet.animationstate = alienmagnet.animationstate + 1
                                  end
                              else
                              alienmagnet.animationstate = 2
                              end
                          alienmagnet.afaze = 6
                          end,
                    [6] = function()
                          if alienmagnet.runtime > 1 then
                              alienmagnet.animationstate = 3 + random(4)
                              if alienmagnet.animationstate >= 5 then
                                  alienmagnet.animationstate = alienmagnet.animationstate + 1
                                  end
                              else
                              alienmagnet.animationstate = 2
                              end
                          alienmagnet.afaze = 7
                          end,
                    [7] = function()
                          if alienmagnet.runtime > 1 then
                              alienmagnet.animationstate = 3 + random(4)
                              if alienmagnet.animationstate >= 6 then
                                  alienmagnet.animationstate = alienmagnet.animationstate + 1
                                  end
                              else
                              alienmagnet.animationstate = 2
                              end
                          alienmagnet.afaze = 8
                          end,
                    [8] = function()
                          if alienmagnet.runtime > 1 then
                              alienmagnet.animationstate = 3 + random(4)
                              else
                              alienmagnet.animationstate = 2
                              end
                          alienmagnet.afaze = 9
                          end,
                    [9] = function()
                          alienmagnet.doesanimation = 0
                          alienmagnet.afaze = 0
                          end,
                    }
                    else
                    switch(alienmagnet.animationstate){
                    [0] = function()
                          if alienmagnet.runtime <= 1 then
                              alienmagnet.animationstate = 4
                              end
                          alienmagnet.afaze = 13
                          end,
                    [1] = function()
                          if alienmagnet.runtime <= 1 then
                              alienmagnet.animationstate = -1
                              end
                          alienmagnet.afaze = 14
                          end,
                    [2] = function()
                          if alienmagnet.runtime > 1 then
                              alienmagnet.animationstate = 1 + random(2)
                              if alienmagnet.animationstate >= 1 then
                                  alienmagnet.animationstate = alienmagnet.animationstate + 1
                                  end
                              else
                              alienmagnet.animationstate = 0
                              end
                          alienmagnet.afaze = 10
                          end,
                    [3] = function()
                          if alienmagnet.runtime > 1 then
                              alienmagnet.animationstate = 1 + random(2)
                              if alienmagnet.animationstate >= 2 then
                                  alienmagnet.animationstate = alienmagnet.animationstate + 1
                                  end
                              else
                              alienmagnet.animationstate = 0
                              end
                          alienmagnet.afaze = 11
                          end,
                    [4] = function()
                          if alienmagnet.runtime > 1 then
                              alienmagnet.animationstate = 1 + random(2)
                              else
                              alienmagnet.animationstate = 0
                              end
                          alienmagnet.afaze = 12
                          end,
                    [5] = function()
                          alienmagnet.doesanimation = 0
                          alienmagnet.afaze=0
                          end,
                    }
                end
            alienmagnet.animationstate = alienmagnet.animationstate + 1
            alienmagnet.runtime = alienmagnet.runtime - 1
            alienmagnet:updateAnim()
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

