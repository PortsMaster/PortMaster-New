--ANIM: Spline Demo V1.2 
--by Richard 'DawnBringer' Fhager

-- (V1.2 Localized, DrawBuffer version)

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_drawbuffer.lua")

--
function main()

 local OK,w,h,n,p,c,fc,bg,p0,p1,p2,p3,aa,hq,c2,f1,f2,points,res,frames,cycle,gamma,dyngam,transp,dyngamma_flag
 local pts0,pts1,pts2,pts3  
 local splinedata, opts, npts, pts, dbuf
 local makePoints, makeNewPoints

w,h = getpicturesize()
fc = getforecolor()
bg = getbackcolor()

points = 5
res = 40
frames = 150
cycle = 0

transp = 1.0
gamma = 1.6 -- Black lines on white bg looks best with gamma=1.6 or less
dyngamma_flag = false

OK, points,frames,res,aa,transp,gamma,dyngam,hq,cycle = inputbox("Spline Demo v1.2", 
                            "Points: 3-1000",            points, 3, 1000, 0,
                            "Frames/Anim: 1-1000",            frames, 1, 1000,0,
                            "Line Resolution: 5-100",   res, 5, 100, 0,
                            "Anti-Aliasing / Dbuf*", 1, 0, 1, 0, 
                            "*Transparency: 0..1",  transp, 0.01, 1,3,
                            "*Gamma (1 = none) or..",   gamma, 0.1, 5,2,
                            "..*Dynamic Gamma", 0, 0, 1, 0,    
                            "*High Quality ColMatch", 0, 0, 1, 0,      
                            "Cycle Colors", 0, 0, 1, 0                                                 
);

if OK then

if dyngam == 1 then dyngamma_flag = true; end

function makePoints(array,points,w,h)
 local n,x,y,mr
 mr = math.random
 for n = 1, points, 1 do
   x = w/2 + mr(-w/2+4,w/2-4)
   y = h/2 + mr(-h/2+4,h/2-4)
   array[n] = {x,y}
 end
end

function makeNewPoints(anew,aold,points,w,h, rnd)
 local n,x,y,mr
 mr = math.random
 for n = 1, points, 1 do
  if mr() >= rnd then -- Chance to keep old points
   x = w/2 + mr(-w/2+4,w/2-4)
   y = h/2 + mr(-h/2+4,h/2-4)
   anew[n] = {x,y}
    else anew[n] = {aold[n][1],aold[n][2]}
  end
 end
end


opts = {}
npts = {}
pts = {}
makePoints(opts,points,w,h)

c,c2 = fc,0
while (1 < 2) do

 makeNewPoints(npts,opts,points,w,h, 0.25) -- Keep old points chance

 for n = 0, frames-1, 1 do

  dbuf = drawb.Init(w,h,gamma, dyngamma_flag)

  f2 = n / frames
  f1 = 1 - f2

  for p = 1, points, 1 do
   pts[p] = {opts[p][1] * f1 + npts[p][1] * f2, opts[p][2] * f1 + npts[p][2] * f2}
  end

  if cycle == 1 and n%10 == 0 then
   c2 = (c2 + 1) % points
  end

 for p = 0, points-1, 1 do
  p0 = 1 + (p-1) % points 
  p1 = 1 + p
  p2 = 1 + (p+1) % points
  p3 = 1 + (p+2) % points   
  c = fc + (c2 + p) % points

  pts0,pts1,pts2,pts3 = pts[p0],pts[p1],pts[p2],pts[p3]

  if aa == 0 then
   db.drawSplineSegment(pts0[1],pts0[2], pts1[1],pts1[2], pts2[1],pts2[2], pts3[1],pts3[2], res, c,  transp, gamma)
  end

  if aa == 1 then
   splinedata = db.makeSplineData(pts0[1],pts0[2], pts1[1],pts1[2], pts2[1],pts2[2], pts3[1],pts3[2], res) 
   --db.drawSplineSegment_Dbuf(dbuf,pts[p0][1],pts[p0][2], pts[p1][1],pts[p1][2], pts[p2][1],pts[p2][2], pts[p3][1],pts[p3][2], res, c,  transp)
   drawb.DrawSplineSegment(dbuf, splinedata, res, c,  transp)
  end
 end


  if hq == 1 then 
   drawb.RenderBufferHQ(dbuf,0.5)
   else
    drawb.RenderBuffer(dbuf)
  end 

  updatescreen();if (waitbreak(0)==1) then return end
  drawb.ReplaceBackground(dbuf)

  if aa == 0 then clearpicture(bg); end
 
end -- frames

  for p = 1, points, 1 do
   opts[p] = npts[p]
  end

end

end

end
-- main

main()