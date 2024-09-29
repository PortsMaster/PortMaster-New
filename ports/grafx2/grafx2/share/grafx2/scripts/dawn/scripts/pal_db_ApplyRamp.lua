--PALETTE: Apply Ramp
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")



function curveRamp(rgb1,rgb2,rgb3)

 local n,r,g,b,sqrt,data

 sqrt = math.sqrt

 cols = 255 -- in this case, brightness levels.

 r1,g1,b1 = rgb1[1],rgb1[2],rgb1[3]
 r2,g2,b2 = rgb2[1],rgb2[2],rgb2[3]
 rm,gm,bm = rgb3[1],rgb3[2],rgb3[3]

 -- Extended bz point for Spline-curve
 zR = 2*rm - (r1+r2)/2
 zG = 2*gm - (g1+g2)/2
 zB = 2*bm - (b1+b2)/2
 rm,gm,bm = zR,zG,zB

 points = 2001 -- 1001 is not enough, same color point can casue error
 data = {}
 ro,go,bo = r1,g1,b1
 dist,pdist = 0,0

  div = points-1 

  r1d =  (rm - r1) / div
  g1d =  (gm - g1) / div
  b1d =  (bm - b1) / div

  r2d =  (r2 - rm) / div
  g2d =  (g2 - gm) / div
  b2d =  (b2 - bm) / div

  for n = 0, points-1, 1 do -- Create Data point for colordistance adjustment (not perceptual)

   A = 1/(points-1) * n
   B = 1 - A 

   r = (r1 + r1d*n)*B + (rm + r2d*n)*A
   g = (g1 + g1d*n)*B + (gm + g2d*n)*A
   b = (b1 + b1d*n)*B + (bm + b2d*n)*A
 
   --r,g,b = db.rgbcap(r,g,b,255,0) -- Why cap, it can curve outside colorspace. this is cause of failure

   dist = dist + sqrt((r-ro)^2 + (g-go)^2 + (b-bo)^2) 
   pdist = pdist + db.getColorDistance_weightNorm(r,g,b,ro,go,bo,0.26,0.55,0.19) -- Normalizing shouldn't be required but there might be better?
  
   ro,go,bo = r,g,b
   data[n+1] = {r,g,b,dist,pdist}

  end


 function findBestMatch(value,data,pos,index1,index2) -- data is [[r,g,b,distance],..], pos is start search position
   local best,bestn,looking,lastdiff,diff,rf,gf,bf,r,g,b,d,pd,pf,pt,points,dpos
   best,bestn,looking,lastdiff = 999999999,0,true,999999999
   rf,gf,bf,pf = -1,-1,-1,-1
   points = #data
    while looking do
      pt = data[pos]; r,g,b,d,pd = pt[1],pt[2],pt[3],pt[index1],pt[index2]
      diff = math.abs(value - d)
      if diff < best then bestn = pos; best = diff; rf,gf,bf,pf = r,g,b,pd; end
      pos = pos + 1
      if diff > lastdiff or pos > points then looking = false; dpos = pos; end
      lastdiff = diff
    end
   return rf,gf,bf,dpos,pf
 end -- find

   delta = dist / cols
   pdelta = pdist / cols
   qf = dist/pdist
   dpos = 1
   ramp = {}
   for n = 0, cols, 1 do -- Search for the datapoints that best matches the intended colors
    rf,gf,bf,dpos,pd = findBestMatch(n*pdelta,data,dpos,5,4) -- read perceptual, return linear
    p = n*delta -- ok, so the found point may not be exactly n*delta...but it can't diff by much.
    --ap =  p + (p-pd*qf)/dist * p * (dist - p)/dist
    rf,gf,bf,dummy,dummy = findBestMatch(pd,data,1,4,5) -- pd is the linear value here
    ramp[n+1] = {rf,gf,bf} 
   end

   return ramp
end -- curveRamp




--r1,g1,b1 = 0,0,255; r2,g2,b2 = 0,0,-192 -- Natural (Blue to Yellow)
--r1,g1,b1 = 255,-128,-255; r2,g2,b2 = 255,0,-128 -- Sepia/Hellfire
--r1,g1,b1 = 255,-255,255; r2,g2,b2 = -255,255,255 -- violett-turq
--r1,g1,b1 = 128,0,255; r2,g2,b2 = 255,0,-128 -- Violett-red 
--r1,g1,b1 = 32,0,112; r2,g2,b2 = 255,112,-96 --  Summer Evening
--r1,g1,b1 = -112,-112,-64; r2,g2,b2 = -96,-48,-40 -- Night (add mode)
--r1,g1,b1 = 0,128,255; r2,g2,b2 = 0,255,255 -- Under Water 


function main()
 INPUT = 0
 selectbox("Palette Apply ColorRamps", 
  "PRESETS 1",      function() INPUT = 1; end,
  "FROM PENCOLORS", function() INPUT = 2; end,
  --"[Info]", _info,
  "[Quit]", _quit -- We cannot go back to the DB ToolBox from here
);
end

main()



