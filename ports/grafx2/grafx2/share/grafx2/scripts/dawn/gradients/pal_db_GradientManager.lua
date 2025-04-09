--PALETTE: #Gradient Manager V1.0
--(Set predefined gradients)
--by Richard 'DawnBringer' Fhager

-- Gradient (Presets) Manager (Working version of menu system, maxlen fix)



-- Make an exception for object o
function deselectAll(o)
 if o ~= grads then grads.selected = 0; end
 if o ~= deep  then  deep.selected = 0; end
 if o ~= multi then multi.selected = 0; end
 if o ~= misc  then  misc.selected = 0; end
end
--

--
function menu_Handler(o)

          menu(o,math.floor((math.max(0,o.selected-1))/o.maxlen) * o.maxlen, o.maxlen);
          if o.selected > 0 then 
            deselectAll(o); 
            dofile(o.list[o.selected][1]); 
          end;
end
--

-- Normal Gradients

grads = {
 list = {{"pal_db_SetTaupe_256.lua",       "Taupe",       256}
        ,{"pal_db_SetLime_256.lua",        "Lime",        256}
        ,{"pal_db_SetWatermelon_256.lua",  "Watermelon",  256}
        ,{"pal_db_SetOlive_256.lua",       "Olive",       256}
        ,{"pal_db_setAzureSky_256.lua",    "Azure Sky",   256}
        ,{"pal_db_setBlueSky_256.lua",     "Blue Sky",    256}
        ,{"pal_db_SetDusk_256.lua",        "Dusk",        256}
        ,{"pal_db_SetDawn_256.lua",        "Dawn",        256}
        ,{"pal_db_SetPaleRider_256.lua",   "Pale Rider",  256}
        ,{"pal_db_SetRust_256.lua",        "Rust",        256}
        ,{"pal_db_SetBlueSepia_256.lua",   "Blue-Sepia",  256}
        ,{"pal_db_SetMauve_256.lua",       "Mauve",       256}
        ,{"pal_db_SetPurpleBeige_256.lua", "PurpleBeige", 256} -- Text Length Limit
         }

 ,textlen = 13 -- Make text this long (add spaces)
 ,title = "Set Linear Gradient"
 ,selected = 0
 ,maxlen = 7 -- Limit is 8 (More won't break the system but page-counter (* active selection) can fail)
 ,menu = (function() menu_Handler(grads); end)
}


deep = {
 list = { --                               "--------------------"
          {"pal_db_SetFire_256.lua",       "Fire"          ,256}
         ,{"pal_db_SetSteelBlue_256.lua",  "Steel Blue"    ,256}
         ,{"pal_db_SetLava_256.lua",       "Lava (v.deep)" ,256}
         ,{"pal_db_SetXray_256.lua",       "Xray (v.deep)" ,256}
        }
 ,textlen = 13
 ,title = "Set Deep Gradient"
 ,selected = 0
 ,maxlen = 7
 ,menu = (function() menu_Handler(deep); end)
}


multi = {
 list = {
          {"pal_db_SetGoldBlue_256.lua",   "Gold-Blue", 256}
         ,{"pal_db_SetPinkGold_256.lua",   "Pink-Gold", 256}
         ,{"pal_db_SetMandel1_256.lua",    "Mandel1",   256}
         ,{"pal_db_SetMystery_256.lua",    "Mystery",   256}
        }
 ,textlen = 13
 ,title = "Set Multi Gradient"
 ,selected = 0
 ,maxlen = 7
 ,menu = (function() menu_Handler(multi); end)
}


misc = {
 list = {
         {"pal_db_SetRainbow_256.lua",    "Rainbow", 256}
        }
 ,textlen = 13
 ,title = "Set Misc Gradient"
 ,selected = 0
 ,maxlen = 7
 ,menu = (function() menu_Handler(misc); end)
}


--
-- Create a SelectBox menu from an object
-- ex: o = {list = {{"Text1", func1}, {"Text2", func2}}, selected = 1}
--
function menu(o, ofs, maxlen)
 local n,args,i,len,enum,name
 ofs = ofs or 0  
 maxlen = math.min(8,(maxlen or 7)) -- Capped at 8 for a max total of 10 buttons (8 + back + more)
 len = math.min(#o.list-ofs, maxlen)
 args,i = {},1
 for n = 1+ofs, len+ofs, 1 do
  prefix = ""
  enum = n
  --if n < 10 then enum = " "..n; end
  if (1+ofs < 10 and len+ofs > 9) and n<10 then enum = " "..n; end -- Add a leading space for numbers <10 if 2-digit numbers occur in the list
  if o.selected == n then prefix = "*"; end
  name = o.list[n][2]..string.rep(" ", o.textlen-#o.list[n][2]).."["..o.list[n][3].."]"
  args[i] = prefix..enum.."."..name; i=i+1
  args[i] = (function() o.selected = n; end); i=i+1
 end

 if (#o.list-ofs) > maxlen then
  args[i] = "[More]"; i=i+1
  args[i] = (function() menu(o, maxlen+ofs, maxlen); end); i=i+1
 end

 if ofs > 0 then
  args[i] = "[Back]"; i=i+1
  args[i] = (function() menu(o, ofs-maxlen, maxlen); end); i=i+1
 end

 selectbox(o.title, unpack(args))

end
--

--
function setGrayscale()
 local n
 for n = 0, 255, 1 do
  setcolor(n,n,n,n)
 end
 deselectAll(o)
end
--

--
function resetPalette()
 local n,r,g,b
 for n = 0, 255, 1 do
  r,g,b = getbackupcolor(n)
  setcolor(n,r,g,b)
 end
 deselectAll(o)
end
--

--
function seltext_Handler(o)
 if o.selected > 0 then 
   return ": "..o.list[o.selected][2].." ["..o.list[o.selected][3].."]" -- Name/Text of selected gradient
    else 
     return " ("..#o.list..")"
  end
end
--

--
function main()
  local do_selbox

  do_selbox = true
  while do_selbox do

   selectbox("# Gradient Manager",
    ">LINEAR"..seltext_Handler(grads),  grads.menu,
      ">DEEP"..seltext_Handler(deep),   deep.menu, 
     ">MULTI"..seltext_Handler(multi),  multi.menu,
      ">MISC"..seltext_Handler(misc),   misc.menu, 
    "Set Grayscale [256] >>",  setGrayscale,
    "Reset Palette >>",  resetPalette,  
    "[DONE/QUIT]",function() do_selbox = false; end
   );

  end

end
--

main()