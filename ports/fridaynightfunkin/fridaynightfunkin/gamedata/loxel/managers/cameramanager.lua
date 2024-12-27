local CameraManager = {list = {}}
local defaults = {}

function CameraManager.add(camera, defaultDrawTarget)
	table.insert(CameraManager.list, camera)
	if defaultDrawTarget == nil or defaultDrawTarget then
		table.insert(defaults, camera)
	end
	return camera
end

function CameraManager.remove(camera, destroy)
	if destroy == nil or destroy then
		camera:destroy()
	end
	if table.delete(CameraManager.list, camera) then
		table.delete(defaults, camera)
	end
end

function CameraManager.reset(camera)
	for i = #CameraManager.list, 1, -1 do
		CameraManager.list[i]:destroy()
		table.delete(defaults, CameraManager.list[i])
		CameraManager.list[i] = nil
	end

	if not camera then camera = Camera() end
	game.camera = CameraManager.add(camera)

	Camera.__defaultCameras = defaults
end

function CameraManager.setDefaultDrawTarget(camera, value)
	local index = table.find(CameraManager.list, camera)
	if index then
		index = table.find(defaults, camera)
		if value and not index then
			table.remove(defaults, camera)
		elseif not value then
			table.remove(defaults, index)
		end
	end
end

function CameraManager:update(dt)
	for _, cam in ipairs(self.list) do cam:update(dt) end
end

function CameraManager:__render()
	for _, cam in ipairs(self.list) do cam:draw() end
end

Camera.__defaultCameras = defaults

return CameraManager
