-- Mystery 256, Black-Blue-White-Green-Black-Brown-White-Purple-Black
  
c=math.pow(255,1/64)  
for n = 0, 64, 1 do
 v = n*4 
 d = (v*2+math.pow(c,n))/3
 setcolor(n,d,d*1.17,v)
 setcolor(128-n,d*1.09,v,d*1.1)
end


c=math.pow(255,1/64)
for n = 0, 64, 1 do
 v = n*4
 d = (v*2+math.pow(c,n))/3
 setcolor(128+n,v*0.97,d*1.15*0.97,d*0.97)
 setcolor(256-n,d*1.15,d*1.02,v)
end
