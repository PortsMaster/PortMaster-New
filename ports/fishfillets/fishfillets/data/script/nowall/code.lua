
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky01.ogg")
    local nehraje = true

    -- -------------------------------------------------------------
    local function prog_init_room()
	local i;
	local zbyva = 70+random(70);

        room.misto = 0
	room.uvod = true
	room.ptafaze = -1

        return function()
	  if no_dialog() and isReady(small) and isReady(big) then
	    zbyva = zbyva-1
	  end
	  if zbyva == 0 then
	    room.ptafaze = room.ptafaze+1
	    zbyva = 100+random(100)
	    addm(0, "m-otazka"..room.ptafaze)
	    if room.ptafaze==4 then room.ptafaze=0 end
	    addv(5, "v-odpoved"..room.ptafaze)
	  end

	  if room.uvod then
	    i = random(4)
	    if i ~= 0 then
	      addm(10, "m-zvlastni")
	      addv(2, "v-zadne")
	      if random(3) ~= 0 then
	        addm(4, "m-zeme")
	      end
	    end
	    if i ~= 1 then
	      addm(30, "m-uvedomit")
	      if random(3) ~= 0 then
	        addv(0, "v-nad")
	      end
	      addm(0, "m-predmet")
	      if random(3) ~= 0 then
	        addv(10, "v-krehci")
	      end
	    end
	    room.uvod = false
	  end

	  room.misto = room.misto+1
	  if room.misto == 37 then room.misto = 0 end
	  model_setViewShift(room.index, 0, room.misto)
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

