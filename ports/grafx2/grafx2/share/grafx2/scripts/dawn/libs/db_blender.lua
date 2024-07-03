---------------------------------------------------
---------------------------------------------------
--
--               Blender Library
--              
--                    V1.0
-- 
--                Prefix: blend_.
--
--        by Richard 'DawnBringer' Fhager
--                                   
--        Email: dawnbringer@hem.utfors.se
--               dawnbringer@bahnhof.se
--
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  A set of image blending functions (like Photoshop).
--  Operating with a source color and an application color, producing a combined result.

-- Arguments:
-- rgbo = Image Color [r,g,b]
-- rgba = Application Color [r,g,b]
-- return value: r,g,b

---------------------------------------------------


blend_ = {}


-- Photoshop Suite

function blend_.Overlay(rgbo, rgba) -- Photoshop Overlay, Hard Light if images are swapped.
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  if rgbo[n]/m >  0.5 then rgb[n] = (1 - (1 - 2*(rgbo[n]/m - 0.5)) * (1 - rgba[n]/m)) * 255; end
  if rgbo[n]/m <= 0.5 then rgb[n] = ((2*rgbo[n]/m) * rgba[n]/m) * 255; end
 end
 --if (Target > ½) R = 1 - (1-2x(Target-½)) x (1-Blend)
 --if (Target <= ½) R = (2xTarget) x Blend
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Multiply(rgbo, rgba) -- Photoshop Multiply: rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = (rgbo[n] * rgba[n]) / m  -- R = Target x Blend
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Screen(rgbo, rgba) -- Photoshop Screen: rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = 255 - ((255-rgbo[n]) * (255-rgba[n])) / m  -- R = 1 - (1-Target) x (1-Blend)   
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Darken(rgbo, rgba) -- Photoshop Darken: rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = math.min(rgbo[n],rgba[n])  -- min(a,b)
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Exclusion(rgbo, rgba) -- Photoshop Exclusion: rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = (0.5 - 2 * (rgbo[n]/m-0.5) * (rgba[n]/m-0.5)) * 255  --R = ½-2x(Target-½)x(Blend-½)
 end
 return rgb[1],rgb[2],rgb[3]
end


function blend_.Lighten(rgbo, rgba) -- Photoshop Lighten: rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = math.max(rgbo[n],rgba[n])  -- max(a,b)
 end
 return rgb[1],rgb[2],rgb[3]
end


function blend_.ColorBurn(rgbo, rgba) -- Photoshop ColorBurn: rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = 255 * (1 - ( (1 - rgbo[n]/m) / (math.max(1/m,rgba[n])/m)) )  --  R = 1 - (1-Target) / Blend 
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.ColorDodge(rgbo, rgba) -- Photoshop ColorDodge: rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = 255 * (rgbo[n]/m / math.max(1/m,(1-rgba[n]/m)) )   --  R = Target / (1-Blend)
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.SoftLight(rgbo, rgba) -- Photoshop SoftLight (not 100% correct, but close enough): rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  if rgbo[n]/m >  0.5 then rgb[n] = (2 * rgbo[n]/m * rgba[n]/m + (rgbo[n]/m)^2 * (1 - 2 * rgba[n]/m)) * 255; end
  if rgbo[n]/m <= 0.5 then rgb[n] = ((rgbo[n]/m)^0.5 * (2 * rgba[n]/m - 1) + (2 * rgbo[n]/m) * (1 - rgba[n]/m)) * 255; end
 end
 --(a,b) = 	2 * a * b + a^2 * (1 - 2 * b) (for b < ½)
 --sqrt(a) * (2 * b - 1) + (2 * a) * (1 - b) (else)
 return rgb[1],rgb[2],rgb[3]
end


