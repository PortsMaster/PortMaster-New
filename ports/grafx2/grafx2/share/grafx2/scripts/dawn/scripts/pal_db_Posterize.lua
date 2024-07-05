--PALETTE: Posterize V1.0
--by Richard Fhager

dofile("../libs/dawnbringer_lib.lua")

FC = getforecolor()

hue_center, bri_center, sat_center, txt,pre = -1,-1,-1," [FG=BG->get focus]",""
-- Get HSB values from pencolor
if getforecolor() == getbackcolor() then
  txt = " [Pen values*]"
  pre = "*"
  hue_center, bri_center, sat_center = db.getHSB(getcolor(getforecolor()))
end

OK,bits,dummy,hue_center,bri_center,sat_center,edit_width,amt,penonly   = inputbox("Posterize"..txt,
                        
                          "BITS / CHANNEL: 1-7", 2, 1,7,0,
                
                          "Center/Focus Adjustment at: (-1=n/a)",0,0,0,0,
                           pre.."HUE effect focus: 0-359°", hue_center, -1,359,0, -- -1 = off, 360 = Gry, but that has no effect on Hue-shifting
                           pre.."BRI effect focus: 0-255",  bri_center, -1,255,0,
                           pre.."SAT effect focus: 0-100%", sat_center, -1,100,0,
                           "Focus Width %: 1-100", 33, 1,100,0,
                          --"Grays only (Lightness)", 0, 0,1,0, 
                          "AMOUNT %", 100, 1,100,0,
                          "Pen-Color only (#"..FC..")", 0, 0,1,0                                                
);



if OK == true then

  Amount = amt / 100

  div = 2^(8-bits)
  mult = 255 / (2^bits - 1)

  for n = 0, 255, 1 do

   if penonly == 0 or n == FC then

     r,g,b = getcolor(n)


   r2 = math.floor(r / div) * mult
   g2 = math.floor(g / div) * mult
   b2 = math.floor(b / div) * mult


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

     setcolor(n,rf,gf,bf)
  
    end -- if deg

  end -- n

end -- ok
