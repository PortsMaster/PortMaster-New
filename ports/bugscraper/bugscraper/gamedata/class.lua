local Class = {}
Class.__index = Class

function Class:inherit()
    local Subclass = {}
    Subclass.__index = Subclass
    setmetatable(Subclass, self)
    return Subclass
end

function Class:init()
    error("this class cannot be initialized: init not defined")
end

function Class:new(...)
    local instance = {}
    setmetatable(instance, self)
    self.init(instance, ...)
    return instance
end

return Class