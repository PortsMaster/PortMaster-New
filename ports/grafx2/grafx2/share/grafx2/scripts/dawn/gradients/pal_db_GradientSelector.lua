--PALETTE: Gradient Selector
--(Use arrow-keys, [SPACE] for plain gray)
--by Richard 'DawnBringer' Fhager

--dofile("../libs/dawnbringer_lib.lua")


path = ""

-- Normal Gradients
grads = {}
n = 0
n=n+1; grads[n] = {"pal_db_SetTaupe_256.lua",       "Taupe"}
n=n+1; grads[n] = {"pal_db_SetRust_256.lua",        "Rust"}
n=n+1; grads[n] = {"pal_db_SetLime_256.lua",        "Lime"}
n=n+1; grads[n] = {"pal_db_SetWatermelon_256.lua",  "Watermelon"}
n=n+1; grads[n] = {"pal_db_SetOlive_256.lua",       "Olive"}
n=n+1; grads[n] = {"pal_db_setAzureSky_256.lua",    "Azure Sky"}
n=n+1; grads[n] = {"pal_db_setBlueSky_256.lua",     "Blue Sky"}
n=n+1; grads[n] = {"pal_db_SetDawn_256.lua",        "Dawn"}
n=n+1; grads[n] = {"pal_db_SetDusk_256.lua",        "Dusk"}
n=n+1; grads[n] = {"pal_db_SetBlueSepia_256.lua",   "Blue-Sepia"}

n=n+1; grads[n] = {"pal_db_SetPaleRider_256.lua",   "Pale Rider"}
n=n+1; grads[n] = {"pal_db_SetPurpleBeige_256.lua", "Purple-Beige"}
n=n+1; grads[n] = {"pal_db_SetMauve_256.lua",       "Mauve"}
Q = 0 -- Current Normal Gradient

-- Odd Gradients
grads2 = {}
n = 0
n=n+1; grads2[n] = {"pal_db_SetFire_256.lua",       "Fire (deep)"}
n=n+1; grads2[n] = {"pal_db_SetSteelBlue_256.lua",  "Steel Blue (deep)"}
n=n+1; grads2[n] = {"pal_db_SetLava_256.lua",       "Lava (v.deep)"}
n=n+1; grads2[n] = {"pal_db_SetXray_256.lua",       "Xray (v.deep)"}
n=n+1; grads2[n] = {"pal_db_SetGoldBlue_256.lua",   "Gold-Blue (multi)"}
n=n+1; grads2[n] = {"pal_db_SetPinkGold_256.lua",   "Pink-Gold (multi)"}
n=n+1; grads2[n] = {"pal_db_SetMandel1_256.lua",    "Mandel1 (multi)"}
n=n+1; grads2[n] = {"pal_db_SetMystery_256.lua",    "Mystery (multi)"}
n=n+1; grads2[n] = {"pal_db_SetRainbow_256.lua",    "Rainbow (multi)"}
O = 0 -- Current Odd Gradient

G = 0; --Grayscale not active
current_list,current_offset,First_flag = grads,0,true

statusmessage("Arrow-keys to change pal")

moved, key, mouse_x, mouse_y, mouse_b = 0,0,0,0,0

repeat

 old_key = key;
 old_mouse_x = mouse_x;
 old_mouse_y = mouse_y;
 old_mouse_b = mouse_b;

 update = 0

 moved, key, mouse_x, mouse_y, mouse_b = waitinput(0)
 --print(key)
 --if mouse_b > 0 then update = 1; end

 if (key == 32) then 
  if G == 0 then
   for i=0,255,1 do setcolor(i,i,i,i); end
   updatescreen(); statusmessage("Grayscale")
  end
  if G == 1 then
    dofile(path..current_list[1+current_offset][1])
    updatescreen();statusmessage(current_list[1+current_offset][2].." (#"..(1+current_offset).."/"..#current_list..")")
    First_flag = false
  end
  G = (G+1) % 2
  updatescreen()
 end

 if (key == 273) then O = (O + 1) % #grads2; update = 2; end -- up arrow
 if (key == 274) then O = (O - 1) % #grads2; update = 2; end -- down arrow

 if (key == 276) then Q = (Q - 1) % #grads; update = 1; end -- left arrow
 if (key == 275) then Q = (Q + 1) % #grads; update = 1; end -- right arrow


 if update > 0 then
  if First_flag then Q,O = 0,0; First_flag = false; end -- Display Gradients #1 at first click (and not #2)
  list,offset = grads,Q; 
  if update == 2 then list,offset = grads2,O; end
  current_list,current_offset = list,offset -- For Grayscale swap memory
  dofile(path..list[1+offset][1])
  updatescreen()
  statusmessage(list[1+offset][2].." (#"..(1+offset).."/"..#list..")")
  updatescreen()
  G = 0
 end

until (key == 27)
