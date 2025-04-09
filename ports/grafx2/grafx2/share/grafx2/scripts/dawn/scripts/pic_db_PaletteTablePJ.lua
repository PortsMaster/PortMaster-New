--PICTURE: Palette Table with Hex-Values V1.01
--(PJ collab format as default)
--Richard 'DawnBringer' Fhager (Feb 2017)


--
function rgb2HEX(r,g,b,prefix)
  local c,n,s,t,z
  c = {r,g,b}
  z = {"0",""}
  t = ""
  for n = 1, 3, 1 do
  s = string.upper(string.format("%x",c[n]))
  t = t..z[#s]..s
     --s = tonumber(c[n],16)
     --t = t..s
  end
  return prefix..t
end
--

--
function getTextObject()

 local text

text = {}


-- Default Font (4x5)--
--
-- 0 = Void
-- 1 = Solid
-- 2 = Strong AA (becomes solid if no AA)
-- 3 = Light/Medium AA (becomes void if no AA)
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

-- !
c[33] = {
{0,0,1,0},
{0,0,1,0},
{0,0,1,0},
{0,0,0,0},
{0,0,1,0}
}

-- "
c[34] = {
{0,1,0,1},
{0,1,0,1},
{0,0,0,0},
{0,0,0,0},
{0,0,0,0}
}

-- #
c[35] = {
{1,0,1,0},
{1,1,1,1},
{1,0,1,0},
{1,1,1,1},
{1,0,1,0}
}

-- $
c[36] = {
{0,2,0,0},
{0,1,1,0},
{1,2,0,0},
{0,3,1,0},
{1,1,3,0}
}

-- %
c[37] = {
{0,0,0,0},
{1,0,3,1},
{0,3,1,3},
{3,1,3,0},
{1,3,0,1}
}

-- &
c[38] = {
{2,1,3,0},
{1,0,1,0},
{3,1,2,0},
{1,0,2,1},
{2,1,1,3}
}

-- '
c[39] = {
{0,1,0,0},
{0,1,0,0},
{0,0,0,0},
{0,0,0,0},
{0,0,0,0}
}

-- (
c[40] = {
{0,3,1,0},
{0,1,0,0},
{0,1,0,0},
{0,1,0,0},
{0,3,1,0}
}

-- )
c[41] = {
{0,1,3,0},
{0,0,1,0},
{0,0,1,0},
{0,0,1,0},
{0,1,3,0}
}

-- *
c[42] = {
{2,0,0,2},
{0,1,1,0},
{2,1,1,2},
{0,1,1,0},
{2,0,0,2}
}

-- +
c[43] = {
{0,0,0,0},
{0,1,0,0},
{1,1,1,0},
{0,1,0,0},
{0,0,0,0}
}

-- ,
c[44] = {
{0,0,0,0},
{0,0,0,0},
{0,0,0,0},
{0,1,0,0},
{1,3,0,0}
}

-- -
c[45] = {
{0,0,0,0},
{0,0,0,0},
{1,1,1,0},
{0,0,0,0},
{0,0,0,0}
}

-- .
c[46] = {
{0,0,0,0},
{0,0,0,0},
{0,0,0,0},
{0,0,0,0},
{0,1,0,0}
}

-- /
c[47] = {
{0,0,0,1},
{0,0,3,2},
{0,2,2,0},
{2,3,0,0},
{1,0,0,0}
}

-- 0
c[48] = {
{3,1,1,3},
{1,0,0,1},
{1,0,0,1},
{1,0,0,1},
{3,1,1,3}
}

-- 1
c[49] = {
{0,1,0,0},
{2,1,0,0},
{0,1,0,0},
{0,1,0,0},
{1,1,1,0}
}

-- 2
c[50] = {
{1,1,1,3},
{0,0,0,1},
{3,1,1,3},
{1,0,0,0},
{1,1,1,1}
}

-- 3
c[51] = {
{1,1,1,3},
{0,0,0,1},
{0,1,1,3},
{0,0,0,1},
{1,1,1,3}
}

-- 4
c[52] = {
{1,0,0,1},
{1,0,0,1},
{1,1,1,1},
{0,0,0,1},
{0,0,0,1}
}

-- 5
c[53] = {
{1,1,1,1},
{1,0,0,0},
{1,1,1,3},
{0,0,0,1},
{1,1,1,3}
}

-- 6
c[54] = {
{3,1,1,0},
{1,0,0,0},
{1,1,1,3},
{1,0,0,1},
{3,1,1,3}
}

-- 7
c[55] = {
{1,1,1,2},
{0,0,0,1},
{0,0,1,1},
{0,0,0,1},
{0,0,0,1}
}

-- 8
c[56] = {
{3,1,1,3},
{1,0,0,1},
{3,1,1,3},
{1,0,0,1},
{3,1,1,3}
}

-- 9
c[57] = {
{3,1,1,3},
{1,0,0,1},
{3,1,1,1},
{0,0,0,1},
{0,1,1,3}
}

-- :
c[58] = {
{0,0,0,0},
{0,1,0,0},
{0,0,0,0},
{0,1,0,0},
{0,0,0,0}
}

-- ;
c[59] = {
{0,0,0,0},
{0,1,0,0},
{0,0,0,0},
{0,1,0,0},
{2,3,0,0}
}

-- =
c[61] = {
{0,0,0,0},
{0,1,1,1},
{0,0,0,0},
{0,1,1,1},
{0,0,0,0}
}

-- ?
c[63] = {
{1,1,1,3},
{0,0,0,1},
{0,2,1,3},
{0,3,0,0},
{0,1,0,0}
}



-- A
c[65] = {
{3,1,1,3},
{1,0,0,1},
{1,1,1,1},
{1,0,0,1},
{1,0,0,1}
}

-- B
c[66] = {
{1,1,1,3},
{1,0,0,1},
{1,1,1,3},
{1,0,0,1},
{1,1,1,3}
}

-- C
c[67] = {
{3,1,1,1},
{1,0,0,0},
{1,0,0,0},
{1,0,0,0},
{3,1,1,1}
}


-- D
c[68] = {
{1,1,1,3},
{1,0,0,1},
{1,0,0,1},
{1,0,0,1},
{1,1,1,3}
}

-- E
c[69] = {
{2,1,1,1},
{1,0,0,0},
{1,1,1,0},
{1,0,0,0},
{2,1,1,1}
}

-- F
c[70] = {
{2,1,1,1},
{1,0,0,0},
{1,1,1,0},
{1,0,0,0},
{1,0,0,0}
}

-- G
c[71] = {
{3,1,1,1},
{1,0,0,0},
{1,0,1,1},
{1,0,0,1},
{3,1,1,1}
}

-- H
c[72] = {
{1,0,0,1},
{1,0,0,1},
{1,1,1,1},
{1,0,0,1},
{1,0,0,1}
}

-- I
c[73] = {
{1,1,1,0},
{0,1,0,0},
{0,1,0,0},
{0,1,0,0},
{1,1,1,0}
}

-- J
c[74] = {
{1,1,1,1},
{0,0,0,1},
{0,0,0,1},
{1,0,0,1},
{3,1,1,3}
}

-- K
c[75] = {
{1,0,0,1},
{1,0,0,1},
{1,1,1,3},
{1,0,0,1},
{1,0,0,1}
}

-- L
c[76] = {
{1,0,0,0},
{1,0,0,0},
{1,0,0,0},
{1,0,0,0},
{2,1,1,1}
}

-- M
c[77] = {
{1,0,0,1},
{1,1,1,1},
{1,0,0,1},
{1,0,0,1},
{1,0,0,1}
}

-- N
c[78] = {
{1,1,1,3},
{1,0,0,1},
{1,0,0,1},
{1,0,0,1},
{1,0,0,1}
}

-- O
c[79] = {
{3,1,1,3},
{1,0,0,1},
{1,0,0,1},
{1,0,0,1},
{3,1,1,3}
}

-- P
c[80] = {
{1,1,1,3},
{1,0,0,1},
{1,1,1,3},
{1,0,0,0},
{1,0,0,0}
}

-- Q
c[81] = {
{3,1,1,3},
{1,0,0,1},
{1,0,0,1},
{1,0,1,3},
{3,1,3,1}
}

-- R
c[82] = {
{1,1,1,3},
{1,0,0,1},
{1,1,1,3},
{1,0,0,1},
{1,0,0,1}
}

-- S
c[83] = {
{3,1,1,1},
{1,0,0,0},
{3,1,1,3},
{0,0,0,1},
{1,1,1,3}
}

-- T
c[84] = {
{1,1,1,1},
{0,1,0,0},
{0,1,0,0},
{0,1,0,0},
{0,1,0,0}
}

-- U
c[85] = {
{1,0,0,1},
{1,0,0,1},
{1,0,0,1},
{1,0,0,1},
{3,1,1,3}
}

-- V
c[86] = {
{1,0,0,1},
{1,0,0,1},
{1,0,0,1},
{1,0,2,3},
{3,1,3,0}
}

-- W
c[87] = {
{1,0,0,1},
{1,0,0,1},
{1,0,0,1},
{1,1,1,1},
{1,0,0,1}
}

-- X
c[88] = {
{1,0,0,1},
{1,0,0,1},
{3,1,1,3},
{1,0,0,1},
{1,0,0,1}
}

-- Y
c[89] = {
{1,0,0,1},
{1,0,0,1},
{3,1,1,1},
{0,0,0,1},
{1,1,1,3}
}

-- Z
c[90] = {
{1,1,1,1},
{0,0,0,1},
{3,1,1,3},
{1,0,0,0},
{1,1,1,1}
}

return c

end
-- eof default font --



-- 
-- Change the current default font, ex: text.setFont(font_mini_3x4) 
--
function text.setFont(font)
 text.ActiveFontData = font()
 text.xsize = text.ActiveFontData.xsize
 text.ysize = text.ActiveFontData.ysize
end
--

-- Load the library default font
text.setFont(text.font_default)
--


--
-- font_f:  Font data (function), will use built-in font by default or font previously set by text.setFont(), use anything undefined as argument, f.ex. 'f' 
-- txt:     Text
-- xpos,ypos: text screen location
-- hspace,vspace: Letter spacing, horizontal/vertical
-- maxwidth:   Paragraph/Box width (i.e point where ONE MORE word is allowed)
-- col:   RGB colorvalue {r,g,b}
-- transparency: transparency 0..1, 0 = No Transparency
-- linebreak_char: character that will function as linebreak
-- aa_str: AA strength, 1 = Normal/full AA, 0 = No AA,Solid color. For Dark text on bright bg use about 0.5.
-- clear_flag: restore background when overwriting text (true/false). 
--             When doing text+shadow use true for shadow and false for text. 
--             Overwriting old text+shadow requires a restoration of the previous text (an extra leading print with 'true')
-- backup_flag:  use getbackuppixel() to make font act on background as it a was before script was run, 
--               use when animating text, NOT when drawing over content generated previously by the running script
--
function text.write(font_f,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag)
 local n,c,cx,cy,font,lwidth,x,y,asc,v,px,py,r,g,b,transp,tr,r2,g2,b2,pget,gam,rgam
 --if font_f == null then font_f = text.font_default; end
 --font = font_f()

 if font_f == null then 
  font = text.ActiveFontData; -- Default font: text.font_default()
   else
    font = font_f() -- Load "temporary" font
 end

 gam = 1.6
 rgam = 1 / gam
 backup_flag = backup_flag or false
 pget = getpicturepixel; if backup_flag then pget = getbackuppixel; end
 if aa_str == nil then aa_str = 1.0; end
 transp = {1, 1 - 0.25*aa_str, 0.5*aa_str}
 cx,cy,lwidth = xpos, ypos, 0
 for n = 1, #txt, 1 do
  c = string.sub(txt,n,n)
  asc = string.byte(string.upper(c))
  if c ~= linebreak_char then
   if font[asc] == nil then asc = 32; end -- Make it SPACE if char is missing in font
   ---- Draw char ----
   for y = 1, font.ysize, 1 do
    for x = 1, font.xsize, 1 do
     v = font[asc][y][x]
     if v > 0 then
       px, py = cx + x - 1, cy + y - 1
       tr = transp[v] * (1-transparency)
       r,g,b = getcolor(pget(px,py))
       --r2 = col[1]*tr + r*(1-tr)
       --g2 = col[2]*tr + g*(1-tr)
       --b2 = col[3]*tr + b*(1-tr)
       r2 = (col[1]^gam*tr + r^gam*(1-tr))^rgam
       g2 = (col[2]^gam*tr + g^gam*(1-tr))^rgam
       b2 = (col[3]^gam*tr + b^gam*(1-tr))^rgam
      putpicturepixel(px,py, matchcolor(r2,g2,b2))
     end -- v
     if v == 0 and clear_flag then
      px, py = cx + x - 1, cy + y - 1
      putpicturepixel(px,py, pget(px,py))
     end
    end;end -- x,y
     lwidth = lwidth + font.xsize + hspace
     cx = cx + font.xsize + hspace
    ----
   end -- linebreak
     if c == linebreak_char or (lwidth >= maxwidth and asc == 32) then -- Only break on space, not words
      cx, cy, lwidth = xpos, cy + font.ysize + vspace, 0
     end
   end -- n
end
--



-- *************************************
-- ***        Text Formation         ***
-- *************************************

--
-- Format a value into a string with a given number of decimals (zeros)
--
-- Ex: text.AddDecimalZeros(1,   2) --> "1.00"
-- Ex: text.AddDecimalZeros(1.6, 2) --> "1.60"
-- Ex: text.AddDecimalZeros(1.25,2) --> "1.25"
--
function text.AddDecimalZeros(v,decimals)
 local n,txt,m
 txt = ""..v
 if v == math.floor(v) then txt = txt.."."; end
 for n = decimals-1, 0, -1 do
  m = 10^n * v
  if m == math.floor(m) then txt = txt.."0"; end
 end
 return txt
end
--

 return text

end
--


-- Easy Text Interface
function drawText(xpos,ypos,txt,big,rgb) -- dark
 local hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,font_f
--
if big ~= 1 then
 font_f = font_mini_3x4
end
-- font_f:  Font data (function), will use built-in font by default, use anything undefined as argument, f.ex. 'f' 
-- txt:     Text
-- xpos,ypos: text screen location
hspace = 1
vspace = 1            -- Letter spacing, horizontal/vertical
maxwidth = 1000       --   Paragraph/Box width (i.e point where ONE MORE word is allowed)
col = rgb or {0,0,0}   -- RGB colorvalue {r,g,b}
transparency = 0      -- transparency 0..1, 0 = No Transparency
linebreak_char = "|"  -- character that will function as linebreak
aa_str = 0.8            -- AA strength, 1 = Normal/full AA, 0 = No AA,Solid color. For Dark text on bright bg use about 0.5.
clear_flag = false    --  restore background when overwriting text (true/false). 
--             When doing text+shadow use true for shadow and false for text. 
--             Overwriting old text+shadow requires a restoration of the previous text (an extra leading print with 'true')

text.write(font_f,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag)
end

--
function line(x1,y1,x2,y2,c) -- Coords doesn't have to be integers w math.floor in place (Broken lines problem with fractions)
 local n,st,m,xd,yd; m = math
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 xd = (x2-x1) / st
 yd = (y2-y1) / st
 for n = 0, st, 1 do
   putpicturepixel(m.floor(x1 + n*xd), m.floor(y1 + n*yd), c );
 end
end
--


-- Filled Rectangle
function drawRectangle(x1,y1,w,h,c)
   local x,y
   for y = y1, y1+h-1, 1 do
    for x = x1, x1+w-1, 1 do
       putpicturepixel(x,y,c);
    end
   end
end
--

--
function drawRectangleLine(x,y,w,h,c)
 w = w-1
 h = h-1
 line(x,y,x+w,y,c)
 line(x,y,x,y+h,c)
 line(x,y+h,x+w,y+h,c)
 line(x+w,y,x+w,y+h,c)
end
--




-------- Settings -------

colors = 22
rows = 2

-- Overridden by Input
 two_row_mode = true -- PJ mode: Two rows with text above row1 and below row2, center 2nd row if a color less

cell_xsize = 29
cell_ysize = 19

inner_xspace = 3
inner_yspace = 3
outer_xspace = 2
outer_yspace = 2

-- Overridden by Input
 pencols_flag = true -- Get back and text/outline color from Pen-colors

outline_backcol = true -- Outline pal-color if it's the same as template background

-- Overridden by Input 
 text_draw = true
text_ysize = 6 -- Space added for text (i.e Height of font +1)
text_bottom_mode = false    -- Draw text under color-cells instead of above

-------------------------


--
OK,colors,rows,cell_xsize,cell_ysize,Cell_Spacing,Outer_Spacing,Pen_Cols,Text_Draw,PJ_Mode = inputbox("Palette Table w/ Hex-vals",
                        

                           "Colors", colors, 2,256,0,  
                           "Rows", rows, 1,256,0,
                           "Cell Width",  cell_xsize, 1,256,0, 
                           "Cell Height", cell_ysize, 1,256,0,     
                           "Cell Spacing",inner_xspace, 0,32,0,
                           "Frame Space",outer_xspace, 0,32,0,
                           "Back/Text Cols from Pens", 1,0,1,0, 
                           "Draw Text (Hex-values)", 1,0,1,0,            
                           "Two Row Mode (PJ)", 1,0,1,0
                                                                        
);

--
if OK then

 two_row_mode = true; if PJ_Mode == 0 then two_row_mode = false; end
 pencols_flag = true; if Pen_Cols == 0 then pencols_flag = false; end
 text_draw = true; if Text_Draw == 0 then text_draw = false; end
 inner_xspace = Cell_Spacing
 inner_yspace = Cell_Spacing
 outer_xspace = Outer_Spacing
 outer_yspace = Outer_Spacing



-- Derivative Settings

if pencols_flag then
 back_color    = getbackcolor()
 outline_color = getforecolor()
  else
   back_color    = matchcolor(255,255,255)
   outline_color = matchcolor(0,0,0)
end

text_rgb = {getcolor(outline_color)} -- Text col is same as outline (trying to avoid non-palette colors)
text_top = -text_ysize      -- Text offset
text_bot = cell_ysize + 1   -- Text offset bottom row (for two rows only)

if rows > 2 then two_row_mode = false; end

-- Final calculation of spacing values
outer_yspace_top = outer_yspace
outer_yspace_bot = outer_yspace
inner_yspace_final = inner_yspace
if text_draw then

 if text_bottom_mode == false then
  outer_yspace_top = outer_yspace + text_ysize
 end

 if two_row_mode == true or text_bottom_mode == true then
  outer_yspace_bot = outer_yspace + text_ysize
 end

 if two_row_mode == false or text_bottom_mode == true then
  inner_yspace_final = inner_yspace + text_ysize
 end

end
--

anchor_x = outer_xspace
anchor_y = outer_yspace_top

--if text_bottom_mode and text_draw then 
-- anchor_y = outer_yspace_top - text_ysize
--end

max_columns = math.ceil(colors / rows)

last_row_voids = max_columns * rows - colors -- # of cells missing from full table on last row
--messagebox(last_row_voids)

size_x = max_columns * cell_xsize + (max_columns - 1) * inner_xspace + outer_xspace * 2
size_y = rows * cell_ysize + (rows - 1) * inner_yspace_final + (outer_yspace_top + outer_yspace_bot)


--back_color    = matchcolor(back_rgb[1],back_rgb[2],back_rgb[3]) -- {255,255,255}
--outline_color = matchcolor(255-back_rgb[1],255-back_rgb[2],255-back_rgb[3])
--cell_color    = matchcolor(145,157,161)

setpicturesize(size_x, size_y)

drawRectangle(0,0,size_x,size_y,back_color)

text = getTextObject()

col = 0
for row = 0, rows-1, 1 do
 for c = 0, max_columns-1, 1 do

  if col < colors then
  
   -- Center last row if not full (PJ style)
   ofx = 0
   if two_row_mode == true and row == rows-1 then 
    ofx = last_row_voids * (cell_xsize+inner_xspace)/2
   end

   x = anchor_x + (cell_xsize + inner_xspace) * c + ofx
   y = anchor_y + (cell_ysize + inner_yspace_final) * row
 
   drawRectangle(x,y,cell_xsize,cell_ysize, col)
  
   if col == back_color and outline_backcol then
    drawRectangleLine(x,y,cell_xsize,cell_ysize, outline_color)
   end

   if text_draw then
    r,g,b = getcolor(col)
    txt = rgb2HEX(r,g,b,"")
    yoff = text_top; if (two_row_mode and row == 1) or text_bottom_mode then yoff = text_bot ; end
    drawText(x,y + yoff, txt, null, text_rgb)
   end

   col = col + 1
  
  end

 end
end 

end
-- OK

