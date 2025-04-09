--PALETTE: Curved Ramps V2.0
--by Richard Fhager


-- (V2.0 Gamma correction for auto-midpoints)

dofile("../libs/dawnbringer_lib.lua")

 FC = getforecolor()
 BC = getbackcolor()

 if FC > BC then FC,BC = BC,FC; end

 steps = FC - BC
 cols = math.abs(steps)

 r1,g1,b1 = getcolor(FC)
 r2,g2,b2 = getcolor(BC)

 --hr = (r2 + r1)/2
 --hg = (g2 + g1)/2
 --hb = (b2 + b1)/2

 -- Gamma corrected
 gam = 1.6
 hr = ((r2^gam + r1^gam)/2)^(1/gam)
 hg = ((g2^gam + g1^gam)/2)^(1/gam)
 hb = ((b2^gam + b1^gam)/2)^(1/gam)


--[[ Not in use   
function getHybridDistance(r1,g1,b1,r2,g2,b2,rw,gw,bw, briweight)
  local dist,bdiff
  dist = db.getColorDistance_weightNorm(r,g,b,ro,go,bo,0.26,0.55,0.19)
  bdiff = math.abs(db.getBrightness(r1,g1,b1) - db.getBrightness(r2,g2,b2))
  return dist * (1-briweight) + bdiff * briweight
end
--]]
      




OK,rm,gm,bm,unidist,trudist,proxdist,briweight,priweight,amount = inputbox("Pencolor Ramp-Curves (gamma = "..gam..")",
                           --"R (midpoint: inital)",    hr,  -128,386,0,
                           --"G ( RGB-values are )",    hg,  -128,386,0,
                           --"B ( from pencolors )",    hb,  -128,386,0, 

                           "R: (midpoint: preset is)",    hr,  -128,386,0,
                           "G: (  gamma-corrected  )",    hg,  -128,386,0,
                           "B: ( pencolors average )",    hb,  -128,386,0, 
                           --"1. Spline (touch RGB)", 1,  0,1,-1,  
                           --"2. Bezier (bend RGB)", 0,  0,1,-1,                          
                           "1.     Uniform Distances",     0,  0,1,-2,  
                           "2.  Perceptual Distances",  0,  0,1,-2, 
                           "3. Prox-Hybrid Distances*", 1,  0,1,-2, 
                           "* BriWeight: 0..1",    0.7,    0,1,2,
                           "* PrimProx Weight: 0..1",  0.6, 0,1,2,
                           "Curve Amount %",    100,  0,100,0  
);

if OK == true then

 rw,gw,bw = db.getDefaultRGBweights()

 spl,bez = 1,0

 -- Amount/Strength (Actually a 50% Spline is the same as a Bezier-curve)
 amt = amount/100
 rev = 1 - amt
 rm = (r1+r2)/2*rev + rm*amt
 gm = (g1+g2)/2*rev + gm*amt
 bm = (b1+b2)/2*rev + bm*amt
 --
 
 if spl == 1 then
  -- Extended bz point for Spline-curve
  zR = 2*rm - (r1+r2)/2
  zG = 2*gm - (g1+g2)/2
  zB = 2*bm - (b1+b2)/2
  rm,gm,bm = zR,zG,zB
 end

 points = 2001 -- 1001 is not enough, same color point can casue error
 --if adjust == 0 then points = cols + 1; end
 data = {}
 ro,go,bo = r1,g1,b1
 dist,pdist = 0,0


 if bez == 1 or spl == 1 then

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
 
   r,g,b = db.rgbcap(r,g,b,255,0)


    dist = dist + ((r-ro)^2 + (g-go)^2 + (b-bo)^2)^0.5
     
    if trudist == 1 then
     pdist = pdist + db.getColorDistance_weightNorm(r,g,b,ro,go,bo,rw,gw,bw) -- Normalizing shouldn't be required but there might be better?
    end    

    if proxdist == 1 then
     --pdist = pdist + db.getColorDistanceProx(r,g,b,ro,go,bo,0.333,0.333,0.333,1.0, priweight, briweight) -- cv, briweight
     pdist = pdist + db.getColorDistanceProx(r,g,b,ro,go,bo,0.26,0.55,0.19,1.569, priweight, briweight) -- cv, briweight
     --pdist = pdist + getHybridDistance(r,g,b,ro,go,bo,0.26,0.55,0.19, 0.65)
    end


   ro,go,bo = r,g,b
   data[n+1] = {r,g,b,dist,pdist}

   --if adjust == 0 then setcolor(FC+n, r,g,b); end

  end

 --messagebox(dist.." "..pdist)

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
   for n = 0, cols, 1 do -- Search for the datapoints that best matches the intended colors

     if unidist == 1 then
      rf,gf,bf,dpos,pd = findBestMatch(n*delta,data,dpos,4,5)
     end    

     if trudist == 1 or proxdist == 1 then
       rf,gf,bf,dpos,pd = findBestMatch(n*pdelta,data,dpos,5,4) -- read perceptual, return linear
        p = n*delta -- ok, so the found point may not be exactly n*delta...but it can't diff by much.
       ap =  p + (p-pd*qf)/dist * p * (dist - p)/dist
       --ap = pd*qf
       --ap = p * (p/(pd*qf))
       --ap = (dist - pd*qf)
       --rf,gf,bf,dummy,dummy = findBestMatch(ap,data,1)
       rf,gf,bf,dummy,dummy = findBestMatch(pd,data,1,4,5) -- pd is the linear value here
     end

     setcolor(FC+n, rf,gf,bf)
   end

 end -- bez



 if sin == 1 then

  mid = math.ceil((cols + 1) / 2)

  r1d =  (rm - r1)
  g1d =  (gm - g1)
  b1d =  (bm - b1)

  r2d =  (r2 - rm) 
  g2d =  (g2 - gm) 
  b2d =  (b2 - bm) 

  stp = math.pi/cols

  for n = 0, cols, 1 do
   A = 1/cols * n
   B = 1 - A 
   Q = math.sin(stp * n)
   W = 1 - Q
   r = (r1*B + r2*A) * W + rm*Q
   g = (g1*B + g2*A) * W + gm*Q
   b = (b1*B + b2*A) * W + bm*Q
   setcolor(FC+n, r,g,b)
  end

 end -- sin


end



