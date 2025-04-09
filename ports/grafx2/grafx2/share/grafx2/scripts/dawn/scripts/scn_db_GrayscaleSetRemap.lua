--SCENE: Set Grayscale and Remap
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")

-- This is (as far as I've tested) eq. to my Make Grayscale script.
db.setGrayscaleAndRemap()

--[[
for c = 0, 255, 1 do
 setcolor(c,c,c,c) 
end
db.paletteRemap(1.0) -- Remap with 100% briweight
--]]



