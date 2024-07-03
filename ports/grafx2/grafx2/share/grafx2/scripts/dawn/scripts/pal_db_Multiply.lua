--PALETTE: Multiply V1.0
--by Richard Fhager 


dofile("../libs/dawnbringer_lib.lua")
--> db.multiply(r,g,b,mult)
--> db.HSB_regions(hue_center, bri_center, sat_center, r,g,b, edit_width)

---------------------------------------------------
function taperCurve(xi,exp,steps) -- 0..255

 local interpolate

 -- ex: {{0,5},{2,7},{5,9}}
function interpolate(list) -- [[x,y],..] interpolate y for all missing values of x, x are in order lo-hi
 local n,x,yi,p1,p2,x1,x2,y1,y2,xd,data,index
 data = {}
 index = 0
 for n = 1, #list-1, 1 do
  p1 = list[n]
   index = index + 1;  data[index] = p1[2] --data[index] = p1
  p2 = list[n+1]
  x1,y1 = p1[1],p1[2]
  x2,y2 = p2[1],p2[2]
  xd = x2 - x1 - 1
  if xd >= 1 then
   yi = (y2 - y1) / (xd+1)
   for x = 1, xd, 1 do 
    index = index + 1
    --data[index] = {x1+x,y1+yi*x}
    data[index] = y1+yi*x
   end
  end
 end
 index = index + 1; data[index] = p2[2] --data[index] = p2
 --messagebox(index)
 return data
end

local points,pcount,n,x1,y1,x2,y2,x3,y3,x,y,x_inp,f,fr,fp,data

points = {}; pcount = 0

for n = 0, steps, 1 do

 f  = n / steps -- x value, INPUT VALUE, fraction of max colorchannel (255)
 fr = 1 - f
 fp = f^exp -- Simulate being "further along the multiply line" to create a sharper curve. 0.33-0.5 is good

 -- Spline line
 x1 = 0*fr + xi*fp
 y1 = 0*fr +  1*fp
 x2 = xi*fr + 1*f
 y2 = 1 
 --
 -- Spline point (as fraction of x)
 x3 = x1*fr + x2*f
 y3 = y1*fr + y2*f -- y3 = f*fr+f = f*(2-f)

 pcount = pcount + 1; points[pcount] = {math.floor(x3*255),y3*255}

end -- n

 data = interpolate(points)

 return data
end
--
----------------------- eof taperCurve -------------------------


FC = getforecolor()
BC = getbackcolor()
range1 = math.min(FC,BC)
range2 = math.max(FC,BC)

hue_center, bri_center, sat_center, txt,pre = -1,-1,-1," [FG=BG->get focus]",""
-- Get HSB values from pencolor
if getforecolor() == getbackcolor() then
  txt = " [Pen values*]"
  pre = "*"
  hue_center, bri_center, sat_center = db.getHSB(getcolor(getforecolor()))
end

OK,mult,taper_str,bri,anorm,hue_center,bri_center,sat_center,edit_width,penrange   = inputbox("Multiply"..txt,
                        
                         
                          "MULTIPLY: 0.0039..255", 1.5, 0,255,4,
                          --"Taper off effect*", 0, 0,1,0,
                          "Taper Off Effect %", 0, 0,100,4,  
                          "Brightness Adjust...", 0, -65025,65025,0,
                          "...or Auto Normalize", 0, 0,1,0,
                          --"----------------------",0,0,0,-4,
                           pre.."HUE effect focus: 0-359°", hue_center, -1,359,0, -- -1 = off, 360 = Gry, but that has no effect on Hue-shifting
                            pre.."BRI effect focus: 0-255",  bri_center, -1,255,0,
                            pre.."SAT effect focus: 0-100%", sat_center, -1,100,0,
                            "Focus Width %: 1-100", 33, 1,100,0,
                          --"Grays only (Lightness)", 0, 0,1,0, 
                          --"AMOUNT %: 1-100", 100, 1,100,0,
                          "Selected Range (#"..range1.."-"..range2..")", 0, 0,1,0
                                                
);


if OK == true then

  if taper_str > 0 then taper = 1; end

  if anorm == 1 then -- Normalize by brightest color in palette
   maxbri = 0
   for c = 0, 255, 1 do
     maxbri = math.max(maxbri, db.getBrightness(getcolor(c)))
   end
   bri = 255 - mult*maxbri
  end

  -- Effect may not be perfectly focused on single color range (rounding?) so turn it off (we didn't want it to begin with)
  if penrange == 1 and range1 == range2 then 
   hue_center,bri_center,sat_center = -1,-1,-1
  end

  --Amount = amt / 100
  Amount = 1

  w, h = getbrushsize()

  taper_flag, curve = false,nil
  if taper == 1 then 
    taper_flag = true; 
    if mult > 1 then
     xi = 1 / mult
     exp = taper_str / 100  
     curve = taperCurve(xi,exp,25) -- roof intersection, exponent 0.01..1.0 (lower = sharper curve = less taper), data points
    end
  end

  for c = 0, 255, 1 do

   if penrange == 0 or (penrange == 1 and c >= range1 and c<= range2) then

     r,g,b = getcolor(c)

     -- Multiply
     r1,g1,b1 = db.multiply(r,g,b,mult,taper_flag,curve)
     r1,g1,b1 = r1+bri, g1+bri, b1+bri

     --
     -- Edit Regions (centre effect in desired hue/bri/sat registers)
     --
     rf,gf,bf = r,g,b
     hue_factor = 1
     bri_factor = 1
     sat_factor = 1
     op,np = 0,1

     hue_factor, bri_factor, sat_factor = db.HSB_regions(hue_center, bri_center, sat_center, r,g,b, edit_width) 
     np = hue_factor * bri_factor * sat_factor * Amount
     op = 1 - np

     rf = r*op + r1 * np
     gf = g*op + g1 * np
     bf = b*op + b1 * np

     setcolor(c,rf,gf,bf)

   end -- inside penrange

  end -- c

end -- ok
