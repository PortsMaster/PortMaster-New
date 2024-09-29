--BRUSH: Crop Margins
--by Richard 'DawnBringer' Fhager 


t = ""


w,h = getbrushsize()

bg = getbackcolor()

ml,mr,mu,md = 99e9,0,99e9,0

 for y = 0, h-1, 1 do
 for x = 0, w-1, 1 do
   
  c = getbrushpixel(x,y)

 -- Find margins
 if c ~= bg then
  if x<ml then ml = x; end
  if x>mr then mr = x; end
  if y<mu then mu = y; end
  if y>md then md = y; end
 end

 end
 end

 -- If brush is just background color, the margins is all there is...
 -- ... then just set a 1x1 brush

 xsn = math.max(1,mr-ml+1)
 ysn = math.max(1,md-mu+1)

  setbrushsize(xsn, ysn)

  for y = mu, h-1, 1 do
  for x = ml, w-1, 1 do
   putbrushpixel(x-ml,y-mu,getbrushbackuppixel(x,y))
  end
  end






