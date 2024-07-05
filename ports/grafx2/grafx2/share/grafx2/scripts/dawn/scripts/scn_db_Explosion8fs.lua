--SCENE: Explosion (Particles) V0.6wip
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")


function main()

 local Img,fget,fput,fcontrol,frend,cap,x,y,w,h,r,g,b,pal,Divisions,Rlevels,Rsum,Count,radf
 local floor,rnd

 --math.randomseed(1)

 floor = math.floor
 rnd = math.random

 -- 4/4 or 4/5 is good
 Divisions = 4
 Rlevels   = 4

 Rsum  = db.recursiveSum(Divisions,Rlevels)
 Count = 0

 -- Recursive control function
 function fcontrol(type,mode,wd,ht,sx,sy,xrad,yrad,rgba1,rgba2, update_flag, f_get, f_put, f_recur, recur_count)
  local n,rx,ry,nxrad,nyrad,sp,v,t,divisions,rlevels

   Count = Count + 1
   --statusmessage("Recursion: "..Count.." / "..Rsum)
   db.particle(type,mode,wd,ht,sx,sy,xrad,yrad,rgba1,rgba2, update_flag, f_get, f_put) 

   
   recur_count = recur_count + 1

   if recur_count <= Rlevels then

    sp = 1.2   -- Scatterness (1st ex = 1.2)
    radf = 0.65 -- Radius reduction multiple per Iteration (1st ex = 0.6)
 
    nxrad = xrad * radf
    nyrad = yrad * radf
    v = 90   -- Brightness reduction per iteration (1st ex = 90)
    t = 0.6 -- Iteration transparency/alpha multiple, higher = more solid particles (1st ex = 0.7)
    rgba1 = {rgba1[1]-v,rgba1[2]-v,rgba1[3]-v,rgba1[4]*t}
    rgba2 = {rgba2[1]-v,rgba2[2]-v,rgba2[3]-v,rgba2[4]*t}


    for n = 1, Divisions, 1 do
     rx = rnd(-xrad*sp,xrad*sp)
     ry = rnd(-yrad*sp,yrad*sp)
     --updatescreen(); if (waitbreak(0)==1) then return; end;
     fcontrol(type,mode,wd,ht,sx+rx,sy+ry,nxrad,nyrad,rgba1,rgba2, update_flag, f_get, f_put, f_recur, recur_count)
    end

      statusmessage("Recursion: "..Count.." / "..Rsum)
      updatescreen(); if (waitbreak(0)==1) then return; end;
   end

 end -- Control


 w,h = getpicturesize()

 Img = {}
 for y = 0, h-1, 1 do 
  Img[y+1] = {}; for x = 0, w-1, 1 do r,g,b = getcolor(getpicturepixel(x,y)); Img[y+1][x+1] = {r,g,b}
 end; end

 function fget(x,y) return Img[floor(y)+1][floor(x)+1]; end
 function fput(x,y,r,g,b) Img[floor(y)+1][floor(x)+1] = {r,g,b}; end -- rgb array won't work as it's just a reference

 --
 -- db.particle(type,mode,wd,ht,sx,sy,xrad,yrad,rgba1,rgba2, update_flag, f_get, f_put)
 --
 -- type: "sphere" - volmetric planet-like disc
 --       "disc"   - plain disc
 -- mode: "blend"  - mix graphics with background color
 --       "add"    - add graphics to background color
 -- wd,ht:         - Max Width/Height of drawing area, i.e. screen size (needed if drawing to an array-buffer)
 -- sx,sy:         - drawing coordinates (center)
 -- xrad,yrad:     - x & y radii
 -- rgba1:         - rgb+alpha array of center color: {r,g,b,a}, alpha is 0..1 where 1 is no transparency, Extreme rgb-values allowed
 -- rgba2:         - rgb+alpha array of edge color: {r,g,b,a}, alpha is 0..1 where 1 is no transparency, Extreme rgb-values allowed
 -- update_flag:	  - Display rendering option (and add break feature)
 -- f_get:	  - Get pixel function: use getpicturepixel if reading from image (set null for image default)
 -- f_put:	  - Put pixel function: use putpicturepixel if drawing to image (set null for image default)
 -- f_recur:       - Optional custom control-function for recursion (set null if not used)
 -- recur_count    - Recursion depth counter, for use in combination with a custom function (f_recur), 0 as default
 --
 fcontrol("sphere","add", w,h, w/2,h/2, 60,60, {375,350,290, 0.85},{224-400,32-400,-64-400, -0.5}, false, fget, fput, fcontrol, 0)
 --fcontrol("sphere","add", w,h, w/2,h/2, 40,40, {500,400,255, 0.8},{0,-150,-175, 0.0}, false, fget, fput, fcontrol, 0)
 --

 -- RENDER

 function cap(v) return math.min(255,math.max(0,v)); end

 -- Expand array to work with render-engine fs dither
 Img[h+1], Img[h+2] = db.newArrayInit(w,{0,0,0}), db.newArrayInit(w,{0,0,0}) 

 function frend(x,y,w,h) -- Render Engine function
  local rgb
  --w,h = getpicturesize()
  --x = math.max(0,math.min(x,w-1))
  --y = math.max(0,math.min(y,h-1))
  rgb = Img[y+1][x+1]
  return cap(rgb[1]),cap(rgb[2]),cap(rgb[3])
 end



 makepal = 0
 if makepal == 1 then
  n = 0
  for y = 0, h, math.floor(h/15) do
  for x = 0, w, math.floor(w/15) do
    r,g,b = frend(x,y,-1,-1)
    setcolor(n,r,g,b); n = n+1
   end
  end; end

 --pal = db.fixPalette(db.makePalList(256))
 ditherprc = 50
 xdith  = 2  -- 5
 ydith  = 4 -- 10
 --db.fsrenderControl(f, title, sampal,usepal,scenepal, ditherprc,xdith,ydith, briweight, sampalcols)
 --db.fsrender(frend,pal,ditherprc,xdith,ydith)
 db.fsrenderControl(frend, "Particle Explosion Render", 1, 0, 0, ditherprc,xdith,ydith, 25, 256)
 --rgb = Img[y+1][x+1]; putpicturepixel(x,y, matchcolor2(rgb[1],rgb[2],rgb[3],0.65))

end -- main

main()





