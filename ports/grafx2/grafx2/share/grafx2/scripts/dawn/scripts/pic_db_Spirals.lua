--PICTURE: Draw Spirals V2.0
--by Richard 'DawnBringer' Fhager

-- (V2.0 AA, Draw Buffer update)


dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_drawbuffer.lua")

--> db.lineTranspAAgamma(fx,fy,tx,ty, R,G,B, transp, gamma)

w, h = getpicturesize()
c = getforecolor()

rad = math.min(h/2,w/2)
ang = 0
deg = 720
step = 0
pow = 1
arm = 1
transp = 0.5
gamma = 1.8

OK, rad,deg,step,arm,ang,pow,aa,transp,gamma = inputbox("Draw Spirals", 
                            "Radius",            rad, 1, 1000, 0,
                            "Degrees (len/dir)", deg, -36000, 36000,0,
                            "Jump Step (degrees)",step, 0, 359, 2,
                            "Arms",              arm, 1, 1000, 0,
                            "Offset Angle",      ang, -359, 359,  0,
                            "Radial Exponent",   pow, 0.01, 100,2,
                            "Anti-Aliasing *",    1, 0, 1, 0,    
                            "*Transparency: 0..1",  transp, 0.01, 1,3,
                            "*Gamma (1 = none)",   gamma, 0.1, 5,2
                            --"Draw Background col?", 1, 0, 1, 0                          
);

--
if OK then

dbuf = drawb.Init(w,h,gamma)

--drawb.LineAA(dbuf,5,7,5,197,0,0,0,1)


cx = w / 2
cy = h / 2

density = 1 -- point step/density
sstep  = 360 / arm
-- we don't need as many points as degrees, and less counters dark center
-- A smaller radius should have less points otherwise it gets darker/denser
-- rad^0.5/25 will make points decrease somewhat exp. with lesser radius...but right now it counter the more solid centers in small spirals
points = 10 + math.floor(math.abs(deg)*density*rad^0.5/25)
mul    = points / points^pow
dstep  = deg / points
rstep  = rad / points
--rstep = 0.8
conv   = (math.pi * 2) / 360

Sin,Cos,mf = math.sin, math.cos, math.floor



R,G,B = getcolor(c)
for s = 0, arm-1, 1 do

 armv = sstep * s 

 v = ang + dstep * 0 + armv + step*0
 r = rstep * 0^pow * mul
 tx = cx + Sin(v * conv) * r
 ty = cy + Cos(v * conv) * r

ox,oy = tx,ty
for n = 1, points, 1 do

 fx,fy = tx,ty
 if aa==1 then fx,fy = ox,oy; end -- Using ox,oy as start points skip is always 1

 v = ang + dstep * n + armv + step*n 
 r = rstep * n^pow * mul

 tx = cx + Sin(v * conv) * r
 ty = cy + Cos(v * conv) * r

 qw = 1; 
 --if mf(fx)==mf(tx) and mf(fy)==mf(ty) then qw = 0; end -- attempt to counter dark center, works but very patchy look

 if qw == 1 then
 if aa == 1 then
   skip = 1; 
   ox,oy = drawb.LineAA(dbuf,fx,fy,tx,ty,R,G,B,transp,skip)
   putpicturepixel(ox,oy,c) -- Temp. plot, RenderBuffer will replace this
   else
    db.line(mf(fx),mf(fy),mf(tx),mf(ty),c)
 end
 end

 if n%10 == 0 then updatescreen(); if (waitbreak(0)==1) then return; end; end

end

 updatescreen(); if (waitbreak(0)==1) then return; end
end

if aa == 1 then
 statusmessage("Rendering Draw Buffer..."); waitbreak(0)
 drawb.RenderBufferHQ(dbuf,0.5)
end

end -- OK
