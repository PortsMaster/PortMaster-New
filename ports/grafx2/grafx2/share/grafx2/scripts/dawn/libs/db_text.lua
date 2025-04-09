---------------------------------------------------
---------------------------------------------------
--
--                Text Library
--              
--                    V1.2
-- 
--                Prefix: text.
--
--        by Richard 'DawnBringer' Fhager
--                                   
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  Function(s) for drawing (data-defined) text in an image

---------------------------------------------------

-- Shorthand:

-- Quick & simple text usage with default 4x5 font: (linebreak char is: "|")
-- text.white(xpos, ypos, text) 
-- text.black(xpos, ypos, text)  

-- text.setFont([font function]): Change Current font function. 
--                                Must first have loaded the font, ex: dofile("../ffonts/font_mini_3x4.lua")
--                                Then use: text.setFont(font_mini_3x4)
-- text.xsize: (get) Width  of currently loaded font, not including spacing
-- text.ysize: (get) Height of currently loaded font, not including spacing


-- Text Features:
-- * AA-fonts (variable strength)
-- * Adjustable Transparency (Gamma corrected)
-- * Custom Spacing
-- * Background Management

-- Formatting:
-- text.AddDecimalZeros(v,decimals): Format a value into a string with a given number of decimals, ex: text.AddDecimalZeros(1.6, 2) --> "1.60"

---------------------------------------------------


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
{1,0,0,1},
{0,0,1,3},
{3,1,0,0},
{1,0,0,1}
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
{0,0,1,0},
{0,2,1,0},
{0,0,1,0},
{0,0,1,0},
{0,1,1,1}
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


-- <
c[60] = {
{0,0,1,1},
{0,1,3,0},
{1,3,0,0},
{0,1,3,0},
{0,0,1,1}
}


-- =
c[61] = {
{0,0,0,0},
{0,1,1,1},
{0,0,0,0},
{0,1,1,1},
{0,0,0,0}
}

-- >
c[62] = {
{1,1,0,0},
{0,3,1,0},
{0,0,3,1},
{0,3,1,0},
{1,1,0,0}
}


-- ?
c[63] = {
{1,1,1,3},
{0,0,0,1},
{0,2,1,3},
{0,3,0,0},
{0,1,0,0}
}

