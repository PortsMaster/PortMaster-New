--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- skins library
loveframes.skins = {}

--[[---------------------------------------------------------
	- func: RegisterSkin(skin)
	- desc: registers a skin
--]]---------------------------------------------------------
function loveframes.RegisterSkin(skin)
	local skins = loveframes.skins
	local name = skin.name
	local author = skin.author
	local version = skin.version
	local basename = skin.base
	local newskin = false
	
	if name == "" or not name then
		loveframes.Error("Skin registration error: Invalid or missing name data.")
	end
	
	if author == "" or not author then
		loveframes.Error("Skin registration error: Invalid or missing author data.")
	end
	
	if version == "" or not version then
		loveframes.Error("Skin registration error: Invalid or missing version data.")
	end
	
	local namecheck = skins[name]
	if namecheck then
		loveframes.Error("Skin registration error: A skin with the name '" ..name.. "' already exists.")
	end
	
	local dir = skin.directory or loveframes.config["DIRECTORY"] .. "/skins/" ..name
	local dircheck = love.filesystem.getInfo(dir) ~= nil and love.filesystem.getInfo(dir)["type"] == "directory"
	if not dircheck then
		loveframes.Error("Skin registration error: Could not find a directory for skin '" ..name.. "'.")
	end
	
	local imagedir = skin.imagedir or dir .. "/images"
	local imagedircheck = love.filesystem.getInfo(imagedir) ~= nil and love.filesystem.getInfo(imagedir)["type"] == "directory"
	if not imagedircheck then
		loveframes.Error("Skin registration error: Could not find an image directory for skin '" ..name.. "'.")
	end
	
	if basename then
		--local basename = base
		local base = skins[basename]
		if not base then
			loveframes.Error("Could not find base skin '" ..basename.. "' for skin '" ..name.. "'.")
		end
		newskin = loveframes.DeepCopy(base)
		newskin.name = name
		newskin.author = author
		newskin.version = version
		newskin.imagedir = imagedir
		local skincontrols = skin.controls
		local basecontrols = base.controls
		if skincontrols and basecontrols then
			for k, v in pairs(skincontrols) do
				newskin.controls[k] = v
			end
			for k, v in pairs(skin) do
				if type(v) == "function" then
					newskin[k] = v
				end
			end
		end
	end
	
	if not newskin then
		newskin = skin
	end
	
	newskin.dir = dir
	local images = {}
	
	local indeximages = loveframes.config["INDEXSKINIMAGES"]
	if indeximages then
		local imagelist = loveframes.GetDirectoryContents(imagedir)
		local filename, extension, image
		for k, v in ipairs(imagelist) do
			extension = v.extension
			filename = v.name .. "." .. extension
			if extension == "png" then
				image = love.graphics.newImage(v.fullpath)
				image:setFilter("nearest", "nearest")
				images[filename] = image
			end
		end
	end
	newskin.images = images
	skins[name] = newskin
end

function loveframes.LoadSkins(dir)
	local skinlist = loveframes.GetDirectoryContents(dir)
	-- loop through a list of all gui skins and require them
	local skin
	for k, v in ipairs(skinlist) do
		if v.extension == "lua" then
			skin = loveframes.require(v.requirepath)
			--loveframes.RegisterSkin(skin)
		end
	end
end
--return skins

---------- module end ----------
end
