--PALETTE: Gamma Adjust V1.5
--by Richard Fhager
 
-- (V1.5 Palette Range selective edit) 

dofile("../libs/dawnbringer_lib.lua")

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

OK,exp,dummy,hue_center,bri_center,sat_center,edit_width,amt,penrange   = inputbox("Gamma Adjust"..txt,
                        
                          "GAMMA: (1/10..10) 1=none", 1.8, 0.1,10,4,
                          
                           --"-- Focus Adjustment at: (-1=n/a) --",0,0,0,0,
                           "Center/Focus Adjustment at: (-1=n/a)",0,0,0,0,

                           pre.."HUE effect focus: 0-359°", hue_center, -1,359,0, -- -1 = off, 360 = Gry, but that has no effect on Hue-shifting
                           pre.."BRI effect focus: 0-255",  bri_center, -1,255,0,
                           pre.."SAT effect focus: 0-100%", sat_center, -1,100,0,
                           "Focus Width %: 1-100", 33, 1,100,0,
                          --"Grays only (Lightness)", 0, 0,1,0, 
                          "AMOUNT %: 1-100", 100, 1,100,0,
                          "Selected Range (#"..range1.."-"..range2..")", 0, 0,1,0                                                
);



if OK == true then

  -- Effect may not be perfectly focused on single color range (rounding?) so turn it off (we didn't want it to begin with)
  if penrange == 1 and range1 == range2 then 
   hue_center,bri_center,sat_center = -1,-1,-1
  end

  Amount = amt / 100


  for c = 0, 255, 1 do

   if penrange == 0 or (penrange == 1 and c >= range1 and c<= range2) then

     r,g,b = getcolor(c)


   r2 = db.gamma(r,255,exp)
   g2 = db.gamma(g,255,exp)
   b2 = db.gamma(b,255,exp)

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

     rf = r*op + r2 * np
     gf = g*op + g2 * np
     bf = b*op + b2 * np

     setcolor(c,rf,gf,bf)
  
    end -- if deg

  end -- n

end -- ok
