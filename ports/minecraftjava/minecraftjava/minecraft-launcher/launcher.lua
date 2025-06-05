local Launcher = {}
Launcher.__index = Launcher

function Launcher.new()
    local self = setmetatable({}, Launcher)
    self.versions = {}
    return self
end

function Launcher:loadVersions()
    -- Centralized version data with row (loader) and script specified
    self.versions = {
        { name = "1.7.10", loader = "Vanilla", script = "1.7.10.start" },
        { name = "1.7.10", loader = "Forge", script = "1.7.10-Forge.start" },
        { name = "1.13", loader = "Vanilla", script = "1.13.start" },
        { name = "1.16.5", loader = "Fabric", script = "1.16.5-Fabric.start" },
    }
end

function Launcher:getVersions()
    return self.versions
end

function Launcher:getVersionsByLoader(loader)
    local filtered = {}
    for _, version in ipairs(self.versions) do
        if version.loader == loader then
            table.insert(filtered, version)
        end
    end
    return filtered
end

function Launcher:startVersion(version)
    print("Starting version: " .. version.name .. " with loader: " .. version.loader)
    print("Copying script to: main.start")
    -- Copy the script to main.start
    local baseDir = love.filesystem.getSourceBaseDirectory()
    local scriptPath = baseDir .. "/" .. version.script
    local mainScriptPath = baseDir .. "/main.start"

    -- Use os.execute to copy the file
    local command = string.format('cp "%s" "%s"', scriptPath, mainScriptPath)
    local success = os.execute(command)
    love.event.quit()

    if success then
        print("Script copied successfully to main.start!")
    else
        print("Failed to copy script.")
    end
end

return Launcher
