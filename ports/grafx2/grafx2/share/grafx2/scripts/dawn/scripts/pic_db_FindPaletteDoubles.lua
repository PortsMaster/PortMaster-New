--PICTURE: Find Palette Duplicates
-- (Duplicates marked with 'X')
--

dofile("../libs/dawnbringer_lib.lua")

palList = db.fixPalette(db.makePalList(256),0)



-- Palette
if palList["doubles"] == nil then 
 messagebox ("Palette not processed - Doubles cannot be marked"); 
 palList["doubles"] = {}
end
yo = 1
xo = 1
cw = 12
ch = 12
cols = 32
rows = 8

w,h = getpicturesize()
setpicturesize(math.max(cols*cw,w),math.max(rows*ch,h))

good = true
bl = matchcolor(0,0,0)
wt = matchcolor(255,255,255)
for y = 0, rows-1, 1 do
 for x = 0, cols-1, 1 do
  xp = xo + x*cw
  yp = yo + y*ch
  c = y*32+x
  db.drawRectangle(xp,yp,cw,ch,c)
   if palList["doubles"][c] == true then -- Mark doubles
    good = false
    db.line(xp,yp+1,xp+cw-1,yp+ch,bl)
    db.line(xp+cw,yp+1,xp,yp+ch,bl)
    db.line(xp,yp,xp+cw-1,yp+ch-1,wt)
    db.line(xp+cw-1,yp,xp,yp+ch-1,wt)
   end
 end
end

if good then
 messagebox ("Find Palette Duplicates", "Palette is good, No Duplicates found!"); 
end

--