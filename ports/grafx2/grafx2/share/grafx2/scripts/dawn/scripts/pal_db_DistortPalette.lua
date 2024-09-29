--PALETTE: Distort
--by Richard 'DawnBringer' Fhager


dofile("../libs/dawnbringer_lib.lua")

FG = getforecolor()
BG = getbackcolor()
lo = math.min(FG,BG)
hi = math.max(FG,BG)
pens = "(#"..lo.."-"..hi..")"

OK,red,grn,blu,pen = inputbox("Distort Palette",
                         "RND   Red: 0-255", 32, 0,255,0,
                         "RND Green: 0-255", 32, 0,255,0,
                         "RND  Blue: 0-255", 32, 0,255,0,               
                         "Selected Range "..pens,   0,0,1,0              
);

if OK == true then

  brikeep   = true;
  loosemode = false; 

  for n = 0, 255, 1 do
    if (pen == 0 or (n>=lo and n<=hi)) then
     rd = math.random(0,red)
     gd = math.random(0,grn)
     bd = math.random(0,blu)
     r,g,b = getcolor(n)
     setcolor(n, db.ColorBalance(r,g,b, rd,gd,bd, brikeep, loosemode))
    end 
  end

end -- ok
