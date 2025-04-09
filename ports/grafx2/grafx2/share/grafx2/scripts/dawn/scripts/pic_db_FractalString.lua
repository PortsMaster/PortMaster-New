--PICTURE: Fractal Strings V1.1
--by Richard Fhager


dofile("../libs/dawnbringer_lib.lua")

w,h = getpicturesize()
c = getforecolor()


function split(array,a1,r1,a2,r2,rndmult,rndexp,limit,iter)
 local a,r,mr,var,mf

 if iter < limit then
  a = math.floor(a1 + a2)/2
  mr = (r1 + r2)
  var = math.floor(mr*rndmult / (1+iter^rndexp)) -- 2^iter (1+iter^rndexp)
  r = math.max(0, mr / 2 + math.random()*var*2 - var) 
  split(array,a,r,a1,r1,rndmult,rndexp,limit,iter+1)
  split(array,a,r,a2,r2,rndmult,rndexp,limit,iter+1)
 end
 
 array[a1+1] = r1

end
--

rndmult = 1.3
rndexp  = 1.1 -- Fall off
rad1 = math.min(w/5,h/5)
rad2 = math.min(w/5,h/5)
iter = 10
spline = 1

OK, rad1,rad2,iter,rndmult,rndexp,spline = inputbox("Draw Fractal String", 
                            "Inital Radius 1",            rad1, 1, 1000, 0,
                            "Inital Radius 2",            rad2, 1, 1000,0,
                            "Iterations",          iter, 1, 20, 0,
                            "RND Multiple",        rndmult, 0, 10,  3,
                            "RND Exp (fall off)",  rndexp,  0, 10,  3,
                            "Spline Interpolation", spline, 0, 1, 0    
                            --"Transparency (0..1)",  transp, 0.01, 1,3
                            --"Draw Background col?", 1, 0, 1, 0                          
);


--
if OK then

string = {}
split(string,0,rad1,3599,rad2,rndmult,rndexp,iter,0) -- Entry point

conv = math.pi / 180
cx = w / 2
cy = h / 2

pts = {}
pos = 1
for n = 0, 3599, 1 do
 if string[n+1] ~= null then
  r = string[n+1]
  fx = tx
  fy = ty
  tx = math.floor(cx + math.sin(n/10 * conv) * r)
  ty = math.floor(cy + math.cos(n/10 * conv) * r)
  pts[pos] = {tx,ty}
  pos = pos + 1
 end
end

fx,fy = pts[1][1],pts[1][2]

for n = 0, #pts-1, 1 do
 p0 = 1 + (n-1) % #pts 
 p1 = 1 + n
 p2 = 1 + (n+1) % #pts
 p3 = 1 + (n+2) % #pts  
 if spline == 1 then 
  db.drawSplineSegment(pts[p0][1],pts[p0][2], pts[p1][1],pts[p1][2], pts[p2][1],pts[p2][2], pts[p3][1],pts[p3][2], 50, c)
   else
    tx,ty = pts[n+1][1],pts[n+1][2]
    db.line(fx,fy,tx,ty,c)
    fx,fy = tx,ty
 end
end
if spline ~= 1 then
 db.line(tx,ty,pts[1][1],pts[1][2],c)
end


 --updatescreen(); if (waitbreak(0)==1) then return; end

end -- OK
