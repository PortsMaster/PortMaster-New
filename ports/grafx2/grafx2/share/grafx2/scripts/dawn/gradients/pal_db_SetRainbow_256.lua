-- Rainbow 256 

dofile("../libs/dawnbringer_lib.lua")


-- Should add an interface with brightness control etc.

--
function main()
  
  local cols,step,offset,r,g,b,n,deg,r1,g1,b1

   cols = 256
   step = 360/cols
   offset = 0 -- -120 for blue as start
   r = 255
   g = 80
   b = 80
 
   for n = 0, cols-1, 1 do
    deg = offset + step * n
    r1,g1,b1 = db.shiftHUE(r,g,b,deg) 
    setcolor(n,r1,g1,b1)
   end

  setcolor(0,0,0,0)

end
--

main()