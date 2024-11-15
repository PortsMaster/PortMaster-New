
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/kufrik.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        konik.afaze = -random(100)
	local semafodp = 0;
	local nakresleni = random(300)+500
	local otocka = random(200)+300
	local mrka = random(4)+8
	local proc = 0
	local funkcni = true

 	local zacatek=random(2)
	local zelena=false;

        return function()

	  if o.dir ~= dir_no then
	    if proc < 0 then proc=0
	    else proc = proc+1 end
	  end
	  if proc==15 then proc=proc+1  addm(5, "proc-m") end

	  if koral.dir ~= dir_no then
	    if proc > 0 then proc=0
	    else proc = proc-1 end
	  end
	  if proc==-15 then proc=proc-1 addv(5, "proc-v") end

	  if otocka == 0 then
	    if no_dialog() or vrsek.afaze~=0 then
	      if vrsek.afaze==23 then
	        vrsek.afaze=0
		vrsek:updateAnim()
		spodek.afaze=0
		spodek:updateAnim()
	        dole.afaze=0
		dole:updateAnim()
	        nahore.afaze=0
		nahore:updateAnim()
		f.afaze=0
		f:updateAnim()
		o.afaze=0
		o:updateAnim()
		otocka = random(200)+300
	      else
	        if vrsek.afaze==0 then
		  if random(2)==1 then
		    vrsek:planDialog(0, "nevi-b")
		  else
		    vrsek:planDialog(0, "nejlepsi-b")
		  end
		end
	        vrsek.afaze=vrsek.afaze+1
		vrsek:updateAnim()
		spodek.afaze=spodek.afaze+1
		spodek:updateAnim()
	        dole.afaze=dole.afaze+1
		dole:updateAnim()
	        nahore.afaze=nahore.afaze+1
		nahore:updateAnim()
		f.afaze=f.afaze+1
		f:updateAnim()
		o.afaze=o.afaze+1
		o:updateAnim()
	      end
	    else
	      otocka = otocka+20;
	    end
	  else
	    otocka = otocka-1
	  end

	  nakresleni=nakresleni-1
	  if nakresleni==0 and isReady(small) and isReady(big) then
	    if no_dialog() and zelena==false then
 	      addv(0, "hybeme-v")
	      addm(0, "agenti-m")
	      addv(0, "podvodou-v")
	      addm(10, "mene-m")
	      addv(0, "kecas-v")
	      addm(0, "cely-m")
	    else
	      nakresleni=50
	    end
	  end

	  if zacatek==0 and no_dialog() then
	     addv(0, "vidis-v")
	     addm(0, "budova-m")
	     addv(0, "rozkladaci-v")  
	     addm(0, "drzel-m")
	     zacatek=2
	  end

	  if obrryb.afaze == 11 then
	    obrryb.afaze = -1 end
	  obrryb.afaze = obrryb.afaze+1
	  obrryb:updateAnim()

	  if konik.afaze == 3 then
	    if mrka == 0 and isReady(small) and isReady(big) then
	      if no_dialog() and zelena==false then
	        addm(10, "mrka-m")
		addv(0, "nemrka-v")
		mrka=random(4)+1;
		addm(0, "ted"..mrka.."-m")
		addv(0, "nebyl-v")

		konik.afaze = 0
	        konik:updateAnim()
	        switch(mrka){
	           [1] = function()
		     konik.afaze=-85
		   end,
	           [2] = function()
		     konik.afaze=-80
		   end,
	           [3] = function()
		     konik.afaze=-80
		   end,
	           [4] = function()
		     konik.afaze=-90
		   end,
		}
		mrka=-1
	      else
	        mrka=1
	        konik.afaze = 0
		konik:updateAnim()
		konik.afaze = -random(100)
		mrka = mrka-1
	      end
	    else
	      konik.afaze = 0
	      konik:updateAnim()
	      konik.afaze = -random(100)
	      mrka = mrka-1
	    end
	  end
	  if konik.afaze >= 0 then
	    konik:updateAnim()
          end
	  konik.afaze = konik.afaze+1

	  if isReady(small)==false and funkcni and isReady(big) then
	    funkcni=false
	    addv(5, "rozbil-v")
	  end

	  if funkcni then
	    if small.Y > semafor.Y+1 then
	      semafor.afaze=2
	      if zelena and no_dialog() and isReady(big) then
	        addv(5, "zelena-v")
		zelena = false
	      end
	    elseif small.Y ==semafor.Y+1 then
	      semafor.afaze=1
	    elseif small.Y < semafor.Y+1 then
	      semafor.afaze=0 
	      if zacatek == 1 and no_dialog and isReady(big) then
	        addv(0, "semafor-v")
		addm(0, "nacekala-m")
		zelena=true
		zacatek=2
	      end
	    end
	  else
	    if semafodp == 0 then
	      semafor.afaze=1
	      semafodp = 5
	    else
	      semafodp = semafodp-1;
	      semafor.afaze=3
	    end
	  end
	  semafor:updateAnim()
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