if INPUT == 1 then
 OK,opt1,opt2,opt3,opt4,opt5,opt6,opt7,brikeep,amount = inputbox("Apply Balancing ColorRamps",
                           "1. Twilight",         1,  0,1,-1,  
                           "2. Hellfire",         0,  0,1,-1, 
                           "3. Summer Evening",   0,  0,1,-1,   
                           "4. Natural HueShift", 0,  0,1,-1,    
                           "5. Water/Winter",     0,  0,1,-1,  
                           "6. Night (Add mode)", 0,  0,1,-1,  
                           "7. Cold War (Add mode)",     0,  0,1,-1,                            
                           "Keep Brightness (off=Add)", 1, 0,1,0,
                           "AMOUNT %",    50,  1,100,0  
 );
end


if opt1 == 1 then
 -- Twilight (blue-red-yellow)
 rgb1 = {0,0,255}
 rgb2 = {255,255,0}
 rgb3 = {255,96,0} -- Midpoint
end

if opt2 == 1 then
 -- Hellfire
 rgb1 = {255,-128,-255}
 rgb2 = {255,0,-128}
 rgb3 = {255,-64,-192} -- Midpoint
end

if opt3 == 1 then
 -- Summer evening ?
 rgb1 = {-48,-112,160}
 rgb2 = {160,0,-96}
 rgb3 = {16,32,-48} -- Midpoint
end

if opt4 == 1 then
 -- Natural
 rgb1 = {-70,-100,180}
 rgb2 = {120,60,-180}
 rgb3 = {35,45,-85} -- Midpoint
end

if opt5 == 1 then
 -- Under Water
 rgb1 = {-176,-80,32}
 rgb2 = {-144,0,0}
 rgb3 = {-160,-40,16} -- Midpoint
end

if opt6 == 1 then
 -- Night (darker)
 rgb1 = {-208,-192,-112}
 rgb2 = {-160,-128,-112}
 rgb3 = {-192,-160,-112} -- Midpoint
 brikeep = 0
end

if opt7 == 1 then
 -- Cold War (Contrast, blue/cyan ish.)
 rgb1 = {-255,-224,-240}
 rgb2 = {160,192,208}
 rgb3 = {-32,0,32} -- Midpoint
 brikeep = 0
end

if opt8 == 1 then
 -- Azure Dreams
 rgb1 = {255,-255,255}
 rgb2 = {255,255,-255}
 rgb3 = {-255,255,255} -- Midpoint
end


if INPUT == 2 then

 FC = getforecolor()
 BC = getbackcolor()

 --if FC > BC then FC,BC = BC,FC; end

 r1,g1,b1 = getcolor(FC)
 r2,g2,b2 = getcolor(BC)

 hr = (r2 + r1)/2
 hg = (g2 + g1)/2
 hb = (b2 + b1)/2

 OK,dummy1,dummy2,rm,gm,bm,brikeep,amount = inputbox("Apply Pencolor Ramp-Curves",
                           "Ramp Colors: ".."#"..FC.." & #"..BC,               0,0,0,-2, 
                           "From ["..r1..","..g1..","..b1.."] to ["..r2..","..g2..","..b2.."]",               0,0,0,-2,   
                           "R: (midpoint: inital..)",    hr,  -128,386,0,
                           "G: (..RGB-values are..)",    hg,  -128,386,0,
                           "B: (..from pencolor avg.)",    hb,  -128,386,0, 
                           "Keep Brightness (off=Add)", 1, 0,1,0,
                           "AMOUNT %",    100,  0,100,0  
 );

 rgb1 = {r1,g1,b1}
 rgb2 = {r2,g2,b2}
 rgb3 = {rm,gm,bm}

end


if OK then

 -- There can be odd results with strict brikeep, but the dif between plain add and loose-brikeep is just too small to warrant

if brikeep == 1 then brik = 1; end
--brik = 1
--loose = 1

amt = amount / 100 or 1.0

brikeep   = false;
loosemode = false; 
if  brik == 1 then brikeep = true; loosemode = false; end
if loose == 1 then brikeep = true; loosemode = true; end


  if (rgb1[1] == rgb2[1] and rgb1[1] == rgb3[1]) and (rgb1[2] == rgb2[2] and rgb1[2] == rgb3[2]) and (rgb1[3] == rgb2[3] and rgb1[3] == rgb3[3]) then
   return
  end

  ramp = curveRamp(rgb1,rgb2,rgb3)

  for n = 0, 255, 1 do
     r,g,b = getcolor(n)
     bf = db.getBrightness(r,g,b) / 255 
     br = 1 - bf
     --ra,ga,ba = (r1*br + r2*bf)*amt, (g1*br + g2*bf)*amt, (b1*br + b2*bf)*amt
     rgb = ramp[math.floor(bf*255)+1]
     ra,ga,ba = rgb[1]*amt, rgb[2]*amt, rgb[3]*amt
     rn,gn,bn = db.ColorBalance(r,g,b, ra,ga,ba, brikeep, loosemode)
     setcolor(n,rn,gn,bn)
  end

end -- ok