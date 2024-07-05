--PICTURE: Shuffle/Restore Image V2.5
--by Richard 'DawnBringer' Fhager


dofile("../libs/dawnbringer_lib.lua")


OK, xsize,ysize,shuffle,restore,seed2 = inputbox("Shuffle Image", 
                           "Block X-Size",  16, 1, 512,0,
                           "Block Y-Size",  16, 1, 512,0,
                           "1. Shuffle",       1,  0,1,-1,
                           "2. Restore",       0,  0,1,-1,
                            "Encryption Code",  1979,   1, 9999,0
                            --"Draw Background col?", 1, 0, 1, 0                          
);


if OK then

w, h = getpicturesize()

xtiles = math.floor(w / xsize)
ytiles = math.floor(h / ysize)

statusmessage("Creating Shuffle..."); waitbreak(0)

anchor = {}
n = 0
for y = 0, ytiles-1, 1 do
  for x = 0, xtiles - 1, 1 do
     n = n + 1
     anchor[n] = {x*xsize,y*ysize}
  end
end

db.cshuffle(anchor,3,seed2)
statusmessage("")

 ysize1 = ysize - 1
 xsize1 = xsize - 1

 n = 0
 for y = 0, h-ysize, ysize do
   for x = 0, w-xsize, xsize do
      n = n + 1
       ax = anchor[n][1]
       ay = anchor[n][2]
       for py = 0, ysize1, 1 do
        aypy = ay+py
         ypy = y + py
       for px = 0, xsize1, 1 do
        if shuffle == 1 then
         putpicturepixel(x+px,ypy,getbackuppixel(ax+px,aypy))
        end
        if restore == 1 then
         putpicturepixel(ax+px,aypy,getbackuppixel(x+px,ypy))
        end
       end
       end
   end
   updatescreen(); if (waitbreak(0)==1) then return; end
 end


end -- OK