function blend_.SoftLight2(rgbo, rgba) -- (Not Quite) Photoshop SoftLight: rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  if rgbo[n]/m >  0.5 then rgb[n] = (1 -   (1-rgbo[n]/m)   *   (1-(rgba[n]/m-0.5))       ) * 255; end
  if rgbo[n]/m <= 0.5 then rgb[n] = (rgbo[n]/m) * (rgba[n]/m + 0.5) * 255; end
 end
 --if (Blend > ½) R = 1 - (1-Target) x (1-(Blend-½))
 --if (Blend <= ½) R = Target x (Blend+½)
 return rgb[1],rgb[2],rgb[3]
end
  
function blend_.SoftLight3(rgbo, rgba) -- iPaint SoftLight: rgbo = Image Color, rgba = Application Color
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  if rgbo[n]/m >  0.5 then rgb[n] = rgba[n] + (255 - rgba[n]) * ((rgbo[n] - 127.5) / 127.5) * (0.5 - math.abs(rgba[n]-127.5)/255); end
  if rgbo[n]/m <= 0.5 then rgb[n] = rgba[n] - rgba[n] * ((127.5 -  rgbo[n]) / 127.5) * (0.5 - math.abs(rgba[n]-127.5)/255); end
 end
-- v1 = source, v2 = application
--if ( v1 > 127.5 ){
--  return v2 + (255 - v2) * ((v1 - 127.5) / 127.5) * (0.5 - Math.abs(v2-127.5)/255);
-- }else{
--   return v2 - v2 * ((127.5 -  v1) / 127.5) * (0.5 - Math.abs(v2-127.5)/255);
 return rgb[1],rgb[2],rgb[3]
end


function blend_.Stamp(rgbo, rgba) -- http://www.pegtop.net/delphi/articles/blendmodes/additive.htm
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = rgbo[n] + 2 * rgba[n] - 255   --  R = Target + 2*Blend - 1
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Reflect(rgbo, rgba) 
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = ((rgbo[n]/m)^2 / math.max(1/m,(1-rgba[n]/m))) * 255 -- a^2 / (1-b)
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Glow(rgbo, rgba) 
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = ((rgba[n]/m)^2 / math.max(1/m,(1-rgbo[n]/m)) ) * 255 -- b^2 / (1-a)
 end
 return rgb[1],rgb[2],rgb[3]
end


function blend_.BaseLineFusion(rgbo, rgba) -- mine
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = rgbo[n] + rgba[n] - 127.5   --  R = Target + Blend - 0.5
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Brand(rgbo, rgba) -- mine
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
   rgb[n] = (rgbo[n]/m)^2 / math.max(1/m,(1-rgba[n]/m)^2) * 255 -- a^2 / (1-b)^2
 end
 return rgb[1],rgb[2],rgb[3]
end
   

function blend_.Add(rgbo, rgba) -- Add (Linear Dodge)
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = rgbo[n] + rgba[n] -- a + b
 end
 return rgb[1],rgb[2],rgb[3]
end


function blend_.Divide(rgbo, rgba) -- Divide???
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = ((rgbo[n]/m) / (1-(rgba[n]/m))) * 255 -- a / b
 end
 return rgb[1],rgb[2],rgb[3]
end


function blend_.Difference(rgbo, rgba) -- 
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = math.abs(rgbo[n] - rgba[n]) -- abs(a - b)
 end
 return rgb[1],rgb[2],rgb[3]
end


function blend_.Subtract(rgbo, rgba) -- 
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = rgbo[n] - rgba[n]  -- a - b
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.LinearBurn(rgbo, rgba) -- i.e. Inverted Subtract
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = rgbo[n] + rgba[n] - 255 -- a + b - 1 or (a - (1-b))
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Normal(rgbo, rgba) -- (use 50% amount for average)
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = rgba[n] -- b 
  end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.AverageBright(rgbo, rgba) -- mine, Average with dominance for the brighter colors, order doesn't matter
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = (((rgbo[n]/m)^2 + (rgba[n]/m)^2) / 2)^0.5 * 255 -- sqrt((a^2 + b^2)/2)
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Appliance(rgbo, rgba) -- mine, order doesn't matter
 local n,rgb,m,v; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  v = ((rgbo[n]/m)^2 + (rgba[n]/m)^2)^0.5 * 255 -- sqrt(a^2 + b^2) - sqrt(min(a,b))
  rgb[n] = v - (math.min(rgbo[n],rgba[n]))^0.5
 end
 return rgb[1],rgb[2],rgb[3]
end

     
function blend_.Dominance(rgbo, rgba) -- mine, Average with dominance for contrasting & saturated colors, order doesn't matter
 local n,rgb,m,so,sa,sfo; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  so = (rgbo[n]/m - 0.5)^2 * 1000
  sa = (rgba[n]/m - 0.5)^2 * 1000
  sfo = so / math.max(1,(so+sa))
  rgb[n] = rgbo[n]*sfo + rgba[n]*(1-sfo) 
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Submission(rgbo, rgba)
-- mine, Average with submission for contrasting & saturated colors, order doesn't matter
-- Quite close to Exclusion
 local n,rgb,m,so,sa,sfo; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  so = ((1 - math.abs(rgbo[n]/m - 0.5)) * m)^2
  sa = ((1 - math.abs(rgba[n]/m - 0.5)) * m)^2
  sfo = so / (so+sa) 
  rgb[n] = rgbo[n]*sfo + rgba[n]*(1-sfo) 
 end
 return rgb[1],rgb[2],rgb[3]
end


function blend_.Multinvert(rgbo, rgba) -- Similar to AverageBright but more distinct
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = (1 - math.sqrt((1 - rgbo[n]/m) * (1 - rgba[n]/m))) * 255 
  end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.MultiplyRoot(rgbo, rgba) --
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = math.sqrt(rgbo[n]/m * rgba[n]/m) * 255 -- sqrt(a*b)
  end
 return rgb[1],rgb[2],rgb[3]
end
 

function blend_.NegShade(rgbo, rgba) -- mine, Dark colors get negative, order doesn't matter, Quite close to "Difference"
 local n,rgb,m; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  rgb[n] = (((rgbo[n]/m - 0.5)^2 + (rgba[n]/m - 0.5)^2))^0.5 * 255 -- sqrt(((a-0.5)^2 + (b-0.5)^2)/2)
 end
 return rgb[1],rgb[2],rgb[3]
end


function blend_.Chromatic(rgbo, rgba) -- mine, Negshade x 2
 local n,rgb,m,c; rgb,m = {}, 255 
 for n = 1, 3, 1 do
  c = (((rgbo[n]/m - 0.5)^2 + (rgba[n]/m - 0.5)^2))^0.5 * 1.4142 * 255 -- sqrt(((a-0.5)^2 + (b-0.5)^2)/2)
  rgb[n] = ((((c/m - 0.5)^2 + (rgba[n]/m - 0.5)^2))^0.5 * 1.4142) * 255 
 end
 return rgb[1],rgb[2],rgb[3]
end

function blend_.StrongColor(rgbo, rgba) -- Self-appliance = Higher Saturation
 local n,rgb,m; rgb,m = {}, 255 

  r1,g1,b1 = rgbo[1], rgbo[2], rgbo[3]
  r2,g2,b2 = rgba[1], rgba[2], rgba[3]

  rgb[1] = r1 + r2-(g2+b2)/2
  rgb[2] = g1 + g2-(r2+b2)/2
  rgb[3] = b1 + b2-(r2+g2)/2
 
 return rgb[1],rgb[2],rgb[3]
end

function blend_.Ghost(rgbo, rgba) -- Self-appliance = Higher contrast & lower Sat
 local n,rgb,m; rgb,m = {}, 255 

  r1,g1,b1 = rgbo[1], rgbo[2], rgbo[3]
  r2,g2,b2 = rgba[1], rgba[2], rgba[3]

  rgb[1] = r1/2 + (r1/m * r2/m * ((g2+b2)/2)/m)*255
  rgb[2] = g1/2 + (g1/m * g2/m * ((r2+b2)/2)/m)*255
  rgb[3] = b1/2 + (b1/m * b2/m * ((r2+g2)/2)/m)*255

  return rgb[1],rgb[2],rgb[3]
end

