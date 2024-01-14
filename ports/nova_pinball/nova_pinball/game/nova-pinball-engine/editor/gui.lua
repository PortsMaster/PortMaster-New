-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
   
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see http://www.gnu.org/licenses/.

-----------------------------------------------------------------------

local gui = { }
gui.cursors = { }
gui.toolboxVisible = true
gui.registeredToolCount = 0

function gui.status(text)
    gui.statusbar:SetText(text)
end

function gui.setTool(text)
    gui.toolName:SetText(text)
end

function gui.createStatusbar()
    local statusBarHeight = 20
    local statusPanel = loveframes.Create("panel")
    local screenWidth, screenHeight = love.graphics.getDimensions()
    statusPanel:SetSize(screenWidth, statusBarHeight):SetPos(0, screenHeight - statusBarHeight)
    gui.statusbar = loveframes.Create("text", statusPanel)
    gui.statusbar:SetPos(5, 5)
    gui.statusbar:SetText("Welcome to the Nova Pinball table editor! Press F1 for shortcuts.")

    gui.toolName = loveframes.Create("text", statusPanel)
    gui.toolName:SetDefaultColor(0, 0, 1)
    gui.toolName:SetText("")
    gui.toolName:SetPos(screenWidth - 150, 5)
    gui.toolName:CenterX()

end

function gui.createAdvancedPane()
	local screenWidth, screenHeight = love.graphics.getDimensions()
    local advancedPaneWidth = 160
    gui.advancedPaneX = screenWidth - advancedPaneWidth
	local tbpanel = loveframes.Create("panel")
	tbpanel:SetSize(advancedPaneWidth, screenHeight)
	tbpanel:SetPos(screenWidth - advancedPaneWidth, 0)
    gui.advancedPane = tbpanel

    -- component cycler list
    local f = loveframes.Create("frame", tbpanel)
    f:SetName("Component Cycler")
    f:SetSize(advancedPaneWidth, 100)
    f:SetDraggable(false)
    f:ShowCloseButton(false)
    local cmpList = loveframes.Create("list", f)
    cmpList:SetY(20)
    cmpList:SetHeight(80)
    cmpList:SetWidth(advancedPaneWidth)
    gui.componentCyclerList = cmpList

    -- Component Tag Input
    local f = loveframes.Create("frame", tbpanel)
    f:SetName("Component Tag")
    f:SetSize(advancedPaneWidth, 40)
    f:SetDraggable(false)
    f:ShowCloseButton(false)
    f:SetY(100)
    local textinput = loveframes.Create("textinput", f)
    textinput:SetY(20)
    textinput:SetWidth(advancedPaneWidth)
    textinput.OnEnter = function(object)
        local tag = object:GetText()
        gui.setComponentTag(tag)
        object:SetFocus(false)
    end
    gui.componentTagInput = textinput
    
    -- Component Cooldown Input
    local f = loveframes.Create("frame", tbpanel)
    f:SetName("Component Cooldown")
    f:SetSize(advancedPaneWidth, 40)
    f:SetDraggable(false)
    f:ShowCloseButton(false)
    f:SetY(145)
    local textinput = loveframes.Create("textinput", f)
    textinput:SetY(20)
    textinput:SetWidth(advancedPaneWidth)
    textinput.OnEnter = function(object)
        local cooldown = object:GetText()
        gui.setComponentCooldown(cooldown)
        object:SetFocus(false)
    end
    gui.componentCooldownInput = textinput

end

function gui.readComponentTag(tag)
    gui.componentTagInput:SetText(tag)
end

function gui.readComponentCooldown(value)
    gui.componentCooldownInput:SetText(value)
end

function gui.setComponentTag(tag)

end

function gui.setComponentCooldown(cooldown)

end

function gui.setComponentCyclerItems(items, clickHandler)
    local l = gui.componentCyclerList
    -- TODO Does clear release previous button objects? Keep an eye out here for possible memory leaks.
    l:Clear()
    if (items) then
        for i, v in ipairs(items) do
            local b = loveframes.Create("button")
            b.data = v.idx
            b:SetText(v.text)
            b:SetY((i-1)*20)
            b.OnClick = clickHandler
            l:AddItem(b)
        end
    end
end

function gui.createToolbox(tools)

    -- group tools into categories
    local cats = { }
    for _, tool in ipairs(tools) do
        if (not cats[tool.category]) then cats[tool.category] = { } end
        table.insert (cats[tool.category], tool)
    end

    --table.sort (tools, function (a, b) return b.category < a.category end)

	local screenWidth, screenHeight = love.graphics.getDimensions()

    -- Toolbox panel
    gui.toolboxWidth = 160
	local tbpanel = loveframes.Create("panel")
	tbpanel:SetSize(gui.toolboxWidth, screenHeight)
	tbpanel:SetPos(0, 0)

    -- Toolbox list
    local tblist = loveframes.Create("list", tbpanel)
    tblist:SetHeight(screenHeight)
    tblist:SetWidth(gui.toolboxWidth)

    for cat, toolGroup in pairs(cats) do

        -- New category
        local catpanel = loveframes.Create("panel")
        local grid = loveframes.Create("grid", catpanel)
        grid:SetCellWidth(32)
        grid:SetCellHeight(32)
        --grid:SetCellPadding(6)
        grid:SetItemAutoSize(true)

        -- Add each tool in this group
        local j, k = 1, 1
        for _, tool in pairs(toolGroup) do

            -- Tool Button
            local button = loveframes.Create("imagebutton")
            button:SetImage(tool.icon)
            button:SetText("")
            button.data = tool
            button.OnClick = tool.guiAction
            
            -- Tooltip
            local tooltip = loveframes.Create("tooltip")
            tooltip:SetObject(button)
            tooltip:SetPadding(10)
            tooltip:SetOffsetY(60)
            tooltip:SetText(tool.text)

            grid:AddItem(button, j, k)
            k = k + 1
            if (k > 3) then
                k = 1
                j = j + 1   -- row count this category
            end
        end

        catpanel:SetHeight(j*40)

        local collapsiblecategory = loveframes.Create("collapsiblecategory")
        collapsiblecategory:SetText(cat)
        collapsiblecategory:SetObject(catpanel)
        collapsiblecategory:SetOpen(true)
        tblist:AddItem(collapsiblecategory)

    end

    gui.createAdvancedPane()

