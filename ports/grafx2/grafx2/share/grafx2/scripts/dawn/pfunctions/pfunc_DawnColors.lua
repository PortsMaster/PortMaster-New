---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--  DawnColors V1.3
--
--  Program-Function (pfunc) - Dependencies: dawnbringer_lib.lua
--
--  by Richard 'DawnBringer' Fhager (dawnbringer@hem.utfors.se)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--
-- A basic attempt to describe colors
--
-- 
-- Usage:
-- dofile("pfunc_DawnColors.lua")(r,g,b)
-- or
-- myfunc = dofile("pfunc_DawnColors.lua"); myfunc(r,g,b)
--
--
-- History:
-- (V1.3 Now a program function, Saturation model is Purity)
-- (Library V1.2 Saturation model Purity replacing 'Apparent')
-- (Library V1.1 Replaced brightest Crimson with Pink (184,94,188 just didn't look like Crimson))
---------------------------------------------------------------------------------------

dofile("../libs/dawnbringer_lib.lua") 


return function(r,g,b)

 local RD,oR,OR,AM,YL,LI,CH,sG,GR,bG,SP,TQ,CY,bC,AZ,gB,BL,IN,VI,PU,MA,FU,RO,CR,PI,BR,OL,BG,UM,Cr
 local descript, hue, lig, sat, cH, cL, col, name, pre_l, pre_s, prefix
 local CSPEC, LSAT, GRY

-- ID, adjL, adjS, Name
RD = {1,  0,0, "RED"}
oR = {2,  0,0, "ORANGE-RED"}
OR = {3,  0,0, "ORANGE"}
AM = {4,  0,0, "AMBER"}
YL = {5,  0,0, "YELLOW"}
LI = {6,  0,0, "LIME"}
CH = {7,  0,0, "Chartreuse"}
sG = {8,  0,0, "SAP-GREEN"}
GR = {9,  0,0, "GREEN"}
bG = {10, 0,0, "BLUISH-GREEN"}
SP = {11, 0,0, "SPRING-GREEN"}
TQ = {12, 0,0, "TURQUOISE"}
CY = {13, 0,0, "CYAN"}
bC = {14, 0,0, "BLUISH-CYAN"}
AZ = {15, 0,0, "AZURE"}
gB = {16, 0,0, "GREENISH-BLUE"}
BL = {17, 0,0, "BLUE"}
IN = {18, 0,0, "INDIGO"}
VI = {19, 0,0, "VIOLET"}
PU = {20, 0,0, "PURPLE"}
MA = {21, 0,0, "MAGENTA"}
FU = {22, 0,0, "FUCHSIA"}
RO = {23, 0,0, "ROSE"}
CR = {24, 0,0, "CRIMSON"}

PI = {25, -1.5,  0, "PINK"}
BR = {26,  0.75, 0, "BROWN"}
OL = {27,  0.75, 0, "OLIVE"}
BG = {28, -1.5,  0, "BEIGE"}
UM = {29,  0.75, 0, "ULTRAMARINE"}
Cr = {30, -2,    0, "CREAM"}

CSPEC = {
{PI,PI,BG,BG,BG,Cr,YL,LI,CH,CH,sG,GR,GR,bG,SP,SP,TQ,CY,CY,bC,AZ,AZ,gB,BL,BL,IN,VI,VI,PU,MA,MA,FU,RO,PI,PI,PI},  
{PI,oR,OR,OR,BG,YL,YL,LI,CH,CH,sG,GR,GR,bG,SP,SP,TQ,CY,CY,bC,AZ,AZ,gB,BL,BL,IN,VI,VI,PU,MA,MA,FU,RO,RO,PI,PI}, 
{RD,oR,OR,OR,AM,YL,YL,LI,CH,CH,sG,GR,GR,bG,SP,SP,TQ,CY,CY,bC,AZ,AZ,gB,BL,BL,IN,VI,VI,PU,MA,MA,FU,RO,RO,PI,RD}, 
{RD,oR,OR,OR,AM,YL,YL,LI,CH,CH,sG,GR,GR,bG,SP,SP,TQ,CY,CY,bC,AZ,AZ,gB,BL,BL,IN,VI,VI,PU,MA,MA,FU,RO,RO,CR,RD}, 
{RD,BR,BR,BR,AM,OL,OL,OL,OL,CH,sG,GR,GR,bG,SP,SP,TQ,CY,CY,bC,AZ,AZ,gB,BL,UM,IN,VI,VI,PU,MA,MA,FU,RO,RO,CR,RD}, 
{BR,BR,BR,BR,BR,OL,OL,OL,OL,CH,sG,GR,GR,bG,SP,SP,TQ,CY,CY,bC,AZ,AZ,gB,BL,BL,IN,VI,VI,PU,MA,MA,FU,RO,RO,CR,RD} 
}

LSAT = {
{"WHITISH",      "VERY PALE", "VERY LIGHT",  "BRIGHT",      "V. BRILLIANT"},
{"WASHED",       "PALE",      "LIGHT",       "TINTED",      "BRILLIANT"},
{"GRAYISH",      "FADED",     "MEDIUM",      "STRONG",      "VIVID"},
{"DARK GRAYISH", "VERY DULL", "DULL",        "SHADED",      "DEEP VIVID"},
{"VERY DARK",    "DARK",      "VERY SHADED", "DEEP",        "VERY DEEP"}
}



GRY = {"BLACK", "VERY DARK", "DARK", "MEDIUM", "MEDIUM", "MEDIUM", "BRIGHT", "VERY BRIGHT", "WHITE"}


--hue = 335
--lig = 208
--sat = 200


descript = ""

hue = db.getHUE(r,g,b, 0.0078125 * 3) * 60 -- 390 is grayscale
lig = db.getLightness(r,g,b) 
--lig = math.max(r,g,b) -- value
--lig = (r+g+b)/3
 --satTRU = db.getTrueSaturation(r,g,b)
 --satHSL = db.getSaturation(r,g,b)
 --sat = (satTRU + satHSL) / 2 -- a mix
--sat = db.getAppSaturation(r,g,b)
sat = db.getPurity_255(r,g,b)
--messagebox(hue.." "..lig.." "..sat)

--int = math.max(r,g,b)

if hue ~= 390 then -- Don't do grayscales

 cH = 1 + math.floor( hue / 360 * 36 ) -- HUE
 cL = 6 - math.floor( lig / 256 * 6  ) -- LIGHTNESS (HSL) 

 col = CSPEC[cL][cH] 
 name = col[4]

 pre_l = 5 - math.max(0,math.floor( lig /  51.1 + col[2] ))
 pre_s = 1 + math.floor( sat / 51.1 + col[3])

 --messagebox(pre_l.." "..pre_s)

 prefix = LSAT[pre_l][pre_s]

 descript = prefix.." "..name

end


if hue == 390 then -- "Grayscales"
 descript = GRY[1 + math.floor(lig / 28.4)] .." GREY"
end


return descript

end 
--

