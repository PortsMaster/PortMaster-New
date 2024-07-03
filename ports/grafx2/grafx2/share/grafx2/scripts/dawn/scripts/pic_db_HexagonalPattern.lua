--PICTURE: Hexagonal Pattern V1.2
--by Richard Fhager 
--Email: dawnbringer@hem.utfors.se


-- (V1.12 pen-color start col, updating screen)


-- Coordinate based Hexagonal 3 color Pattern by dividing the screen into parallelograms
-- and further splitting these into hexagon sub-triangles.
-- The final color-calculation was derived/simplified through many steps...I have no clue what it does! :D
-- (No concern for offsets etc, yet) 

S = 20	-- Side / Size
startcol = getforecolor()
OK, S,ex,sq,ad,startcol = inputbox("Hexagonal Pattern", 
                            "Side / Size",  S, 4, 100,0,
                            "1. Exact",         1, 0, 1,-1,
                            "2. Square",        0, 0, 1,-1,
                            "3. Approximate",   0, 0, 1,-1, -- used to be called adjusted
                            "Start Col: 0-253", startcol, 0, 253,0
);

if OK == true then
				
R = math.sqrt(3) / 2 				 
H = R * S			-- Height
AY = 1 / math.sqrt(3) 		-- Y adjustment

if sq == 1 then -- Square
 R = 1
 H = R * S
 AY = 1/2
end

if ad == 1 then -- Adjusted to useful proportions, very close to math. exact
 R = 7/8
 H = R * S
 AY = 1/R/2
end



m = math
w, h = getpicturesize()
for y = 0, h - 1, 1 do
  for x = 0, w - 1, 1 do

    -- Cell number (Parallelogram)
    yn = m.floor(y / H)   
    xn = m.floor((x - y*AY) / S)

    -- Rel. pos inside cell
    mx = (x - y*AY) % S
    my = y % H

    -- Celldivision (triangle)
    d = 0; if mx > (S-my/R) then d = 1; end

    -- Horizontal triangle #
    tx = xn*2 + d

    -- Find color of triangle
    c = (yn + (m.floor((tx+yn*4)/3) % 2)) % 3

    putpicturepixel(x, y, startcol+c);

  end
  if y%8==0 then updatescreen();if (waitbreak(0)==1) then return end; end
end


end
