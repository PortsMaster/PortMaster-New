dofile("../libs/dawnbringer_lib.lua")

--setpicturesize(512,400)



w,h = getpicturesize()

colors = 256
height = h


tresh = 1; -- Treshold dither

for x = 0, w - 1, 1 do
 v = colors/w * x
 c = math.floor(v)
 d=0; if v-c >= 0.5 then d = 1; end
 for y = 0, height - 1, 1 do

    col = c

    if tresh == 1 then
     dith = d*((y+x)%2)
     col = math.min(255,c + dith)
    end

    putpicturepixel(x, y, col);
 end
 if x%8 == 0 then updatescreen();if (waitbreak(0)==1) then return end; end
end

