--PICTURE: Threshold V2.0
--by Richard 'DawnBringer' Fhager

-- (V2.0 Gradient Exponent, Pre-calc remapping)

-- The (modifed) Photoshop effects: 
-- * Threshold    - Split image into black&white (or pencolors here) at a given brightness level (threshold). 
-- * Gradient Map - Apply a gradient (pencolors) over the brightness-range with threshold as midpoint.
--

dofile("../libs/dawnbringer_lib.lua")
--dofile("../libs/db_interpolation.lua") 

-- Not in use
function ip(v) -- from blenders s-curves
 m = math
 ofs = 0
 mul = 2
 sub = 0.5 - 0.5 / mul
 return 1 - (m.cos(m.min(1,m.max(0,(v-sub+ofs)*mul)) * m.pi) + 1)/2 -- variable
end


OK,dummy,thresh,grad,threshold,grad_exp,AMOUNT,BRIWT = inputbox("Threshold & Gradient Map",  
        "--- Uses PenColors (BG/FG) ---", 0,0,0,4,
        "1. Threshold Split BG/FG",        1,  0,1,-1,
        "2. Gradient Map BG->FG *",     0,  0,1,-1,
        "Threshold (split level)", 128,  1,254,0, 
        "* Gradient Exponent", 1,  0.1,20,2, 
        "AMOUNT %", 100,  0,100,0,                 
        "ColMatch Bri-Weight %", 25,  0,100,0 
                          
);


if OK == true then

--
function thold(thresh,grad,briweight,amt,grad_exp)

 local w,h,x,y,c,r1,g1,b1,r1,g2,b2,rm,gm,bm,rc,gc,bc,f1,f2,ramt,match,ip1,ip2,n,remap

 function ip1(v,e)
  return v^e
 end

 function ip2(v,e)
  return 1-((1-v)^e)
 end

 match = matchcolor2

 ramt = 1 - amt

 w,h = getpicturesize()

 r1,g1,b1 = getcolor(getbackcolor())
 r2,g2,b2 = getcolor(getforecolor())

 rm,gm,bm = (r1+r2)/2,(g1+g2)/2,(b1+b2)/2


 remap = {}
 for n = 0, 255, 1 do
 
  rc,gc,bc = getcolor(n)

  bri = db.getBrightness(rc,gc,bc)

  if bri <= threshold then
   if thresh == 1 then
    c = match(r1*amt+rc*ramt, g1*amt+gc*ramt, b1*amt+bc*ramt, briweight)
   end
   if grad == 1 then
    --f1 = bri / threshold;
    f1 = ip1(bri / threshold, grad_exp)
    f2 = 1 - f1 
    c = match((rm*f1 + r1*f2)*amt+rc*ramt, (gm*f1 + g1*f2)*amt+gc*ramt, (bm*f1 + b1*f2)*amt+bc*ramt, briweight)
   end
  end

  if bri > threshold then
   if thresh == 1 then
    c = match(r2*amt+rc*ramt, g2*amt+gc*ramt, b2*amt+bc*ramt, briweight)
   end
   if grad == 1 then
    --f1 = (bri - threshold) / (255 - threshold)
    f1 = ip2((bri - threshold) / (255 - threshold), grad_exp)
    f2 = 1 - f1
    c = match((rm*f2 + r2*f1)*amt+rc*ramt, (gm*f2 + g2*f1)*amt+gc*ramt, (bm*f2 + b2*f1)*amt+bc*ramt, briweight)
   end
  end

  remap[n+1] = c

 end

 -- Remap
 for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   putpicturepixel(x,y, remap[1 + getbackuppixel(x,y)])
  end
  if db.donemeter(32,y,w,h,true) then return; end
 end


end 
-- function




briweight = BRIWT / 100
amt = AMOUNT / 100

thold(thresh,grad,briweight,amt,grad_exp)

end -- ok
