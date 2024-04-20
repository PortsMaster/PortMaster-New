-- A rectangle class.
-- Implements every function that Polygon does.
Rectangle = Object:extend()
Rectangle:implement(Polygon)
function Rectangle:init(x, y, w, h, r)
  self.x, self.y, self.w, self.h, self.r = x, y, w, h, r
  local w_div = w/2
  local h_div = h/2
  local x1, y1 = math.rotate_point(x - w_div, y - h_div, r or 0, x, y)
  local x2, y2 = math.rotate_point(x + w_div, y - h_div, r or 0, x, y)
  local x3, y3 = math.rotate_point(x + w_div, y + h_div, r or 0, x, y)
  local x4, y4 = math.rotate_point(x - w_div, y + h_div, r or 0, x, y)
  self.vertices = {x1, y1, x2, y2, x3, y3, x4, y4}
  self:get_size()
  self:get_bounds()
  self:get_centroid()
end




-- An emerald rectangle class. This is a rectangle with its corners cut by the given rx, ry amount.
-- Implements every function that Polygon does.
EmeraldRectangle = Object:extend()
EmeraldRectangle:implement(Polygon)
function EmeraldRectangle:init(x, y, w, h, rx, ry, r)
  self.x, self.y, self.w, self.h, self.r = x, y, w, h, r
  self.rx, self.ry = rx, ry
  local w_div = w/2
  local h_div = h/2
  local x1, y1 = math.rotate_scale_point(x - w_div, y - h_div + ry, r or 0, x, y)
  local x2, y2 = math.rotate_scale_point(x - w_div + rx, y - h_div, r or 0, x, y)
  local x3, y3 = math.rotate_scale_point(x + w_div - rx, y - h_div, r or 0, x, y)
  local x4, y4 = math.rotate_scale_point(x + w_div, y - h_div + ry, r or 0, x, y)
  local x5, y5 = math.rotate_scale_point(x + w_div, y + h_div - ry, r or 0, x, y)
  local x6, y6 = math.rotate_scale_point(x + w_div - rx, y + h_div, r or 0, x, y)
  local x7, y7 = math.rotate_scale_point(x - w_div + rx, y + h_div, r or 0, x, y)
  local x8, y8 = math.rotate_scale_point(x - w_div, y + h_div - ry, r or 0, x, y)
  self.vertices = {x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6, x7, y7, x8, y8}
  self:get_size()
  self:get_bounds()
  self:get_centroid()
end
