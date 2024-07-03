--BRUSH: Extract Pen-Color

cf = getforecolor()
cb = getbackcolor()

q = {[true] = cf, [false] = cb}  -- same as q = {}; q[true] = cf; q[false] = cb

w, h = getbrushsize()

for y = 0, h - 1, 1 do
  for x = 0, w - 1, 1 do

    putbrushpixel(x, y, q[(getbrushbackuppixel(x,y) == cf)]);

  end
end