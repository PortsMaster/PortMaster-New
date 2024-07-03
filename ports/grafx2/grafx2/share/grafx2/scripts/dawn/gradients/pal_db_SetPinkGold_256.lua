-- Pink-Gold 256  Black-Pink-White-Gold-Black
  
--e = 0
c=math.pow(255,1/128)  
for n = 0, 128, 1 do
 v = n*2 
 d = (v*2+math.pow(c,n))/3

 --q = v*1.2 + e
 --w = math.floor(q)
 --e = q - w

 cos = 0.5+math.cos((128-n)/128*math.pi)*0.5 -- Normal cosinus-curve 1 to 0
 --s = 0.5-math.cos((128-n)/128*math.pi)


-- Rotated cos-curve, fast drop-level-fast drop
if n > 63 then
 s = 1+math.cos((128-(n-64))/128*math.pi)*0.5
end
if n <= 63 then
 s = math.cos((128-(n+63))/128*math.pi)*0.5
end

 setcolor(n,    d*0.3+v*v/160,d,d*1.2)
 --setcolor(256-n,0.8*d^1.2,v*1.1,s^1.5*255) -- d
 setcolor(256-n,0.65*d^1.3,cos^0.75*255,s^1.5*255) -- d

end

--[[
    v = n*8
    d = (v*2+Math.pow(c,n))/3
    col[n]    = dec2HEX([v*1.1,v,d])
    col[64-n] = dec2HEX([d,d*1.1,v])
--]]