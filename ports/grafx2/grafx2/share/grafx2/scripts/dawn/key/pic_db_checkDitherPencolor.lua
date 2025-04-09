--PICTURE: ** Dither Color w/ PenColor ** 
--Assign script to a key 
--Mousepointer location selects target

--Fill all image occurencies of target color with pencolor checker-dither


moved, key, mx, my, mb, ix, iy = waitinput(0)

w,h = getpicturesize()

TC = getpicturepixel(ix,iy)
FC = getforecolor()

for y = 0, h-1, 1 do
 for x = 0, w-1, 1 do

  if ((x+y) % 2 == 0) then
   if getpicturepixel(x,y) == TC then
     putpicturepixel(x,y,FC)
   end
  end  

 end
 
end

