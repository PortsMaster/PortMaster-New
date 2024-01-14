function rectangleDetect(px, py, ox, oy, dx, dy)
  return (px > ox and px < ox + dx and py > oy and py < oy + dy)
end

function circleDetect(px, py, ox, oy, r)
  local dist = (px - ox)^2 + (py - oy)^2
  return dist <= (15 + r)^2
end
