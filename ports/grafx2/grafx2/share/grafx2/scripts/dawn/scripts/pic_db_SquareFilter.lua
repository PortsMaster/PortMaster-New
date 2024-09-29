--PICTURE: Square Filter V2.2
--by Richard Fhager


-- (V2.2 New method, Localized)


dofile("../libs/dawnbringer_lib.lua")

--
function main()

 local x,y,s,q,c,v,w,h,r,g,b,ar,sx,sy,sz,ra,ga,ba,rt,gt,bt,xp,yp,pix,size,gam,rgm,minS,mulS,slotX,slotY
 local tries, clear, Line_Col, Gamma, Line_Strength, Line_Mult, PlaceMult, minSize, maxSize
 local areas,sq,sline,slots,syy
 local mf,mr
 local line

PlaceMult = 6 -- Placement tries multiple 1-10, nominal = 6
Line_Strength = 0.15 -- Base strength
Line_Mult = 0.25 -- Additional strength for largest size square

OK,minsize,mults,PlaceMult,LINE_STR,LINE_MLT,BRIGHTRND = inputbox("Square Filter",
                        
                          "Base Square Size: 2-128", 4, 2,128,0,
                          "Size Multiples: 0-50", 8, 0,50,0,
                          "Frequency: 1-10", PlaceMult, 1,10,0,
                          "Line Base Strength %", Line_Strength*100, 0,100,0,
                          "Line Mult Strength %", Line_Mult*100, 0,100,0,
                          "RND Brightness: 0-128",    25,   0,128,0                                                                    
);


if OK then

Line_Col = matchcolor(0,0,0)
Gamma = 2.0

Line_Strength = LINE_STR / 100
Line_Mult = LINE_MLT / 100


--
function line(x,y,xs,ys,line_str)
 --db.lineTransp(x,y,x+xs-1,y, Line_Col, line_str) 
 --db.lineTransp(x,y,x,y+ys-1, Line_Col, line_str)
 db.lineTransp(x,y+ys-1,x+xs-1,y+ys-1, Line_Col, line_str) 
 db.lineTransp(x+xs-1,y,x+xs-1,y+ys-1, Line_Col, line_str)
end
--

minS = minsize
mulS = mults 


areas = {}
w,h = getpicturesize()

mf,mr = math.floor, math.random

slotX = math.floor(w / minS)
slotY = math.floor(h / minS)

slots = db.newArrayInit2Dim(slotX,slotY,1) 

tries = slotX * slotY / 120 * (1+mf(mulS^0.5)) * PlaceMult^2

--
if mulS > 0 then

for n = 1, tries, 1 do
 --sz = 1 + math.random(1,mulS)
 sz = 2 + mf(mr()*mr()*mulS)
 sx = mr(1,slotX - sz)
 sy = mr(1,slotY - sz)

 size = minS * sz

 ar = sz*sz

 clear = true
 for s = 0, ar-1, 1 do
   x = sx + s%sz
   y = sy + mf(s/sz)
   if slots[y][x] ~= 1 then
    clear = false; break
   end
 end  

 if clear then
   table.insert(areas, #areas+1, {sx-1,sy-1,size,size,sz})
   for y = 0, sz-1, 1 do
    syy = slots[sy+y]
    for x = 0, sz-1, 1 do
     syy[sx+x] = sz
    end
   end
 end

end

end
--


-- Add the remaining single slots
for y = 1, slotY, 1 do
 sline = slots[y]
 for x = 1, slotX, 1 do 
  if sline[x] == 1 then
   --add(areas,{x-1,y-1,minS,minS}) -- coords, size
   table.insert(areas, #areas+1, {x-1,y-1,minS,minS, minS})
   --slots[y][x] = 0
  end
 end
end



-- Render
maxSize = math.max(minS,minS*mulS)
gam = Gamma
rgm = 1 / gam
for s = 1, #areas, 1 do -- {xp,yp,xsize,ysize, size}
 sq = areas[s]
 xp,yp,xs,ys,size = sq[1]*minS,sq[2]*minS,sq[3],sq[4],sq[5]
 rt,gt,bt,pix = 0,0,0,0
  for y = 0, ys - 1, 1 do
   for x = 0, xs - 1, 1 do 
    r,g,b = getcolor(getbackuppixel(xp+x,yp+y))
    rt = rt + r^gam
    gt = gt + g^gam
    bt = bt + b^gam
    pix = pix + 1
   end
  end

  q = 0.1 + (size/maxSize)*0.9 
  v = mr(-BRIGHTRND*q,BRIGHTRND*q)

  ra,ga,ba = (rt/pix)^rgm+v,(gt/pix)^rgm+v,(bt/pix)^rgm+v
  c = matchcolor2(ra,ga,ba)
  for y = 0, ys - 1, 1 do
   for x = 0, xs - 1, 1 do
    putpicturepixel(xp+x,yp+y,c)
   end
  end 
  
  if Line_Strength > 0 or Line_Mult > 0 then
   line(xp,yp,xs,ys,Line_Strength+Line_Mult*((xs-minS)/maxSize) )
  end

  if s%slotX == 0 then
   updatescreen(); if (waitbreak(0)==1) then return; end
  end
end


end -- OK

end 
-- main

main()