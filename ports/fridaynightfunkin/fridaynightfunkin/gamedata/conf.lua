local Project = require "project"

function love.conf(t)
	t.identity = Project.package
	t.console = Project.DEBUG_MODE
	t.gammacorrect = false
	t.highdpi = false

	--[[ Vulkan is buggy atm
		1. Makes inputs delayed for whatever reason
		2. Locks the Update FPS to monitor refresh rate, Though i think this is on purpose
			https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/vkWaitForFences.html
		3. No Nearest Filtering
		4. Stencil on Canvas Broke
	]]
	t.renderers = {"metal", "opengl"}
	--t.excluderenderers = {"vulkan"}

	-- we'll initialize the window in loxel/init.lua
	-- we need it for mobile to not be bugging
	t.modules.window = false
	t.modules.physics = false
end
