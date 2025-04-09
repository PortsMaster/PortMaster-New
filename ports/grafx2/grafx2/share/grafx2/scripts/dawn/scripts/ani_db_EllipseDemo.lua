--ANIM: Ellipse update-demo V2.0
--Demonstrates 'interactive' features.
--by Richard Fhager


--
-- rot: Rotation in degrees
-- stp: Step is # of line segments (more is "better")
-- a & b are axis-radius
function ellipse2(x,y,a,b,stp,rot,col) 
 local n,m=math,rad,al,sa,ca,sb,cb,ox,oy,x1,y1,ast
 m = math; rad = m.pi/180; ast = rad * 360/stp;
 sb = m.sin(-rot * rad); cb = m.cos(-rot * rad)
 for n = 0, stp, 1 do
  ox = x1; oy = y1;
  sa = m.sin(ast*n) * b; ca = m.cos(ast*n) * a
  x1 = x + ca * cb - sa * sb
  y1 = y + ca * sb + sa * cb
  --if (n > 0) then line(ox,oy,x1,y1,col); end
  if (n > 0) then drawline(ox,oy,x1,y1,col); end
 end
end
--

--
function line(x1,y1,x2,y2,c)
 local n,st,m; m = math
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 for n = 0, st, 1 do
   putpicturepixel(m.floor(x1+n*(x2-x1)/st), m.floor(y1+n*(y2-y1)/st), c );
 end
end
--

setpicturesize(300,300)
setcolor(0,96,96,96)
setcolor(1,255,255,128)

setcolor(2,185,185,115)
setcolor(3,155,155,110)
setcolor(4,120,120,100)

r1 = 100
r2 = 50
rt = 0

frames = 100

ort1,ort2,ort3 = 0,0,0

sin = math.sin

while (1 < 2) do

 r1t = 10 + math.random() * 140
 r2t = 10 + math.random() * 140
 rtt = math.random() * 360

for n = 0, frames-1, 1 do
 clearpicture(0)

 f2 = n / frames
 f1 = 1 - f2

 r1a = r1*f1 + r1t*f2
 r2a = r2*f1 + r2t*f2
 rta = rt*f1 + rtt*f2

 p = sin(n/15.9155)*2

 ellipse2(150, 150, r1a*0.40, r2a*0.40, 20, ort3+20*p, 4)
 ellipse2(150, 150, r1a*0.65, r2a*0.65, 25, ort2+16*p, 3)
 ellipse2(150, 150, r1a*0.85, r2a*0.85, 30, ort1+10*p, 2)
 --       x,   y,   r1,  r2,  stp, rot, col
 ellipse2(150, 150, r1a, r2a, 40,  rta, 1)

 ort3 = ort2
 ort2 = ort1
 ort1 = rta

  updatescreen();if (waitbreak(0)==1) then return end

end
 
 r1,r2,rt = r1a,r2a,rta

end