-- @
c[64] = {
{3,2,2,3},
{2,0,0,2},
{2,0,2,2},
{2,0,0,0},
{3,2,2,3}
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

-- [ (91)
c[91] = {
{0,1,2,0},
{0,1,0,0},
{0,1,0,0},
{0,1,0,0},
{0,1,2,0}
}

-- \ (92)
c[92] = {
{1,0,0,0},
{2,3,0,0},
{0,2,2,0},
{0,0,3,2},
{0,0,0,1}
}


-- ] (93)
c[93] = {
{0,2,1,0},
{0,0,1,0},
{0,0,1,0},
{0,0,1,0},
{0,2,1,0}
}

-- _ (94)
c[94] = {
{0,1,1,0},
{1,0,0,1},
{0,0,0,0},
{0,0,0,0},
{0,0,0,0}
}


-- _ (95)
c[95] = {
{0,0,0,0},
{0,0,0,0},
{0,0,0,0},
{0,0,0,0},
{1,1,1,1}
}


--[[
-- x (120)
c[120] = {
{0,0,0,0},
{1,0,0,1},
{3,1,1,3},
{1,0,0,1},
{0,0,0,0}
}
--]]

-- { (123)
c[123] = {
{0,2,1,0},
{0,1,0,0},
{1,2,0,0},
{0,1,0,0},
{0,2,1,0}
}

-- } (125)
c[125] = {
{0,1,2,0},
{0,0,1,0},
{0,0,2,1},
{0,0,1,0},
{0,1,2,0}
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
-- clear_flag: draw background when (over)writing text (true/false). Only has a function when used WITH [backup_flag=true] and not [void_col]

--             ((decrep?:When doing text+shadow use true for shadow and false for text. 
--             Overwriting old text+shadow requires a restoration of the previous text (an extra leading print with 'true')

-- backup_flag:  use getbackuppixel() to make font act on background as it a was before script was run,)) 
--               use when animating text, NOT when drawing over content generated previously by the running script
--
-- void_col: Solid background of this palette index (0-255), Overrides clear_flag & backup_flag, -1 = inactive 
--
function text.write(font_f,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag, void_col)
 local n,c,cx,cy,font,lwidth,x,y,asc,v,px,py,r,g,b,transp,tr
 local r2,g2,b2,pget,gam,rgam,bg,chy,ch,vr,vg,vb,void_mode
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
 void_col = void_col or -1

 pget = getpicturepixel; if backup_flag then pget = getbackuppixel; end

 void_mode = false
 if void_col > -1 then -- Always clear text areas with void color
  vr,vg,vb = getcolor(void_col)
  void_mode = true
 end

 if aa_str == nil then aa_str = 1.0; end
 transp = {1, 1 - 0.275*aa_str, 0.5*aa_str}
 cx,cy,lwidth = xpos, ypos, 0
 for n = 1, #txt, 1 do
  c = string.sub(txt,n,n)

  asc = string.byte(c)

  if font[asc] == nil then -- In case lower case char doesn't exist, make it upper
   asc = string.byte(string.upper(c))
  end

  if c ~= linebreak_char then
   if font[asc] == nil then asc = 32; end -- Make it SPACE if char is missing in font
   ---- Draw char ----
   ch = font[asc]
   for y = 1, font.ysize, 1 do
    chy = ch[y]
    for x = 1, font.xsize, 1 do
     v = chy[x]
     if v > 0 then
       px, py = cx + x - 1, cy + y - 1
       tr = transp[v] * (1-transparency)
       if void_mode then
        r,g,b = vr,vg,vb
         else
          r,g,b = getcolor(pget(px,py))
       end
       r2 = (col[1]^gam*tr + r^gam*(1-tr))^rgam
       g2 = (col[2]^gam*tr + g^gam*(1-tr))^rgam
       b2 = (col[3]^gam*tr + b^gam*(1-tr))^rgam
       putpicturepixel(px,py, matchcolor2(r2,g2,b2))
     end -- v

     if v == 0 then 
       
       if void_col == -1 and (clear_flag and backup_flag) then -- Doesn't actually change/do anything with just clear_flag and no backup_flag!?
         px, py = cx + x - 1, cy + y - 1 
         putpicturepixel(px,py, pget(px,py))
       end

       if void_col > -1 then
         px, py = cx + x - 1, cy + y - 1 
         putpicturepixel(px,py, void_col)
       end
     
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


-- Easy Text Interface, White text
function text.white(xpos,ypos,txt)
 local hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag
 hspace = 1
 vspace = 2            -- Letter spacing, horizontal/vertical
 maxwidth = 1000       --   Paragraph/Box width (i.e point where ONE MORE word is allowed)
 col = {255,255,255}   -- RGB colorvalue {r,g,b}
 transparency = 0      -- transparency 0..1, 0 = No Transparency
 linebreak_char = "|"  -- character that will function as linebreak
 aa_str = 1           -- AA strength, 1 = Normal/full AA, 0 = No AA,Solid color. For Dark text on bright bg use about 0.5.
 clear_flag = false    
 backup_flag = false
 void_col = -1
 -- f_font may be defined/loaded in memory, if null then default font is used
 text.write(f_font,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag, void_col)
end
--

-- Easy Text Interface, Black text
function text.black(xpos,ypos,txt)
 local hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag
 hspace = 1
 vspace = 2            -- Letter spacing, horizontal/vertical
 maxwidth = 1000       --   Paragraph/Box width (i.e point where ONE MORE word is allowed)
 col = {0,0,0}   -- RGB colorvalue {r,g,b}
 transparency = 0      -- transparency 0..1, 0 = No Transparency
 linebreak_char = "|"  -- character that will function as linebreak
 aa_str = 1           -- AA strength, 1 = Normal/full AA, 0 = No AA,Solid color. For Dark text on bright bg use about 0.5.
 clear_flag = false    
 backup_flag = false
 void_col = -1
 -- f_font may be defined/loaded in memory, if null then default font is used
 text.write(f_font,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag, void_col)
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