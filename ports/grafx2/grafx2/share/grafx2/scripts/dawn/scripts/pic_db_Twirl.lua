--PICTURE: Twirl V2.0
--by Richard 'DawnBringer' Fhager

-- (V2.0 ip_.fractionalSampling, Gamma, Removed Bilinear IP)

dofile("../libs/db_interpolation.lua") -- prefix: ip_
dofile("../libs/dawnbringer_lib.lua")


-- Using more than 4 Levels will be overkill for basic use and moderate distortions

--
function main()

 local Ang,Edge_damp,Cx,Cy,interpolate,aa_lev,Gamma,square,match2
 local w,h,r,g,b,c,wd,ht,match,mf,mx,upd,x_sq,y_sq,xf,yf,xd,yd,dist
 local control

 OK,Ang,Edge_damp,Cx,Cy,aa_lev,Gamma,square = inputbox("Image Twirl v2.0",
                      "Angle: -1000..1000", 90, -1000,1000,0,
                      "Edge Hardness: 0.0-10.0", 1.0, 0,10,2,
                      "Center X: 0..1", 0.5, 0,1,4,
                      "Center Y: 0..1", 0.5, 0,1,4,
                      --"1. Interpolate or...", 1, 0,1,0,
                      "Quality: 0-6",  3,  0,6,0, -- "AA-levels"
                      "Gamma", 1.6, 1,5,3,
                      "Square over Scale", 0, 0,1,0 
                      --"Perceptual ColMatch (mc2)", 0, 0,1,0  -- match2
 );

 if OK then

  w, h = getpicturesize()

  upd = math.ceil(h / 64) -- Update frequency

  --match = matchcolor; if match2 == 1 then match = matchcolor2; end
  match = matchcolor2

  wd = w
  ht = h

  mf = math.floor
  mx = math.max

  x_sq,y_sq = 1,1

 --square = 0
 if square == 1 then
  if w < h then
   x_sq = 1; y_sq = w/h
   wd = w
   ht = w
   Cy = Cy * h/w
  end
  if w > h then
   x_sq = h/w; y_sq = 1 
   wd = h
   ht = h
   Cx = Cx * w/h
  end
 end


--
function control(ox,oy,w,h)

 local xr,yr,xp,yp,r,g,b,ofs,a,dist

 dist = mx(0, 1 - 2 * ((ox-Cx)*(ox-Cx) + (oy-Cy)*(oy-Cy))^0.5)

 a = dist^(Edge_damp+1) * Ang;

 xr,yr = db.rotationFrac(a,Cx,Cy,ox,oy)
 xp,yp = xr * w, yr * h 

 r,g,b = getcolor(getbackuppixel(xp+0.5,yp+0.5));
    
 return r,g,b
end
--


for y = 0, h - 1, 1 do

  yf = y/ht
  yd = (yf-Cy)*(yf-Cy)

  for x = 0, w - 1, 1 do

   xd = x/wd - Cx
   dist = mx(0, 1 - 2 * (xd*xd + yd)^0.5)
   --dist = xd*xd + yd -- Works, but doesn't seem to give any speed improvement

   if dist > 0 then  -- > 0 for old dist, <= 0.25 for new
    r,g,b = ip_.fractionalSampling(aa_lev, x,y, wd,ht, control, Gamma)
    c = match(r,g,b) 
     else 
      c = getbackuppixel(x,y) -- yes, no +0.5, we're just keeping the original image here
   end

   putpicturepixel(x, y, c);

  end -- x

  if db.donemeter(upd,y,w,h,true) then return; end
end -- y

end -- OK
end -- main
--

t1 = os.clock()

main()

--messagebox("Seconds: "..(os.clock() - t1))




--[[
--
function OLDcontrol(ox,oy,gamma)

 local xr,yr,xp,yp,r,g,b,ofs,d,dist

     dist = mx(0, 1 - 2 * ((ox-Cx)*(ox-Cx) + (oy-Cy)*(oy-Cy))^0.5)

     d = dist^(Edge_damp+1) * Ang;

     xr,yr = db.rotationFrac(d,Cx,Cy,ox,oy)
     xp,yp = xr * wd, yr * ht 

     --function db.bilinear(ox,oy,w,h,func) -- w&h for edge-wrapping (not used by twirl)
     if interpolate == 1 then
      if aa_lev > 0 then gamma = 1.0; end -- Wrong to use gamma on both levels AND ip (basically doubled effect)
      ofs = 0.0 -- 0 offset seem to be correct for the edges of twirl
       --r,g,b = ip_.pixelRGB_Bicubic(math.max(0,xp+ofs),math.max(0,yp+ofs),getbackupcolor,getbackuppixel,ip_.cubip)
       if gamma == 1.0 then
        r,g,b = ip_.pixelRGB_Bilinear(xp+ofs, yp+ofs, getbackupcolor, getbackuppixel, ip_.linip)
         else
          r,g,b = ip_.pixelRGB_Bilinear_PAL_gamma(xp+ofs, yp+ofs, getbackupcolor, getbackuppixel, ip_.linip, gamma) 
       end
        else
         r,g,b = getcolor(getbackuppixel(xp+0.5,yp+0.5));
     end
 
 return r,g,b
end
--
--]]

