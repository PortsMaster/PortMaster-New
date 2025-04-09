--ANIM: Sprite Animator v0.2 (ping-pong mode added)
--Spare page holds data - Plays on main
--by Richard Fhager 

dofile("../libs/memory.lua")

arg=memory.load({XS=16,YS=16,SPACE=1,FRAMES=8,XOFF=0,YOFF=0,FPS=10,PINGPONG=0})

OK, XS, YS, SPACE, FRAMES, XOFF, YOFF, FPS, PINGPONG = inputbox(".Sprite-Sheet Animator",
  "Sprite X-Size",   arg.XS,    1, 512,0,
  "Sprite Y-Size",   arg.YS,    1, 512,0,
  "Spacing",         arg.SPACE, 0,  32,0,
  "# of Frames",     arg.FRAMES,2, 100,0,
  "X-Offset",        arg.XOFF,  0, 800,0,
  "Y-Offset",        arg.YOFF,  0, 800,0,
  "Play Speed (FPS)",arg.FPS,   1,  60,0,
  "Ping-Pong",      arg.PINGPONG, 0, 1,0
);


if OK == true then

memory.save({XS=XS,YS=YS,SPACE=SPACE,FRAMES=FRAMES,XOFF=XOFF,YOFF=YOFF,FPS=FPS,PINGPONG=PINGPONG})

 MAXPLAYS = 100

 w,h = getpicturesize()
 OX = w / 2 - XS/2
 OY = h / 2 - YS/2
 
 start = 0
  ends = FRAMES - 1
   dir = 1

 for play = 1, MAXPLAYS, 1 do

  for f = start, ends, dir do
   for y = 0, YS-1, 1 do
    for x = 0, XS-1, 1 do
     sx = x + XOFF + f * (XS + SPACE)   
     sy = y + YOFF
     putpicturepixel(OX+x, OY+y, getsparepicturepixel(sx, sy))
    end
   end
   updatescreen(); if (waitbreak(1/FPS)==1) then return; end
  end

  if PINGPONG == 1 then start,ends,dir = ends,start,-dir; end

 end -- plays

end --OK