--PICTURE: Text Library Tutorial (Basic)
--by Richard 'DawnBringer' Fhager

dofile("../libs/db_text.lua") 

setpicturesize(480,320)

c = matchcolor(128,128,128)
clearpicture(c)

t = "Let's load the text-library --> dofile('../libs/db_text.lua')"
text.black(16, 16, t)  

t = "The default font is 4x5 pixels and all caps"
text.white(16, 32, t)  

tw = "This is text written using the quick text command --> text.white"
tb = "This is text written using the quick text command --> text.black"

text.white(16, 56, tw) 
text.black(16, 72, tb)  


-- Let's change font (3x4)

t = "Let's load another font:| --> dofile('../ffonts/font_mini_3x4.lua')"
text.white(16, 96, t) 

dofile("../ffonts/font_mini_3x4.lua")

t = "...And activating it by:| --> text.setFont(font_mini_3x4)"
text.white(16, 128, t) 

text.setFont(font_mini_3x4)

text.white(16, 160, tw) 
text.black(16, 176, tb)  


-- Let's change the font back to the default 4x5

t = "Let's get the default font back:| --> text.setFont(text.font_default)"
text.white(16, 200, t) 

text.setFont(text.font_default)

t = "Alright, we changed the font back to the default 4x5!"
text.black(16, 232, t) 

t = "We can also use text.white over text.black to create a dropshadow..."
text.black(17, 257, t) 
text.white(16, 256, t) 

t = "(This script is: scripts/pic_db_TextTutorial.lua)"
text.black(16, 288, t) 



--[[
-- Print all chars
s = ""
for n = 32, 125, 1 do
 s = s..string.char(n)
end
text.white(16, 16, s) 
text.white(16, 272, s) 
--]]