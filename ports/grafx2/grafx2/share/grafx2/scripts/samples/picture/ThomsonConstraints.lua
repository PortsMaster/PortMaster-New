-- Thomson Constraints checker
-- Check wether picture is compatible with Thomson computers video modes
-- (8x1 cells with 2 colors out of 16 in each cell)

w,h=getpicturesize()
xcell = 8

selectlayer(1)
clearpicture(0)
selectlayer(0)
-- foreach grid cell
for y=0,h-1,1 do
for x1=0,w-1,xcell do
	-- initialize our two colors for the cell, c1 is the color of the first
	-- pixel, and we will look for c2 in the following pixels
	c1 = getpicturepixel(x1,y)
	c2 = -1
	for x2=0,xcell-1,1 do
		c = getpicturepixel(x1+x2, y)
		-- is it a new color ?
		if c ~= c1 and c ~= c2 then
			if c2 == -1 then
				-- C2 is free, we can use it for this new color
				c2 = c
			else
				-- out of colors !
				selectlayer(1)
				putpicturepixel(x1+x2,y,17);
				selectlayer(0)
			end
		end
	end
end
end
