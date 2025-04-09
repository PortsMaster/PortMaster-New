--PALETTE Adjust: Hue & Lightness V3.5
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")
--> db.shiftHUE(r,g,b,deg)
--> db.changeLightness(r,g,b,percent)
--> db.HSB_regions(hue_center, bri_center, sat_center, r,g,b, edit_width)

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

OK,deg,lig,brikeep,hue_center,bri_center,sat_center,edit_width,amt,penrange = inputbox("Hue & Lightness"..txt,
                        
                          "      HUE °: -180..180", 0, -180,180,0,
                          "LIGHTNESS %: -100..100", 0, -100,100,0, 
                          "Keep Brightness on Hue", 1, 0,1,0,
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

  w, h = getbrushsize()

  for c = 0, 255, 1 do

   if penrange == 0 or (penrange == 1 and c >= range1 and c<= range2) then

     r,g,b = getcolor(c)

     -- HUE shift
     if deg ~= 0 then 
      r2,g2,b2 = db.shiftHUE(r,g,b,deg)
      if brikeep == 1 then
        brio = db.getBrightness(r,g,b)
         for i = 0, 5, 1 do -- 6 iterations, fairly strict brightness preservation
          brin = db.getBrightness(r2,g2,b2)
          diff = brin - brio
          r2,g2,b2 = db.rgbcap(r2-diff, g2-diff, b2-diff, 255,0)
         end
      end
       else r2,g2,b2 = r,g,b
     end
 
     -- Lightness
     if lig ~= 0 then r2,g2,b2 = db.changeLightness(r2,g2,b2,lig); end

     rf,gf,bf = db.editHSBregions(r,g,b,r2,g2,b2, Amount, hue_center, bri_center, sat_center, edit_width)

     setcolor(c,rf,gf,bf)
  
    end -- if deg

  end -- n

end -- ok
