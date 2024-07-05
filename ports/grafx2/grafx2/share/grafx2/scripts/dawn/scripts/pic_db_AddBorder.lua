--PICTURE/BRUSH: Add Border
--by Richard Fhager

-- Image by default
titlePrefix = "Image - "
fget,fput,fsize_set,fsize_get = getbackuppixel, putpicturepixel, setpicturesize, getpicturesize

-- Brush mode set in Toolbox
if preBRU == 1 then
 titlePrefix = "Brush - "
 fget,fput,fsize_set,fsize_get = getbrushbackuppixel, putbrushpixel, setbrushsize, getbrushsize
end


w,h = fsize_get()

top = 1
left = 1
right = 1
bottom = 1


OK,dummy,size,outside,inside,top,bottom,left,right = inputbox(titlePrefix.."Add Border",
 
   "--- Using Pen-color ---",    0,  0,0,4,
   "Size: 1-32", 1,  1,32,0,
   --"Add to Outside",    1,  0,1,0,
   "1. Add to Outside",    1,  0,1,-1,
   "2. Draw Inside",       0,  0,1,-1,

   "Top",    1,  0,1,0,
   "Bottom", 1,  0,1,0,
   "Left",   1,  0,1,0,
   "Right",  1,  0,1,0
                              
);



if OK then

 c = getforecolor()

 if outside == 1 then
  wd = (right+left)*size
  ht = (top+bottom)*size
  fsize_set(w+wd,h+ht)
  for y = 0, h-1, 1 do
   for x = 0, w - 1, 1 do
    fput(x+left*size,y+top*size,fget(x,y))
   end
  end
  w,h = w+wd,h+ht -- New image size
 end


if top == 1 then
 for y = 0, size-1, 1 do
  for x = 0, w - 1, 1 do
   fput(x,y,c)
  end
 end
end

if bottom == 1 then
 for y = 0, size-1, 1 do
  for x = 0, w - 1, 1 do
   fput(x,h-y-1,c)
  end
 end
end


if left == 1 then
 for x = 0, size-1, 1 do
  for y = 0, h - 1, 1 do
   fput(x,y,c)
  end
 end
end


if right == 1 then
 for x = 0, size-1, 1 do
  for y = 0, h - 1, 1 do
   fput(w-x-1,y,c)
  end
 end
end

end -- OK
