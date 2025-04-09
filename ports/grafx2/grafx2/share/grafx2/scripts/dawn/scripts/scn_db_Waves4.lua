--BRUSH/PICTURE: Waves Distortion V4.0 
--by Richard 'DawnBringer' Fhager  

--(V4.0 Total revamp, removed Bilinear)


dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_interpolation.lua") -- prefix: ip_

--prePIC / preBRU is set in toolbox-script
prePIC = prePIC or 1
preBRU = preBRU or 0
suffix = " (Brush)"
if prePIC == 1 then suffix = " (Image)"; end



--
function main()

 local Frq,Amp,Dox,Doy,Levels,Void,Edge,Gamma,Wrap,Gamma

 Gamma = 1.6



--Void = 1        -- Fill void with transparent color
--Wrap = 0        -- Wrap edges 
--Edge = 0        -- Stretch Edges

OK,Frq,Amp,Dox,Doy,Levels,Gamma,Void,Edge,Wrap = inputbox("Waves Distortion"..suffix,                
 "Frequency: 0-100.0", 2, 0,100,3,
 "Amplitude: 0-100.0", 2, 0,100,3,
 "X-Waves", 1, 0,1,0,
 "Y-Waves", 1, 0,1,0,
 "Quality: 0-8",  1,  0,16,0, -- Levels 
 "Gamma: 1.0-2.2",   Gamma, 1,2.2,2,         
 --"--- Edge Handling ---",    4, 0,0,0,
 "Edge 1: Fill Transp. Col",   1, 0,1,-1,
 "Edge 2: Stretch",               0, 0,1,-1, 
 "Edge 3: Wrap Around",           0, 0,1,-1  
                                                               
);

if OK then

 local x,y,w,h,w1,h1,sin,cos,max,floor,ceil,frq_adj,amp_adj,f1,f2,Pifreq,Amplitude, W1f,H1f
 local control

 sin,cos,min,max,floor,ceil = math.sin, math.cos, math.min,math.max, math.floor, math.ceil

 frq_adj = 2
 amp_adj = 0.02

if preBRU == 1 then
 w, h = getbrushsize()
 f1 = getbrushbackuppixel
 f2 = putbrushpixel
end

if prePIC == 1 then
 w, h = getpicturesize()
 f1 = getbackuppixel
 f2 = putpicturepixel
end



Pifreq = math.pi*Frq*frq_adj
Amplitude = Amp*amp_adj

--
function control(ox,oy,w1,h1)
 local r,g,b,xp,yp,oox,ooy,px,py,ax,ay
 oox,ooy = ox,oy

  ax,ay = 0.5, 0.5 -- getpixel offset (rounding), must be turned off for wrapping

  if Dox == 1 then
     ox = oox + sin(ooy*Pifreq)*Amplitude
  end
  if Doy == 1 then 
     oy = ooy + sin(oox*Pifreq)*Amplitude   
  end

    -- Default is Void (automatic)
    xp,yp = ox,oy

    if Wrap == 1 then 
     ax,ay = 0,0
     xp,yp = (ox+1)%(1+W1f),(oy+1)%(1+H1f)
    end -- Wrap

    if Edge == 1 then xp = max(min(1,ox),0);  yp = max(min(1,oy),0); end -- Edge Stretch

    ox,oy = xp,yp  

    px,py = ox*w1+ax, oy*h1+ay

    if Void == 1 then -- Negatives are rounded up, causing double thickness on the left/top edges (-0.9 and 0.9 both rounded to 0)
     if px < 0 then px = floor(ox*w1+0.5);end
     if py < 0 then py = floor(oy*h1+0.5);end
    end

    r,g,b = getcolor(f1(px,py));

  return r,g,b 
end
--

 W1f,H1f = 1/(w+1), 1/(h+1) -- For wrapping modulus
 w1,h1 = w-1,h-1


for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
    f2(x,y, matchcolor2(ip_.fractionalSampling(Levels, x,y, w1,h1, control, Gamma)))
  end
  if prePIC == 1 and db.donemeter(10,y,w,h,true) then return; end
end

end -- main
--

end; -- OK


main()


--[[
     -- Crazy wrapping bug hunt
    --xp = (((ox+1)*(w1+0)) % (w1+1)) / (w1+0) 
     --yp = (((oy+1)*(h1+0)) % (h1+1)) / (h1+0) 
 
     --if ox > 1 then xp = ox-1; end
     --if oy > 1 then yp = oy-1; end
     --if ox < 0 then xp = 1+ox; end -- Right side moving in on left
     --if oy < 0 then yp = 1+oy; end -- Bottom moving in top



    --f2(x,y,f1(floor(x),floor(y)))
    --f2(x,y,matchcolor2(control(x/w1,y/h1,w1,h1)))

          if bi == 0 then
           r,g,b = getcolor(f1(floor(ox),floor(oy)));
          end
          if bi == 1 then
           --r,g,b = db.bilinear(max(0,ox-0.5),max(0,oy-0.5),f1,1)
           r,g,b = ip_.pixelRGB_Bilinear(max(0,ox-0.5),max(0,oy-0.5),getbackupcolor,f1,ip_.kenip)
          end
--]]