end

function gui.showMain(loadHandler, saveHandler)
    if (not gui.main) then
        gui.main = loveframes.Create("frame")
        gui.main:SetName("Nova Pinball")
        gui.main:SetSize(200, 200)
        gui.main:Center()
        gui.main.OnClose = function(object)
            gui.main = nil
        end

        --local panel = loveframes.Create("panel", gui.main)
        ----panel:SetSize(gui.main:GetSize())
        --panel:SetPos(5, 30)

        local loadBtn = loveframes.Create("button", gui.main)
        loadBtn:SetPos(5, 30)
        loadBtn:SetText("Load")
        loadBtn.OnClick = loadHandler

        local loadBtn = loveframes.Create("button", gui.main)
        loadBtn:SetPos(5, 60)
        loadBtn:SetText("Save")
        loadBtn.OnClick = saveHandler

    end
end

function gui.hideMain()
    if (gui.main) then
        gui.main:SetVisible(false)
        gui.main = nil
    end
end

function gui.setCursor(image)
    love.mouse.setCursor()
end

-- Get files in a directory as {filename, modtime}
function gui.getFiles(directory)
    local allItems = love.filesystem.getDirectoryItems(directory)
    local files = { }
    for _, f in pairs(allItems) do
        local fullpath = directory .. "/" .. f
        if love.filesystem.isFile(fullpath) then
            local info = love.filesystem.info(fullpath)
            if info then
            	table.insert(files, {filename=f, modtime=os.date("%c", info.modtime)})
            else
            	table.insert(files, {filename=f, modtime="Unknown"})
            end
        end
    end
    return files
end

function gui.fileDialog(mode, directory, callback, warn)

    local files = gui.getFiles(directory)
    local frame = loveframes.Create("frame")
    local list = loveframes.Create("columnlist", frame)
    local fileinput = loveframes.Create("textinput", frame)
    local button = loveframes.Create("button", frame)

    -- positioning
    frame:SetName("File Chooser")
    frame:SetSize(300, 200)
    frame:Center()
    list:SetY(20)
    list:SetSize(300, 160)
    fileinput:SetY(180)
    fileinput:SetSize(200, 20)
    button:SetPos(200, 180)
    button:SetText(mode)
    button:SetSize(100, 20)

    list:AddColumn("Filename")
    list:AddColumn("Modified")
    
    list.OnRowClicked = function(parent, row, rowdata)
        fileinput:SetText(rowdata[1])
    end

    button.OnClick = function()
        if (callback) then
            callback(directory .. "/" .. fileinput:GetText())
        end
        frame:SetVisible(false)
    end

    frame.OnClose = function()
        if (callback) then callback() end
    end
    
    for _, v in pairs(files) do
        list:AddRow(v.filename, v.modtime)
    end

    -- Show a warning to continue
    if (warn) then
        local warnpan = loveframes.Create("panel", frame)
        warnpan:SetY(20)
        warnpan:SetSize(300, 180)
        local warntext = loveframes.Create("text", warnpan)
        warntext:SetText("You have unsaved changes.")
        warntext:SetPos(40, 50)
        local warnYes = loveframes.Create("button", warnpan)
        local warnNo = loveframes.Create("button", warnpan)
        warnYes:SetText("Continue")
        warnNo:SetText("Cancel")
        warnYes:SetPos(50, 100)
        warnNo:SetPos(150, 100)
        warnYes.OnClick = function() warnpan:SetVisible(false) end
        warnNo.OnClick = function()
            if (callback) then callback() end
            frame:SetVisible(false)
        end
    end

end

function gui.showHelp()

    local helpText =
[[Editor functions
-----------------
Spacebar    select tool
Arrows      move selection (Alt moves in small steps)
Enter       apply selection
Delete      remove selected object

Control functions
-----------------
^C  Clone selection
^Z  Undo
^Y  Redo
^S  Save
^L  Load
^H  Flip selection horizontally
^V  Flip selection vertically
^E  Export table as PNG
^up   Scale selection up
^down Scale selection down

Shift functions
---------------
up, down    Scale selection height
left, right Scale selection width
Hold Alt to scale in small steps.

Mouse functions
-----------------
wheel       scroll view vertically
shift+wheel scroll view horizonally

Your tables path is:
]]

helpText = helpText .. love.filesystem.getSaveDirectory() .. "/tables"

    local frame = loveframes.Create("frame")
    frame:SetName("Nova pinball editor help")
    frame:SetSize(400, 500)
    frame:Center()
    
	local list1 = loveframes.Create("list", frame)
	list1:SetPos(5, 30)
	list1:SetSize(390, 465)
	list1:SetPadding(5)
	list1:SetSpacing(5)
	
	local text1 = loveframes.Create("text")
	text1:SetText(helpText)
	list1:AddItem(text1)

end

return gui
