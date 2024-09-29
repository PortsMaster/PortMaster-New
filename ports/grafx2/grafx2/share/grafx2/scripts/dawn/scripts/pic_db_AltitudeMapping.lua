--PICTURE: Altitude Mapping
--by Richard Fhager

-- For a cool effect;
-- 1. Set up a nice 256 color gradient from dark to bright 
-- 2. Run [SCENES]-->[Clouds & Noise]-->[Cloud Fractal Presets] with 'Rectangles + Lines'
-- 3. Run this script on the cloud-fractal

dofile("../libs/dawnbringer_lib.lua")

OK,altscale,mIso,m11,m34,m12,mPro,rSolid,rPlot = inputbox("Altitude Mapping (By Brightness)",
                         "Altitude Scale: 0-512", 128, 0,512,0,
                        
                         "1. Isometric",     1,0,1,-1,
                         "2. Front 1/1 View", 0,0,1,-1,
                         "3. Front 3/4 View", 0,0,1,-1,
                         "4. Front 1/2 View", 0,0,1,-1,
                         "5. Profile", 0,0,1,-1,
 
                         "a) Solid Render", 1,0,1,-2,
                         "b) Plot",         0,0,1,-2


                         --"Dither",           0,  0,1,0



                        
                
);


if OK == true then

w, h = getpicturesize()

  bri = {}
  for n = 0, 255, 1 do
    r,g,b = getcolor(n)
    bri[n+1] = db.getBrightness(r,g,b) / 255 * altscale
  end

  ofy = altscale/2 

  line0 = {}
  line1 = {}

  clearpicture(0)
  for y = 0, h-1, 1 do
   line0,line1 = line1,line0
   for x = 0, w-1, 1 do
    c = getbackuppixel(x,y)
    alt = bri[c+1]

    -- iso
    if mIso == 1 then
     xp1 = x+w/2-y; yp1 = y/2+x/2 - alt; upper,left,corner = true,true,true
    end

    -- Front 1/2 view
    if m12 == 1 then 
     xp1 = x; yp1 = h/4+y/2-alt; upper,left,corner = true,false,false
    end

    -- Front 3/4 view
    if m34 == 1 then
     xp1 = x; yp1 = h/8+y*0.75-alt; upper,left,corner = true,false,false
    end 

    -- Front, Flat view
    if m11 == 1 then
     xp1 = x; yp1 = y-alt; upper,left,corner = true,false,false
    end


    -- Profile
    if mPro == 1 then
     xp1 = x; yp1 = h/2-alt; upper,left,corner = true,false,false
    end


    --db.line(xp1,yp1+ofy,xp2,yp2+ofy,c)

    yp1 = math.floor(yp1)

    line0[x+1] = {yp1,c} 


 if rSolid == 1 then

    if y>0 and upper then -- Fill the decending gaps with the color of the lower area
     yl = yp1 - line1[x+1][1]
     if yl > 1 then
      for n = 0, yl-2, 1 do
       putpicturepixel(xp1,yp1-n-1+ofy,c) -- Starting at line above yp1 and working up
      end
     end
    end

    if y>0 and upper then -- Fill the ascending gaps with the color of the lower area (higher area beneath)
     yl = line1[x+1][1] - yp1
     if yl > 1 then
      for n = 0, yl-2, 1 do
       putpicturepixel(xp1,yp1+n+ofy+1,line1[x+1][2])
      end
     end
    end


    ----
    -- iso
    if mIso == 1 then
    
     if x>0 and left then -- Fill the gaps with the color of the lower area

      yl = yp1 - line0[x][1] -- left pixel in iso
      if yl > 1 then
       for n = 0, yl-2, 1 do
        putpicturepixel(xp1,yp1-n-1+ofy, c)
       end
      end

      yl = line0[x][1] - yp1 -- left pixel in iso
      if yl > 1 then
       for n = 0, yl-2, 1 do
        putpicturepixel(xp1,yp1+n+1+ofy, c)
       end
      end

     end

     if x>0 and y>0 and corner then -- Fill the gaps with the color of the lower area

      yl = yp1 - line1[x][1] -- upper left pixel in iso
      if yl > 1 then
       for n = 0, yl-2, 1 do
        putpicturepixel(xp1,yp1-n-1+ofy, c)
       end
      end

      yl = line1[x][1] - yp1 -- upper left pixel in iso
      if yl > 1 then
       for n = 0, yl-2, 1 do
        putpicturepixel(xp1,yp1+n+1+ofy, c)
       end
      end

     end

    end
    ----

   end -- solid mode

   putpicturepixel(xp1,yp1+ofy,c)

  end
  if y%8==0 then updatescreen();if (waitbreak(0)==1) then return end; end
 end


end -- ok
