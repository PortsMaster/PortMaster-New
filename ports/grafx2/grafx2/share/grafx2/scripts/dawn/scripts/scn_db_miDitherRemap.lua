--SCENE: Dithers Remapping
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")


OK,ditherprc,xdith,ydith,ord_bri,ord_hue,bri_change,hue_change,briweight = inputbox("Dither/Remap /w Sparepal",                                        
                           --"1. Use Spare palette",       1,  0,1,-1,                        
                           "FS Dither Power %",        90,  0,200,0,
                           "X Bri-Dither: 0-64",          5,  0,64,0,
                           "Y Bri-Dither: 0-64",         10,  0,64,0,
                           "Ordered Brightness",         0,  0,128,0,
                           "Ordered Hue (wip)",          0,  0,128,0,
                           "Change Brightness",          0,  -128,128,0,
                           "Change Hue: -180°..180°",    0,  -180,180,0,
                           --"Perceptual ColorMatch",     1,  0,1,0,
                           "ColMatch Bri-Weight %", 25,  0,100,0                            
);


sparepal = 1

function f(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m
  m = math
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  r,g,b = getbackupcolor(getbackuppixel(x,y))

  --
  return cap(r),cap(g),cap(b)
end



function cap(v)
 return math.min(255,math.max(0,v))
end



if OK == true then
 
 if sparepal == 1 then 
  --pal = db.fixPalette(db.makeSparePalList(256)); percep = 1; 
  for n=0, 255, 1 do
   setcolor(n,getsparecolor(n))
  end
 end

 pal = {}

 
 percep = 1 -- HybridColorMatch active 
 if percep == 1 then pal = db.fixPalette(db.makePalList(256)); end
 --percep = null

 t1 = os.clock()

 db.fsrender(f,pal,ditherprc,xdith,ydith,percep,-1,ord_bri,ord_hue,bri_change,hue_change,briweight)

--messagebox("Seconds: "..(os.clock() - t1))

end -- ok