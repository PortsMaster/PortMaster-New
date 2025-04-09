
 -- ASCII 32-95

-- S!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_


--[[
function text.font_default()

local c

c = {}

c.xsize = 4
c.ysize = 5

-- SPACE
c[32] = {
{0,0,0,0},
{0,0,0,0},
{0,0,0,0},
{0,0,0,0},
{0,0,0,0}
}
--]]

 -- assumes font graphics placed top left in image (0,0) 
 -- and colors 0,1,2,3 are used 0 = void, 1=full solid, 2 = 75% solid, 3 = 50% solid
 --file_name     = "font_mini_3x4.lua"
 function_name = "font_mini_3x4"
 xsize = 3
 ysize = 4
 space = 1
 char_first = 32
 char_last  = 95


 f = io.open(file_name, "w");

 d = "function "..function_name.."()\n\n local c\n\n c = {}\n\n c.xsize="..xsize.."\n c.ysize="..ysize.."\n\n"

 --c = string.sub(txt,n,n)
 --asc = string.byte(string.upper(c))
 --string.char(97)

 chars = char_last - char_first 
 for n = 0, chars, 1 do
  ch = char_first+n
  t = "\n\n-- "..string.char(ch).." ("..ch..")\n"
  t = t.."c["..ch.."] = {"

  for y = 0, ysize-1, 1 do   
   t = t.."\n{"
   for x = 0, xsize-1, 1 do
    v = 0
    px = n*(xsize+space) + x
    v = getpicturepixel(px,y)
    t = t..v
    if x<xsize-1 then t=t..","; end
   end
   t = t.."}"
   if y<ysize-1 then t = t..","; end
  end
  t = t.."\n}"

  d = d..t
 end

 d = d.."\n\n return c\n\nend"

 f:write(d)
 f:close()

