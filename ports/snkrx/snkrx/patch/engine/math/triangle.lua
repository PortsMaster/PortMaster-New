-- An isosceles triangle class. This is a triangle with size w, h centered on x, y pointed to the right (angle 0).
-- Implements every function that Polygon does.
Triangle = Object:extend()
Triangle:implement(Polygon)
function Triangle:init(x, y, w, h)
  self.x, self.y, self.w, self.h = x, y, w, h
  local h_div = h/2
  local w_div = w/2
  local x1, y1 = x + h_div, y
  local x2, y2 = x_sub, y - w_div
  local x3, y3 = x_sub, y + w_div
  self.vertices = {x1, y1, x2, y2, x3, y3}
  self:get_size()
  self:get_bounds()
  self:get_centroid()
end


-- An equilateral triangle class. This is a tringle with size w centered on x, y pointed to the right (angle 0).
-- Implements every function that Polygon does.
EquilateralTriangle = Object:extend()
EquilateralTriangle:implement(Polygon)
function EquilateralTriangle:init(x, y, w)
  self.x, self.y, self.w = x, y, w
  local w_div = w/2
  local h = math.sqrt(w * w - w_div * w_div)
  local h_div = h / 2
  local x1, y1 = x + h_div, y
  local x_sub = x - h_div
  local x2, y2 = x_sub, y - w_div
  local x3, y3 = x_sub, y + w_div
  self.vertices = {x1, y1, x2, y2, x3, y3}
  self:get_size()
  self:get_bounds()
  self:get_centroid()
end
