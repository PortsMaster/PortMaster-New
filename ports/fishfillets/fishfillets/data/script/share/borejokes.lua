
-- -----------------------------------------------------------------
local usedJokes = {}
local usedJokesCapacity = 3
local peek = -1
local function wasUsedRecently(n)
    return isIn(n, usedJokes)
end
local function rememberUsed(n)
    peek = math.mod(peek + 1, usedJokesCapacity)
    usedJokes[peek] = n
end

local boredDialogTable = {}

function insertBoreJoke(joke)
    table.insert(boredDialogTable, joke)
    if usedJokesCapacity * 3 < table.getn(boredDialogTable) then
        usedJokesCapacity = usedJokesCapacity + 1
    end
end

insertBoreJoke(
        function()
            if level_getDepth() ~= 15 then
                if random(100) < 30 then
                    addm(20, "ob-m-neverim")
                end
                if random(100) < 30 then
                    addm(20, "ob-m-nedosataneme")
                end
                if random(100) < 30 then
                    addm(20, "ob-m-naveky")
                end
                switch(random(4)){
                    [0] = function()
                        addv(random(15) + 5, "ob-v-jit0")
                    end,
                    [1] = function()
                        addv(random(15) + 5, "ob-v-jit1")
                    end,
                    [2] = function()
                        addv(random(15) + 5, "ob-v-musi")
                    end,
                    [3] = function()
                        addv(random(15) + 5, "ob-v-klid")
                    end,
                }
            end
        end
)

insertBoreJoke(
        function()
            switch(random(3)){
                [0] = function()
                    addv(20, "ob-v-neobvykle")
                    addm(randint(5, 10), "ob-m-teorie")
                end,
                [1] = function()
                    addv(20, "ob-v-mamto")
                    addm(randint(10, 20), "ob-m-pokracuj")
                    addv(5, "ob-v-napad")
                    if random(100) < 40 then
                        addm(6, "ob-m-zase")
                    end
                end,
                [2] = function()
                    addv(20, "ob-v-vyzkousej")
                    addm(0, "ob-m-co")
                    addv(randint(5, 15), "ob-v-alenic")
                    if random(100) < 40 then
                        addm(6, "ob-m-zase")
                    end
                end,
            }
        end
)

insertBoreJoke(
        function()
            switch(random(3)){
                [0] = function()
                    addv(10, "ob-v-nebavi")
                end,
                [1] = function()
                    addv(10, "ob-v-hrej")
                end,
                [2] = function()
                    addv(10, "ob-v-sami")
                end,
            }
            switch(random(3)){
                [0] = function()
                    addm(5, "ob-m-pst")
                end,
                [1] = function()
                    addm(5, "ob-m-hlavu")
                end,
                [2] = function()
                    addm(5, "ob-m-klid")
                end,
            }
        end
)

insertBoreJoke(
        function()
            switch(random(4)){
                [0] = function()
                    addm(10, "ob-m-jesteneco")
                end,
                [1] = function()
                    addm(10, "ob-m-nedeje")
                end,
                [2] = function()
                    addm(10, "ob-m-proc")
                end,
                [3] = function()
                    addm(10, "ob-m-ceka")
                end,
            }
            switch(random(3)){
                [0] = function()
                    addv(5, "ob-v-nerus")
                end,
                [1] = function()
                    addv(5, "ob-v-nerus")
                end,
                [2] = function()
                    addm(15, "ob-m-jetam")
                    planBusy(big, true)
                    addv(randint(5, 25), "ob-v-leskne")
                    planBusy(big, false)
                end,
            }
        end
)

insertBoreJoke(
        function()
            switch(random(5)){
                [0] = function()
                    addv(10, "ob-v-prestavka")
                end,
                [1] = function()
                    planDialog(TALK_INDEX_BOTH, 10, "ob-o-nebavi")
                end,
                [2] = function()
                    planBusy(big, true)
                    planBusy(small, true)
                    planDialog(TALK_INDEX_BOTH, 10, "ob-o-halo")
                    addv(10, "ob-v-nelekl")
                    addm(6, "ob-m-mysleli")
                    planBusy(big, false)
                    planBusy(small, false)
                end,
                [3] = function()
                    planBusy(big, true)
                    addv(10, "ob-v-nehybes")
                    planBusy(big, false)
                    addm(10, "ob-m-resit")
                    addv(5, "ob-v-akvarium")
                end,
                [4] = function()
                    --TODO: shake room
                    -- addset(Room.TrepatRoom, 1)
                    addv(5, "ob-v-halo")
                    adddel(5)
                    -- addset(Room.TrepatRoom, 0)
                end,
            }
        end
)

insertBoreJoke(
        function()
            switch(random(6)){
                [0] = function()
                    planBusy(small, true)
                    addm(5, "ob-m-tezky")
                    planBusy(small, false)
                end,
                [1] = function()
                    planBusy(big, true)
                    addv(5, "ob-v-jidlo")
                    planBusy(big, false)
                end,
                [2] = function()
                    planBusy(small, true)
                    addm(5, "ob-m-strach")
                    planBusy(small, false)
                end,
                [3] = function()
                    addm(10, "ob-m-jakdlouho")
                    addv(5, "ob-v-zvykacka")
                    room.zvykacka = true
                end,
                [4] = function()
                    addv(5, "ob-v-ostani")
                    addm(5, "ob-m-kdo")
                    addv(5, "ob-v-kdoresi")
                    addm(10, "ob-m-pravdepodobne")
                end,
                [5] = function()
                    addm(10, "ob-m-ach")
                    addv(5, "ob-v-copak")
                    addm(15, "ob-m-lito")
                    addv(5, "ob-v-colito")
                    addm(5, "ob-m-vsechno")
                    addv(5, "ob-v-covsechno")
                    addm(1, "ob-m-uplnevse")
                end,
            }
        end
)

-- -----------------------------------------------------------------
-- NOTE: uses 'small' and 'big' names for fishes
local function selectJoke(n)
    if not isReady(small) or not isReady(big) then
        return
    end

    boredDialogTable[n+1]()
end

-- -----------------------------------------------------------------
-- TODO: remember delayForJoke after restart
local lastDialog = 0
local delayForJoke = random(600) + 600
local boredRate = 0
local function boredUnits()
    for index, unit in pairs(getUnitTable()) do
        if not (unit:getAction() == "rest") then
            boredRate = 0
            return false
        end
    end
    boredRate = boredRate + 1
    return boredRate > delayForJoke
end

function stdBoreJokeLoad()
    lastDialog = game_getCycles()
    dialogLoad("script/share/bore_", "sound/share/borejokes/")
end

function stdBoreJoke()
    if boredUnits() and no_dialog() then
        boredRate = 0
        delayForJoke = delayForJoke * randint(100, 150) / 100
        n = random(table.getn(boredDialogTable))
        while wasUsedRecently(n) do
            n = random(table.getn(boredDialogTable))
        end
        rememberUsed(n)
        selectJoke(n)
    end
end

