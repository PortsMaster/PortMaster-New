-- Gold-Blue 256 (v2.0 more gold/red)
  
--e = 0
c=math.pow(255,1/128)  
for n = 0, 128, 1 do
 v = n*2 
 d = (v*2+math.pow(c,n))/3

 --q = v*1.2 + e
 --w = math.floor(q)
 --e = q - w

 setcolor(n,    v*1.2,v,d)
 setcolor(256-n,d,d*1.1,v)
end

--[[
    v = n*8
    d = (v*2+Math.pow(c,n))/3
    col[n]    = dec2HEX([v*1.1,v,d])
    col[64-n] = dec2HEX([d,d*1.1,v])
--]]