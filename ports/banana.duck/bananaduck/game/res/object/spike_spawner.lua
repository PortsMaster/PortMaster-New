local obj = object:extend()

function obj:create(ldtkEntity)
    if ldtkEntity.props.falling then
        for i = 0, math.floor(ldtkEntity.width / 4) - 1 do
            objects.spike_falling(ldtkEntity.x + i * 4, ldtkEntity.y)
         end
    elseif ldtkEntity.props.direction == 1 then
        for i = 0, math.floor(ldtkEntity.width / 4) - 1 do
           objects.spike(ldtkEntity.x + i * 4, ldtkEntity.y, 1)
        end
    elseif ldtkEntity.props.direction == 3 then
        for i = 0, math.floor(ldtkEntity.width / 4) - 1 do
            objects.spike(ldtkEntity.x + i * 4, ldtkEntity.y, 3)
         end
    elseif ldtkEntity.props.direction == 2 then
        for i = 0, math.floor(ldtkEntity.height / 4) - 1 do
            objects.spike(ldtkEntity.x, ldtkEntity.y + i * 4, 2)
        end
    elseif ldtkEntity.props.direction == 4 then
        for i = 0, math.floor(ldtkEntity.height / 4) - 1 do
            objects.spike(ldtkEntity.x, ldtkEntity.y + i * 4, 4)
        end
    end
end


return obj