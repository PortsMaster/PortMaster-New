--PICTURE: Scanline Variations V1.0
--by Richard 'DawnBringer' Fhager




OK,o1,o2,o3,o4,o5,o6,str,gamma = inputbox("Scanline Variations",
                           "1. Basic        [2]",  0,  0,1,-1, 
                           "2. Full/Medium  [4]",  1,  0,1,-1,  
                           "3. Three Levels [8]",  0,  0,1,-1,
                           "4. Window Blind [3]",  0,  0,1,-1,  
                           "5. Thin Bars    [4]",  0,  0,1,-1,  
                           "6. Thick Bars   [6]",  0,  0,1,-1, 
                           "Strength %: 1-200",    75,  1, 200,0,
                           "Gamma",    2.2,  1.0, 3.0,2
                                                  
);

if OK == true then

if o1 == 1 then
 lines = {1.0, 0} -- Basic
end

if o2 == 1 then
 lines = {0.8, 0, 1.0, 0} -- Alternating Full/Medium
end

if o3 == 1 then
 lines = {0.75, 0, 0.5, 0, 1.0, 0, 0.5, 0} -- 3 Levels
end

if o4 == 1 then
 lines = {1.0, 0.5, 0} -- Window Blind
end

if o5 == 1 then
 lines = {0.6, 1.0, 0.6, 0} -- Thin Bars
end

if o6 == 1 then
 lines = {0, 0.4, 0.8, 1.0, 0.8, 0.4} -- Bars
end

magnitude = (str/100) or 0.75

gamma = gamma or 2.0

--brightness = {}
--for n = 0, 255, 1 do
-- brightness[n+1] = db.getBrightness(getcolor(n))
--end


w, h = getpicturesize()

for y = 0, h - 1, 1 do

  darken = lines[1 + y%(#lines)]

  eff = darken * magnitude

  if darken ~= 0 then
 
   gmult = (1-eff)^(1/gamma) -- ex: 50% reduction means a multiple of 0.7 as 255*0.7=180 is half as bright as 255 

   for x = 0, w - 1, 1 do

     c = getpicturepixel(x,y)
     r,g,b = getcolor(c)
     --bri = brightness[c+1]

     xd = (x+y)%2 * 2

     tr = r * gmult + xd
     tg = g * gmult + xd
     tb = b * gmult + xd

     c = matchcolor2(tr, tg, tb)

     putpicturepixel(x, y, c);

   end

 end

  statusmessage("Done: "..math.floor((y+1)*100/h).."%")
  if y%8 == 0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
end

end -- ok

