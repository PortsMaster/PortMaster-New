--PALETTE: Natural Brightness V0.9 (Fhager 2017)

-- Load function library (db)
dofile("../libs/dawnbringer_lib.lua") 
--> db.HSB_regions(hue_center, bri_center, sat_center, r,g,b, edit_width)
--> db.naturalBrightness(value,amount,step)

FC = getforecolor()
BC = getbackcolor()
range1 = math.min(FC,BC)
range2 = math.max(FC,BC)

hue_center, bri_center, sat_center, txt,pre = -1,-1,-1," [FG=BG->focus]",""
-- Get HSB values from pencolor
if getforecolor() == getbackcolor() then
  txt = " [Pen*]"
  pre = "*"
  hue_center, bri_center, sat_center = db.getHSB(getcolor(getforecolor()))
end

OK,bripercent,dummy, dummy, hue_center,bri_center, sat_center, edit_width, penrange = inputbox("Natural Brightness"..txt,
                     
                         "BRIGHTNESS %: -100..100", 0, -100,100,2,
                                                             "",0,0,0,0,
                         "Center/Focus Adjustment at: (-1=n/a)",0,0,0,0,
                            pre.."HUE effect focus: 0-359°", hue_center, -1,359,0, -- -1 = off, 360 = Gry, but that has no effect on Hue-shifting
                            pre.."BRI effect focus: 0-255",  bri_center, -1,255,0,
                            pre.."SAT effect focus: 0-100%", sat_center, -1,100,0,
                          "Focus Width %: 1-100", 33, 1,100,0,
                          "Selected Range (#"..range1.."-"..range2..")", 0, 0,1,0

                
);


if OK == true then

 bri = bripercent * 2.55

 -- Effect may not be perfectly focused on single color range (rounding?) so turn it off (we didn't want it to begin with)
 if penrange == 1 and range1 == range2 then 
  hue_center,bri_center,sat_center = -1,-1,-1
 end

  for c = 0, 255, 1 do
    if penrange == 0 or (penrange == 1 and c >= range1 and c<= range2) then

     r,g,b = getcolor(c)
     r2,g2,b2 = r,g,b

     -- Inverse, Finds the point on the curve (x) with the value of c (y), adds brightness to that value and get the curve pos (y)
     --  calculates the differance and adds it to the original channel value.
     --  Ex. Channel value is 100, the curve may find this value (y) at x=150
     --  Brightness change is 20 and added to 150 for 170.
     --  The differance in curve value (y) for 150 and 170 is added to the original channel value 
     --
     r2 = db.naturalBrightness(r, bri, 0.25)
     g2 = db.naturalBrightness(g, bri, 0.25)
     b2 = db.naturalBrightness(b, bri, 0.25)  

     Amount = 1
     rf,gf,bf = db.editHSBregions(r,g,b,r2,g2,b2, Amount, hue_center, bri_center, sat_center, edit_width)

     setcolor(c, rf, gf, bf)
    end
  end

end