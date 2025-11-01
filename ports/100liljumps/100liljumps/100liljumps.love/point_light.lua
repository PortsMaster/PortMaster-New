local Object = require("./classic")

PointLight = Object.extend(Object)

function PointLight.new(self, pos, color, radius, intensity, visible)
    self.pos = pos
    self.color = color
    self.radius = radius
    self.intensity = intensity

    if(visible ~= nil) then
        self.visible = visible
    else
        self.visible = true
    end
end