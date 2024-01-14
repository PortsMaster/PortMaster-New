local object = object:extend()

function object:new(layer)
    self.layer = layer
end

function object:draw()
    if self.layer and self.layer.visible then
        self.layer:draw()
    end
end