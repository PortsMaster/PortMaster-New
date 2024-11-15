
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky09.ogg")
    local pokus = getRestartCount()

    -- -------------------------------------------------------------
    local function prog_init_room()
        local nehraje = true

	room.hraje = false
	room.uvod = 0
	room.cekuvod = 20
	room.konec = true
	room.rekurzivni = true
	room.tahu = 0
	room.tesi = true
	room.vyhecoval = true
	room.nepomahas = true

        return function()
	  if isReady(big) and isReady(small) and room.hraje and
	     (big.dir ~= dir_no or small.dir ~= dir_no) and
	     room.uvod~=8 then
	    room.tahu  = room.tahu+1
	    if room.tahu == 2400 then
	      addv(0, "v-bavit")
	      switch(random(3)){
	        [0] = function()
		  room.tesi = false
		  addm(5, "m-tesise")
		  addv(0, "v-budou")
		end,
	        [1] = function()
		  room.vyhecoval = false
		  addm(5, "m-vyhecoval")
		  planBusy(big, true)
		  addv(0, "v-looser")
		  planBusy(big, false)
		end,
	        [2] = function()
		  room.nepomahas = false
		  addm(0, "m-nepomahas")
		end,
	      }
	    end
	    if room.tahu == 3600 then
	      addv(0, "v-bavit")
	      if random(2) == 0 then
	        if room.tesi then
		  room.tesi = false
		  addm(5, "m-tesise")
		  addv(0, "v-budou")
		else
		  room.vyhecoval = false
		  addm(5, "m-vyhecoval")
		  planBusy(big, true)
		  addv(0, "v-looser")
		  planBusy(big, false)
		end
	      else
	        if room.nepomahas then
		  room.nepomahas = false
		  addm(5, "m-nepomahas")
		else
		  room.vyhecoval = false
		  addm(5, "m-vyhecoval")
		  planBusy(big, true)
		  addv(0, "v-looser")
		  planBusy(big, false)
		end
	      end
	    end
	    if room.tahu == 4800 then
	      addv(0, "v-bavit")
	      if room.tesi then
		room.tesi = false
		addm(5, "m-tesise")
		addv(0, "v-budou")
	      elseif room.vyhecoval then
		room.vyhecoval = false
		addm(5, "m-vyhecoval")
		planBusy(big, true)
		addv(0, "v-looser")
		planBusy(big, false)
	      else
		room.nepomahas = false
		addm(5, "m-nepomahas")
	      end
	    end
	    if room.tahu == 6000 then
	      addv(0, "v-bavit")
	      addm(5, "m-trikrat")
	      addv(2, "v-jineho")      
	      addm(2, "m-vicedat")
	      addv(2, "v-plny")
	    end
	  end
          if zluta.dir ~= dir_no then
	    room.hraje = true
	  end
          if nehraje and room.hraje and no_dialog() then
	    sound_playMusic("music/rybky10.ogg")
	    nehraje = false
	    if room.uvod < 7 then 
	      if random(2) == 0 and isReady(big) and isReady(small) then
	        addv(20, "v-kopie")
	        addm(3, "m-inspiroval")
		room.uvod = 9
	      else room.uvod = 7 end
	    end
	  end

	  if big:isOut() and ocel.X == 51 and isReady(small)
	     and room.konec then
	    room.konec = false
	    addm(5, "m-predstavujes")
	    addm(0, "m-restartuj")
	  end

	  if small:isOut() and ocel.Y == 4 and isReady(big)
	     and room.konec then
	    room.konec = false
	    addv(5, "v-nenifer")
	    addv(0, "v-restartovat")
	  end

	  if big:isOut() and room.konec and ocel.Y == 4 and isReady(small) then
	    room.konec = false
	    planBusy(small, true)
	    addm(0, "m-citovat")
	    planBusy(small, false)
	  end

	  if zluta.Y == 3 and zelena.Y == 5 and cyanova.Y == 7 and
	     modra.Y == 9 and fialova.Y == 11 and
	     zluta.X > 38 and zelena.X > 38 and cyanova.X > 38 and
	     modra.X > 38 and fialova.X > 38 and room.konec then
	    room.konec = false
	    addv(0, "v-pochvalil")
	  end	    

	  if nehraje and room.uvod < 6 and no_dialog() and isReady(small)
	     and isReady(big) then
	    if room.cekuvod == 0 then
	      switch(room.uvod){
	        [0] = function()
		  room.cekuvod = 5
		  addv(0, "v-tady")
		end,
	        [1] = function()
		  room.cekuvod = 0
		  addm(0, "m-co")
		end,
	        [2] = function()
		  room.cekuvod = 5
		  addv(0, "v-jacity")
		end,
	        [3] = function()
		  room.cekuvod = 0
		  addm(0, "m-bude")
		end,
	        [4] = function()
		  addv(0, "v-mamja")
		end,
	        [5] = function()
		  addv(0, "v-alehrac")
		end,
	      }
	      room.uvod = room.uvod+1
	    else
	      room.cekuvod = room.cekuvod-1
	    end
	  end
	  if isReady(small) and isReady(big) and
	     ((zluta.X == zelena.X    and zluta.Y == zelena.Y+1) or
	      (zluta.X == cyanova.X   and zluta.Y == cyanova.Y+1) or
	      (zluta.X == modra.X     and zluta.Y == modra.Y+1) or
	      (zluta.X == fialova.X   and zluta.Y == fialova.Y+1 and
	       ((small.X ~= zluta.X+2 and small.X ~= zluta.X+8) or
	         small.Y ~= zluta.X)) or
	      (zelena.X == cyanova.X  and zelena.Y == cyanova.Y+1) or
	      (zelena.X == modra.X    and zelena.Y == modra.Y+1) or
	      (zelena.X == fialova.X  and zelena.Y == fialova.Y+1) or
	      (cyanova.X == modra.X   and cyanova.Y == modra.Y+1) or
	      (cyanova.X == fialova.X and cyanova.Y == fialova.Y+1) or
	      (modra.X == fialova.X   and modra.Y == fialova.Y+1)) then
	    if room.uvod == 7 then
	      addv(20, "v-orechove")
	      addm(5, "m-hazet")
	    end
	    room.uvod = 8
	  end
	  if fialova.X > 38 and fialova.Y == 11 and isReady(small)
	     and room.rekurzivni and room.uvod ~= 8 then
	    addm(5, "m-rekurzivni")
	    room.rekurzivni = false
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

