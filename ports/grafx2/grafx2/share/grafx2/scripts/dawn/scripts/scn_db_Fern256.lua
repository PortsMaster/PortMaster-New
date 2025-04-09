--SCENE: Fractal Fern (Haxxor version) V1.4
--by Richard 'DawnBringer' Fhager

--
function main()

 local OK,Plots,oX,oY,Sc,plots,cols,setpal
 local xd,yd,da
 local m,mf,mr,min
 local x,y,q,v,c,w,h,yq,xn,yn,p1,p2,stp,rplot,cols1

Plots = 1000000
oX = 0.45 
oY = 0.95
Sc = 0.09

OK,plots,cols,setpal = inputbox("Fractal Fern",
                         "Plots", Plots, 1,5000000,0,
                         "Colors", 256, 2,256,0,
                         "Set Gradient Palette", 0, 0,1,0 
               
);


if OK == true then


xd = {{0,0},{0.2,-0.26},{-0.15,0.28},{0.85,0.04}}
yd = {{0,0.165,0},{0.23,0.22,1.6},{0.26,0.24,0.44},{-0.04,0.85,1.6}}
da = {4,4,4,4,4,2,3,3,2,1}

w,h = getpicturesize()

m  = math
mf = m.floor
mr = m.random
min = m.min

cols1 = cols - 1

v = 255 / cols1
stp = m.floor(m.sqrt(cols) / 4)

if setpal == 1 then
 for c = 0, cols-1, 1 do setcolor(c,c*v,c*v,c*v); end
end
 
clearpicture(0)

rplot = mf(m.sqrt(plots))

xn,yn = 0,0
for p1 = 0, rplot, 1 do
 for p2 = 0, rplot, 1 do

  q = da[1+mf(mr()*mr()*10)]
  yq = yd[q]
  x = xn*xd[q][1] + yn*xd[q][2]
  y = xn*yq[1] + yn*yq[2] + yq[3]
  xn,yn = x,y
 
  xp = w*(oX+x*Sc) -- skipping flooring
  yp = h*(oY-y*Sc) 

  putpicturepixel(xp,yp, min(cols1,getpicturepixel(xp,yp) + stp + mr(0,1)) )

 end
 statusmessage("Done: "..mf(100*rplot*(p1+1) / plots).."%")
 updatescreen(); if (waitbreak(0)==1) then return end
end

end -- ok

end -- main

main()