function love.load()
	--requires--
	require "controls"
	require "gameB"
	require "gameBmulti"
	require "gameA"
	require "menu"
	require "failed"
	require "rocket"

	vsync = true
	
	autosize()
	
	suggestedscale = math.min(math.floor((desktopheight-50)/144), math.floor((desktopwidth-10)/160))
	if suggestedscale > 5 then
		suggestedscale = 5
	end
	
	loadoptions()
	
	maxscale = math.min(math.floor(desktopheight/144), math.floor(desktopwidth/160)) 
	maxmpscale = math.min(math.floor(desktopheight/144), math.floor(desktopwidth/274)) 
	
	if fullscreen == false then
		if scale ~= 5 then
			love.graphics.setMode( 160*scale, 144*scale, false, vsync, 0 )
		end
	else
		love.graphics.setMode( 0, 0, true, vsync, 0 )
		love.mouse.setVisible( false )
		desktopwidth, desktopheight = love.graphics.getWidth(), love.graphics.getHeight()
		saveoptions()
		
		suggestedscale = math.floor((desktopheight-50)/144)
		if suggestedscale > 5 then
			suggestedscale = 5
		end
		maxscale = math.min(math.floor(desktopheight/144), math.floor(desktopwidth/160))
		
		scale = maxscale
		
		fullscreenoffsetX = (desktopwidth-160*scale)/2
		fullscreenoffsetY = (desktopheight-144*scale)/2
	end
	
	physicsscale = scale/4
	
	--pieces--
	tetriimages = {}
	tetriimagedata = {}
	
	--SOUND--
	music = {}
	
	music[1] = love.audio.newSource( "sounds/themeA.ogg", "stream")
	music[1]:setVolume( 0.6 )
	music[1]:setLooping( true )
	
	music[2] = love.audio.newSource( "sounds/themeB.ogg", "stream")
	music[2]:setVolume( 0.6 )
	music[2]:setLooping( true )
	
	music[3] = love.audio.newSource( "sounds/themeC.ogg", "stream")
	music[3]:setVolume( 0.6 )
	music[3]:setLooping( true )
	
	musictitle = love.audio.newSource( "sounds/titlemusic.ogg", "stream")
	musictitle:setVolume( 0.6 )
	musictitle:setLooping( true )
	
	musichighscore = love.audio.newSource( "sounds/highscoremusic.ogg", "stream")
	musichighscore:setVolume( 0.6 )
	musichighscore:setLooping( true )
	
	musicrocket4 = love.audio.newSource( "sounds/rocket4.ogg", "stream")
	musicrocket4:setVolume( 0.6 )
	musicrocket4:setLooping( false )
	
	musicrocket1to3 = love.audio.newSource( "sounds/rocket1to3.ogg", "stream")
	musicrocket1to3:setVolume( 0.6 )
	musicrocket1to3:setLooping( false )
	
	musicresults = love.audio.newSource( "sounds/resultsmusic.ogg", "stream")
	musicresults:setVolume( 1 )
	musicresults:setLooping( false )
	
	highscoreintro = love.audio.newSource( "sounds/highscoreintro.ogg", "stream")
	highscoreintro:setVolume( 0.6 )
	highscoreintro:setLooping( false )
	
	musicoptions = love.audio.newSource( "sounds/musicoptions.ogg", "stream")
	musicoptions:setVolume( 1 )
	musicoptions:setLooping( true )
	
	boot = love.audio.newSource( "sounds/boot.ogg")
	blockfall = love.audio.newSource( "sounds/blockfall.ogg", "stream")
	blockturn = love.audio.newSource( "sounds/turn.ogg", "stream")
	blockmove = love.audio.newSource( "sounds/move.ogg", "stream")
	lineclear = love.audio.newSource( "sounds/lineclear.ogg", "stream")
	fourlineclear = love.audio.newSource( "sounds/4lineclear.ogg", "stream")
	gameover1 = love.audio.newSource( "sounds/gameover1.ogg", "stream")
	gameover2 = love.audio.newSource( "sounds/gameover2.ogg", "stream")
	pausesound = love.audio.newSource( "sounds/pause.ogg", "stream")
	highscorebeep = love.audio.newSource( "sounds/highscorebeep.ogg", "stream")
	newlevel = love.audio.newSource( "sounds/newlevel.ogg", "stream")
	newlevel:setVolume( 0.6 )
	
	changevolume(volume)
	
	--IMAGES THAT WON'T CHANGE HUE:
	rainbowgradient = love.graphics.newImage("graphics/rainbow.png")rainbowgradient:setFilter("nearest", "nearest")
	
	--Whitelist for highscorenames--
	whitelist = {}
	for i = 48, 57 do -- 0 - 9
		whitelist[i] = true
	end
	for i = 65, 90 do -- A - Z
		whitelist[i] = true
	end
	for i = 97, 122 do --a - z
		whitelist[i] = true
	end
	whitelist[32] = true -- space
	whitelist[44] = true -- ,
	whitelist[45] = true -- -
	whitelist[46] = true -- .
	whitelist[95] = true -- _
	
	-----------------------------
	
	math.randomseed( os.time() )
	math.random();math.random();math.random() --discarding some as they seem to tend to unrandomness.
	
	love.graphics.setBackgroundColor( 255, 255, 255 )

	p1wins = 0
	p2wins = 0

	skipupdate = true
	soundenabled = true
	startdelay = 1
	logoduration = 1.5
	logodelay = 1
	creditsdelay = 2
	selectblinkrate = 0.29
	cursorblinkrate = 0.14
	selectblink = true
	cursorblink = true
	playerselection = 1
	musicno = 1 --
	gameno = 1 --
	selection = 1 --
	colorizeduration = 3 --seconds
	lineclearduration = 1.2 --seconds
	lineclearblinks = 7 --i
	linecleartreshold = 8.1 --in blocks
	densityupdateinterval = 1/30 --in seconds
	nextpiecerotspeed = 1 --rad per seconnd
	minfps = 1/50 --dt doesn't go higher than this
	scoreaddtime = 0.5
	startdelaytime = 0
	density = 0.1
	
	blockstartY = -64 --where new blocks are created
	losingY = 0 --lose if block 1 collides above this line
	blockmass = 5 --probably obsolete because body:setMassFromShapes()
	blockrot = 10
	blockrestitution = 0.1
	minmass = 1
	
	optionschoices = {"volume", "color", "scale", "fullscrn"}
	
	piececenter = {}
	piececenter[1] = {17, 5}
	piececenter[2] = {13, 9}
	piececenter[3] = {13, 9}
	piececenter[4] = { 9, 9}
	piececenter[5] = {13, 9}
	piececenter[6] = {13, 9}
	piececenter[7] = {13, 9}
	
	piececenterpreview = {}
	piececenterpreview[1] = {17, 5}
	piececenterpreview[2] = {15, 7}
	piececenterpreview[3] = {11, 7}
	piececenterpreview[4] = { 9, 9}
	piececenterpreview[5] = {13, 9}
	piececenterpreview[6] = {13, 7}
	piececenterpreview[7] = {13, 9}
	
	loadhighscores()
	loadconfig()
	
	loadimages()
	
	--all done!
	if startdelay == 0 then
		menu_load()
	end
end

function start()
	menu_load()
end

function loadimages()
	--IMAGES--
	--menu--
	stabyourselflogo = newPaddedImage("graphics/stabyourselflogo.png")
	logo = newPaddedImage("graphics/logo.png")
	title = newPaddedImage("graphics/title.png")
	gametype = newPaddedImage("graphics/gametype.png")
	mpmenu = newPaddedImage("graphics/mpmenu.png")
	optionsmenu = newPaddedImage("graphics/options.png")
	volumeslider = newPaddedImage("graphics/volumeslider.png")
	--game--
	gamebackground = newPaddedImage("graphics/gamebackground.png")
	gamebackgroundcutoff = newPaddedImage("graphics/gamebackgroundgamea.png")
	gamebackgroundmulti = newPaddedImage("graphics/gamebackgroundmulti.png")
	multiresults = newPaddedImage("graphics/multiresults.png")
	
	number1 = newPaddedImage("graphics/versus/number1.png")
	number2 = newPaddedImage("graphics/versus/number2.png")
	number3 = newPaddedImage("graphics/versus/number3.png")
	
	gameover = newPaddedImage("graphics/gameover.png")
	gameovercutoff = newPaddedImage("graphics/gameovercutoff.png")
	pausegraphic = newPaddedImage("graphics/pause.png")
	pausegraphiccutoff = newPaddedImage("graphics/pausecutoff.png")
	
	--figures--
	marioidle = newPaddedImage("graphics/versus/marioidle.png")
	mariojump = newPaddedImage("graphics/versus/mariojump.png")
	mariocry1 = newPaddedImage("graphics/versus/mariocry1.png")
	mariocry2 = newPaddedImage("graphics/versus/mariocry2.png")
	
	luigiidle = newPaddedImage("graphics/versus/luigiidle.png")
	luigijump = newPaddedImage("graphics/versus/luigijump.png")
	luigicry1 = newPaddedImage("graphics/versus/luigicry1.png")
	luigicry2 = newPaddedImage("graphics/versus/luigicry2.png")
	
	--rockets--
	rocket1 = newPaddedImage("graphics/rocket1.png");rocket1:setFilter( "nearest", "nearest" )
	rocket2 = newPaddedImage("graphics/rocket2.png")
	rocket3 = newPaddedImage("graphics/rocket3.png")
	spaceshuttle = newPaddedImage("graphics/spaceshuttle.png")
	
	rocketbackground = newPaddedImage("graphics/rocketbackground.png")
	bigrocketbackground = newPaddedImage("graphics/bigrocketbackground.png")
	bigrockettakeoffbackground = newPaddedImage("graphics/bigrockettakeoffbackground.png")
	
	
	smoke1left = newPaddedImage("graphics/smoke1left.png")
	smoke1right = newPaddedImage("graphics/smoke1right.png")
	smoke2left = newPaddedImage("graphics/smoke2left.png")
	smoke2right = newPaddedImage("graphics/smoke2right.png")
	
	fire1 = newPaddedImage("graphics/fire1.png")
	fire2 = newPaddedImage("graphics/fire2.png")
	firebig1 = newPaddedImage("graphics/firebig1.png")
	firebig2 = newPaddedImage("graphics/firebig2.png")
	
	congratsline = newPaddedImage("graphics/congratsline.png")
	
	--nextpiece
	nextpieceimg = {}
	for i = 1, 7 do
		nextpieceimg[i] = newPaddedImage( "graphics/pieces/"..i..".png", scale )
	end
	
	--font--
	tetrisfont = newPaddedImageFont("graphics/font.png", "0123456789abcdefghijklmnopqrstTuvwxyz.,'C-#_>:<! ")
	whitefont = newPaddedImageFont("graphics/fontwhite.png", "0123456789abcdefghijklmnopqrstTuvwxyz.,'C-#_>:<!+ ")
	love.graphics.setFont(tetrisfont)
	
	--filters!
	stabyourselflogo:setFilter("nearest", "nearest")
	logo:setFilter( "nearest", "nearest" )
	title:setFilter( "nearest", "nearest" )
	gametype:setFilter( "nearest", "nearest" )
	mpmenu:setFilter( "nearest", "nearest" )
	optionsmenu:setFilter( "nearest", "nearest" )
	volumeslider:setFilter( "nearest", "nearest" )
	gamebackground:setFilter( "nearest", "nearest" )
	gamebackgroundcutoff:setFilter( "nearest", "nearest" )
	gamebackgroundmulti:setFilter( "nearest", "nearest" )
	multiresults:setFilter( "nearest", "nearest" )
	number1:setFilter( "nearest", "nearest" )
	number2:setFilter( "nearest", "nearest" )
	number3:setFilter( "nearest", "nearest" )
	gameover:setFilter( "nearest", "nearest" )
	gameovercutoff:setFilter( "nearest", "nearest" )
	pausegraphic:setFilter( "nearest", "nearest" )
	pausegraphiccutoff:setFilter( "nearest", "nearest" )
	marioidle:setFilter( "nearest", "nearest" )
	mariojump:setFilter( "nearest", "nearest" )
	mariocry1:setFilter( "nearest", "nearest" )
	mariocry2:setFilter( "nearest", "nearest" )
	luigiidle:setFilter( "nearest", "nearest" )
	luigijump:setFilter( "nearest", "nearest" )
	luigicry1:setFilter( "nearest", "nearest" )
	luigicry2:setFilter( "nearest", "nearest" )
	rocket2:setFilter( "nearest", "nearest" )
	rocket3:setFilter( "nearest", "nearest" )
	spaceshuttle:setFilter( "nearest", "nearest" )
	rocketbackground:setFilter( "nearest", "nearest" )
	bigrocketbackground:setFilter( "nearest", "nearest" )
	bigrockettakeoffbackground:setFilter( "nearest", "nearest" )
	smoke1left:setFilter( "nearest", "nearest" )
	smoke1right:setFilter( "nearest", "nearest" )
	smoke2left:setFilter( "nearest", "nearest" )
	smoke2right:setFilter( "nearest", "nearest" )
	fire1:setFilter( "nearest", "nearest" )
	fire2:setFilter( "nearest", "nearest" )
	firebig1:setFilter( "nearest", "nearest" )
	firebig2:setFilter( "nearest", "nearest" )
	congratsline:setFilter( "nearest", "nearest" )
end

function love.update(dt)
	if gamestate == nil then
		startdelaytime = startdelaytime + dt
		if startdelaytime >= startdelay then
			start()
		end
	end

	if skipupdate then
		skipupdate = false
		return
	end
	
	if cuttingtimer ~= 0 then
		dt = math.min(dt, minfps)
	end
	
	if gamestate == "logo" or gamestate == "credits" or gamestate == "title" or gamestate == "menu" or gamestate == "multimenu" or gamestate == "highscoreentry" or gamestate == "options" then
		menu_update(dt)
	elseif gamestate == "gameA" or gamestate == "failingA" then
		if pause == false then
			gameA_update(dt)
		end
	elseif gamestate == "gameB" or gamestate == "failingB" then
		if pause == false then
			gameB_update(dt)
		end
		elseif gamestate == "gameBmulti" or gamestate == "failingBmulti" or gamestate == "failedBmulti" or gamestate == "gameBmulti_results" then
		gameBmulti_update(dt)
	elseif gamestate == "rocket1" or gamestate == "rocket2" or gamestate == "rocket3" or gamestate == "rocket4" then
		rocket_update()
	end
end

function love.draw()
	if gamestate == "logo" or gamestate == "credits" or gamestate == "title" or gamestate == "menu" or gamestate == "multimenu" or gamestate == "highscoreentry" or gamestate == "options" then
		menu_draw()
	elseif gamestate == "gameA" or gamestate == "failingA" then
		gameA_draw()
	elseif gamestate == "gameB" or gamestate == "failingB" then
		gameB_draw()
	elseif gamestate == "gameBmulti" or gamestate == "failingBmulti" or gamestate == "failedBmulti" or gamestate == "gameBmulti_results" then
		gameBmulti_draw()
	elseif gamestate == "failed" then
		failed_draw()
	elseif gamestate == "rocket1" or gamestate == "rocket2" or gamestate == "rocket3" or gamestate == "rocket4" then
		rocket_draw()
	end
end

function newImageData(path, s)
	local imagedata = love.image.newImageData( path )
	
	if s then
		imagedata = scaleImagedata(imagedata, s)
	end
	
	local width, height = imagedata:getWidth(), imagedata:getHeight()
	
	local rr, rg, rb = unpack(getrainbowcolor(hue))
	
	for y = 0, height-1 do
		for x = 0, width-1 do
			local oldr, oldg, oldb, olda = imagedata:getPixel(x, y)
			
			if olda ~= 0 then
				if oldr > 203 and oldr < 213 then --lightgrey
					local r = 145 + rr*64
					local g = 145 + rg*64
					local b = 145 + rb*64
					imagedata:setPixel(x, y, r, g, b, olda)
				elseif oldr > 107 and oldr < 117 then --darkgrey
					local r = 73 + rr*43
					local g = 73 + rg*43
					local b = 73 + rb*43
					imagedata:setPixel(x, y, r, g, b, olda)
				end
			end
		end
	end
	
	return imagedata
end

function newPaddedImage(filename, s)
    local source = newImageData(filename)
	
	if s then
		source = scaleImagedata(source, s)
	end
	
    local w, h = source:getWidth(), source:getHeight()
   
    -- Find closest power-of-two.
    local wp = math.pow(2, math.ceil(math.log(w)/math.log(2)))
    local hp = math.pow(2, math.ceil(math.log(h)/math.log(2)))
   
    -- Only pad if needed:
    if wp ~= w or hp ~= h then
        local padded = love.image.newImageData(wp, hp)
        padded:paste(source, 0, 0)
        return love.graphics.newImage(padded)
    end
   
    return love.graphics.newImage(source)
end

function padImagedata(source) --returns image, not imagedata!
    local w, h = source:getWidth(), source:getHeight()
   
    -- Find closest power-of-two.
    local wp = math.pow(2, math.ceil(math.log(w)/math.log(2)))
    local hp = math.pow(2, math.ceil(math.log(h)/math.log(2)))
   
    -- Only pad if needed:
    if wp ~= w or hp ~= h then
        local padded = love.image.newImageData(wp, hp)
        padded:paste(source, 0, 0)
        return love.graphics.newImage(padded)
    end
   
    return love.graphics.newImage(source)
end

function newPaddedImageFont(filename, glyphs)
    local source = newImageData(filename)
    local w, h = source:getWidth(), source:getHeight()
   
    -- Find closest power-of-two.
    local wp = math.pow(2, math.ceil(math.log(w)/math.log(2)))
    local hp = math.pow(2, math.ceil(math.log(h)/math.log(2)))
   
    -- Only pad if needed:
    if wp ~= w or hp ~= h then
        local padded = love.image.newImageData(wp, hp)
        padded:paste(source, 0, 0)
		local image = love.graphics.newImage(padded)
		image:setFilter("nearest", "nearest")
        return love.graphics.newImageFont(image, glyphs)
    end
	
    return love.graphics.newImageFont(source, glyphs)
end

function scaleImagedata(imagedata, i)
	local width, height = imagedata:getWidth(), imagedata:getHeight()
	local scaled = love.image.newImageData(width*i, height*i)
	
	for y = 0, height*i-1 do
		for x = 0, width*i-1 do
			local r, g, b, a = imagedata:getPixel(math.floor(x/i), math.floor(y/i))
			scaled:setPixel(x, y, r, g, b, a)
		end
	end	
	
	return scaled
end

function changevolume(i)
	music[1]:setVolume( 0.6*i )
	music[2]:setVolume( 0.6*i )
	music[3]:setVolume( 0.6*i )
	musictitle:setVolume( 0.6*i )
	musichighscore:setVolume( 0.6*i )
	musicrocket4:setVolume( 0.6*i )
	musicrocket1to3:setVolume( 0.6*i )
	musicresults:setVolume( i )
	highscoreintro:setVolume( 0.6*i )
	musicoptions:setVolume( i )
	boot:setVolume( i )
	blockfall:setVolume( i )
	blockturn:setVolume( i )
	blockmove:setVolume( i )
	lineclear:setVolume( i )
	fourlineclear:setVolume( i )
	gameover1:setVolume( i )
	gameover2:setVolume( i )
	pausesound:setVolume( i )
	highscorebeep:setVolume( i )
	newlevel:setVolume( 0.6*i )
end

function loadconfig()
	--standard controls
	--[[controls = {}
	controls["left"] = {"left"}
	controls["right"] = {"right"}
	controls["down"] = {"down"}
	controls["rotateleft"] = {"y", "z", "w"}
	controls["rotateright"] = {"x"}
	
	controls["p1left"] = {"a"}
	controls["p1right"] = {"d"}
	controls["p1down"] = {"s"}
	controls["p1rotateleft"] = {"g"}
	controls["p1rotateright"] = {"h"}
	
	controls["p2left"] = {"left"}
	controls["p2right"] = {"right"}
	controls["p2down"] = {"down"}
	controls["p2rotateleft"] = {"kp1"}
	controls["p2rotateright"] = {"kp2"}
	
	local keys = {"left", "right", "down", "rotateleft", "rotateright", "p1left", "p1right", "p1down", "p1rotateleft", "p1rotateright", "p2left", "p2right", "p2down", "p2rotateleft", "p2rotateright"}
	
	
	print(unpack(controls["left"]))--]]
end

function loadoptions()
	if love.filesystem.exists("options.txt") then
		local s = love.filesystem.read("options.txt")
		local split1 = s:split("\n")
		for i = 1, #split1 do
			local split2 = split1[i]:split("=")
			if split2[1] == "volume" then
				local v = tonumber(split2[2])
				--clamp and round
				if v < 0 then
					v = 0
				elseif v > 1 then
					v = 1
				end
				v = math.floor(v*10)/10
				
				volume = v
				
			elseif split2[1] == "hue" then
				hue = tonumber(split2[2])
			
			elseif split2[1] == "scale" then
				scale = tonumber(split2[2])
			
			elseif split2[1] == "fullscreen" then
				if split2[2] == "true" then
					fullscreen = true
				else
					fullscreen = false
				end	
			end
		end
		
		if volume == nil then
			volume = 1
		end
		if hue == nil then
			hue = 0.08
		end
		if fullscreen == nil then
			fullscreen = false
		end
		
		if scale == nil then
			scale = suggestedscale
		end
		
		
	else
		volume = 1
		hue = 0.08
		autosize()
		scale = suggestedscale
		fullscreen = false
	end
	
	saveoptions()
end

function saveoptions()
	local s = ""
	
	s = s .. "volume=" .. volume .. "\n"
	s = s .. "hue=" .. hue .. "\n"
	s = s .. "scale=" .. scale .. "\n"
	s = s .. "fullscreen=" .. tostring(fullscreen) .. "\n"
	
	love.filesystem.write("options.txt", s)
end

function autosize()
	local modes = love.graphics.getModes()
	desktopwidth, desktopheight = modes[1]["width"], modes[1]["height"]
end

function togglefullscreen(fullscr)
	fullscreen = fullscr
	love.mouse.setVisible( not fullscreen )
	if fullscr == false then
		scale = suggestedscale
		physicsscale = scale/4
		love.graphics.setMode( 160*scale, 144*scale, false, vsync, 0 )
	else
		love.graphics.setMode( 0, 0, true, vsync, 16 )
		desktopwidth, desktopheight = love.graphics.getWidth(), love.graphics.getHeight()
		suggestedscale = math.min(math.floor((desktopheight-50)/144), math.floor((desktopwidth-10)/160))
		suggestedscale = math.min(math.floor((desktopheight-50)/144), math.floor((desktopwidth-10)/160))
		if suggestedscale > 5 then
			suggestedscale = 5
		end
		maxscale = math.min(math.floor(desktopheight/144), math.floor(desktopwidth/160))
		
		scale = maxscale
		physicsscale = scale/4
		
		fullscreenoffsetX = (desktopwidth-160*scale)/2
		fullscreenoffsetY = (desktopheight-144*scale)/2
	end
end

function loadhighscores()
	if gameno == 1 then
		fileloc = "highscoresA.txt"
	else
		fileloc = "highscoresB.txt"
	end
	
	if love.filesystem.exists( fileloc ) then
		
		highdata = love.filesystem.read( fileloc )
		highdata = highdata:split(";")
		highscore = {}
		highscorename = {}
		for i = 1, 3 do
			highscore[i] = tonumber(highdata[i*2])
			highscorename[i] = string.lower(highdata[i*2-1])
		end
	else
		highscore = {}
		highscorename = {}
		highscore[1] = 0
		highscorename[1] = ""
		highscore[2] = 0
		highscorename[2] = ""
		highscore[3] = 0
		highscorename[3] = ""
		savehighscores()
	end
end

function newhighscores()
	highscore = {}
	highscorename = {}
	highscore[1] = 0
	highscorename[1] = ""
	highscore[2] = 0
	highscorename[2] = ""
	highscore[3] = 0
	highscorename[3] = ""
	savehighscores()
end

function savehighscores()
	if gameno == 1 then
		fileloc = "highscoresA.txt"
	else
		fileloc = "highscoresB.txt"
	end
	
	highdata = ""
	for i = 1, 3 do
		highdata = highdata..highscorename[i]..";"..highscore[i]..";"
	end
	love.filesystem.write( fileloc, highdata.."\n" )
end

function changescale(i)
	love.graphics.setMode( 160*i, 144*i, false, vsync, 0 )
	nextpieceimg = {}
	for j = 1, 7 do
		nextpieceimg[j] = newPaddedImage( "graphics/pieces/"..j..".png", i )
	end
	physicsscale = i/4
end

function isElement(t, value)
	for i, v in pairs(t) do
		if v == value then
			return true
		end
	end
	
	return false
end

function string:split(delimiter)
	local result = {}
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from  = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
end

function pythagoras(a, b)
	c = math.sqrt(a^2 + b^2)
	if a < 0 or b < 0 then
		c = -c
	end
	return c
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function table2string(mytable)
	output = {}
	for i, v in pairs (mytable) do
		output[i] = mytable[i]
	end
	return output
end

function getPoints2table(shape)
	x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6,x7,y7,x8,y8 = shape:getPoints()
	if x4 == nil then
		return {x1,y1,x2,y2,x3,y3}
	end
	if x5 == nil then
		return {x1,y1,x2,y2,x3,y3,x4,y4}
	end
	if x6 == nil then
		return {x1,y1,x2,y2,x3,y3,x4,y4,x5,y5}
	end
	if x7 == nil then
		return {x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6}
	end
	if x8 == nil then
		return {x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6,x7,y7}
	end
	return     {x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6,x7,y7,x8,y8}
end

function getrainbowcolor(i)
	local r, g, b
	if i < 1/6 then
		r = 1
		g = i*6
		b = 0
	elseif i >= 1/6 and i < 2/6 then
		r = (1/6-(i-1/6))*6
		g = 1
		b = 0
	elseif i >= 2/6 and i < 3/6 then
		r = 0
		g = 1
		b = (i-2/6)*6
	elseif i >= 3/6 and i < 4/6 then
		r = 0
		g = (1/6-(i-3/6))*6
		b = 1
	elseif i >= 4/6 and i < 5/6 then
		r = (i-4/6)*6
		g = 0
		b = 1
	else
		r = 1
		g = 0
		b = (1/6-(i-5/6))*6
	end
	
	return {r, g, b}
end

function love.keypressed( key, unicode )
	if gamestate == nil then
		if controls.check("return", key) then
			gamestate = "title"
			love.graphics.setBackgroundColor( 0, 0, 0)
			love.audio.play(musictitle)
			oldtime = love.timer.getTime()
		end
		
	elseif gamestate == "logo" then
		if controls.check("return", key) then
			gamestate = "title"
			love.graphics.setBackgroundColor( 0, 0, 0)
			love.audio.play(musictitle)
			oldtime = love.timer.getTime()
		end
		
	elseif gamestate == "credits" then
		if controls.check("return", key) then
			gamestate = "title"
			love.graphics.setBackgroundColor( 0, 0, 0)
			love.audio.play(musictitle)
			oldtime = love.timer.getTime()
		end
		
	elseif gamestate == "title" then
		if controls.check("return", key) then
			if playerselection ~= 3 then
				if soundenabled then
					love.audio.stop(musictitle)
					if musicno < 4 then
						love.audio.play(music[musicno])
					end
				end
			end
			if playerselection == 1 then
				gamestate = "menu"
			elseif playerselection == 2 then
				gamestate = "multimenu"
			else
				gamestate = "options"
				if soundenabled then
				love.audio.stop(musictitle)
				love.audio.play(musicoptions)
				end
				optionsselection = 1
			end
		elseif controls.check("escape", key) then
			love.event.push("q")
		elseif controls.check("left", key) and playerselection > 1 then
			playerselection = playerselection - 1
		elseif controls.check("right", key) and playerselection < 3 then
			playerselection = playerselection + 1
		end
		
	elseif gamestate == "menu" then	
		oldmusicno = musicno
		if controls.check("escape", key) then
			if musicno < 4 then
				love.audio.stop(music[musicno])
			end
			gamestate = "title"
			if soundenabled then
			love.audio.stop(musictitle)
			love.audio.play(musictitle)
			end
		elseif key == "backspace" then
			newhighscores()
		elseif controls.check("return", key) then
			if gameno == 1 then
				gameA_load()
			else
				gameB_load()
			end
		elseif controls.check("left", key) then
			if selection == 2 or selection == 4 or selection == 6 then
				selection = selection - 1
				selectblink = true
				oldtime = love.timer.getTime()
			end
		elseif controls.check("right", key) then
			if selection == 1 or selection == 3 or selection == 5 then
				selection = selection + 1
				selectblink = true
				oldtime = love.timer.getTime()
			end
		elseif controls.check("up", key) then
			if selection == 3 or selection == 4 or selection == 5 or selection == 6 then
				selection = selection - 2
				selectblink = true
				oldtime = love.timer.getTime()
				if selection < 3 then
					selection = gameno
					selectblink = false
					oldtime = love.timer.getTime()
				end
			elseif selection == 1 or selection == 2 then
				selection = musicno + 2
				selectblink = false
				oldtime = love.timer.getTime()
			end
		elseif controls.check("down", key) then
			if selection == 1 or selection == 2 or selection == 3 or selection == 4 then
				selection = selection + 2
				selectblink = true
				oldtime = love.timer.getTime()
				if selection > 2 and selection < 5 then
					selection = musicno + 2
					selectblink = false
					oldtime = love.timer.getTime()
				end
			elseif selection == 5 or selection == 6 then
				selection = gameno
				selectblink = false
				oldtime = love.timer.getTime()
			end
		end
		if selection > 2 and not controls.check("escape", key) then
			musicno = selection - 2
			if oldmusicno ~= musicno and oldmusicno ~= 4 then
				love.audio.stop(music[oldmusicno])
			end
			if musicno < 4 then
				love.audio.play(music[musicno])
			end
		elseif not controls.check("escape", key) then
			gameno = selection
			loadhighscores()
		end
	
	elseif gamestate == "options" then
		if controls.check("escape", key) then
			if soundenabled then
				love.audio.stop(musicoptions)
				love.audio.stop(musictitle)
				love.audio.play(musictitle)
			end
			saveoptions()
			loadimages()
			gamestate = "title"
		elseif controls.check("down", key) then
			optionsselection = optionsselection + 1
			if optionsselection > #optionschoices then
				optionsselection = 1
			end
			selectblink = true
			oldtime = love.timer.getTime()
			
		elseif controls.check("up", key) then
			optionsselection = optionsselection - 1
			if optionsselection == 0 then
				optionsselection = #optionschoices
			end
			selectblink = true
			oldtime = love.timer.getTime()
			
		elseif controls.check("left", key) then
			if optionsselection == 1 then
				if volume >= 0.1 then
					volume = volume - 0.1
					if volume < 0.1 then
						volume = 0
					end
					changevolume(volume)
				end
				
			elseif optionsselection == 3 then
				if fullscreen == false then
					if scale > 1 then
						scale = scale - 1
						changescale(scale)
					end
				end
				
			elseif optionsselection == 4 then
				if fullscreen == false then
					togglefullscreen(true)
				end
			
			end
			
		elseif controls.check("right", key) then
			if optionsselection == 1 then
				if volume <= 0.9 then
					volume = volume + 0.1
					changevolume(volume)
				end
				
			elseif optionsselection == 3 then
				if fullscreen == false then
					if scale < maxscale then
						scale = scale + 1
						changescale(scale)
					end
				end
				
			elseif optionsselection == 4 then
				if fullscreen == true then
					togglefullscreen(false)
				end
				
			end
			
		elseif controls.check("return", key) then
			if optionsselection == 1 then
				volume = 1
				changevolume(volume)
			elseif optionsselection == 2 then
				hue = 0.08
				optionsmenu = newPaddedImage("graphics/options.png");optionsmenu:setFilter( "nearest", "nearest" )
				volumeslider = newPaddedImage("graphics/volumeslider.png");volumeslider:setFilter( "nearest", "nearest" )
			elseif optionsselection == 3 then
				if fullscreen == false then
					if scale ~= suggestedscale then
						scale = suggestedscale
						changescale(scale)
					end
				end
			elseif optionsselection == 4 then
				if fullscreen == true then
					togglefullscreen(false)
				end
			end
			
		end
	
	elseif gamestate == "multimenu" then	
		oldmusicno = musicno
		if controls.check("escape", key) then
			if musicno < 4 then
				love.audio.stop(music[musicno])
			end
			gamestate = "title"
			love.audio.stop(musictitle)
			love.audio.play(musictitle)
		elseif controls.check("return", key) then
			gameBmulti_load()
		elseif controls.check("left", key) then
			if selection == 2 or selection == 4 or selection == 6 then
				selection = selection - 1
				selectblink = true
				oldtime = love.timer.getTime()
			end
		elseif controls.check("right", key) then
			if selection == 1 or selection == 3 or selection == 5 then
				selection = selection + 1
				selectblink = true
				oldtime = love.timer.getTime()
			end
		elseif controls.check("up", key) then
			if selection == 3 or selection == 4 or selection == 5 or selection == 6 then
				selection = selection - 2
				selectblink = true
				oldtime = love.timer.getTime()
				if selection < 3 then
					selection = gameno
					selectblink = false
					oldtime = love.timer.getTime()
				end
			elseif selection == 1 or selection == 2 then
				selection = musicno + 2
				selectblink = false
				oldtime = love.timer.getTime()
			end
		elseif controls.check("down", key) then
			if selection == 1 or selection == 2 or selection == 3 or selection == 4 then
				selection = selection + 2
				selectblink = true
				oldtime = love.timer.getTime()
				if selection > 2 and selection < 5 then
					selection = musicno + 2
					selectblink = false
					oldtime = love.timer.getTime()
				end
			elseif selection == 5 or selection == 6 then
				selection = gameno
				selectblink = false
				oldtime = love.timer.getTime()
			end
		end
		if selection > 2 and not controls.check("return", key) and not controls.check("escape", key) then
			musicno = selection - 2
			if oldmusicno ~= musicno and oldmusicno ~= 4 then
				love.audio.stop(music[oldmusicno])
			end
			if musicno < 4 then
				love.audio.play(music[musicno])
			end
		elseif not controls.check("return", key) and not controls.check("escape", key) then
			gameno = selection
			loadhighscores()
		end
			
	elseif gamestate == "gameA" or gamestate == "gameB" or gamestate == "failingA" or gamestate == "failingB" then

		if controls.check("return", key) then
			pause = not pause

			if pause == true then
				if musicno < 4 then
					love.audio.pause(music[musicno])
				end
				love.audio.stop(pausesound)
				love.audio.play(pausesound)
			else
				if musicno < 4 then
					love.audio.resume(music[musicno])
				end
			end
		end
		if gamestate == "gameA" or gamestate == "gameB" then
			if controls.check("escape", key) then
				oldtime = love.timer.getTime()
				gamestate = "menu"
			end
			
			if pause == false and (cuttingtimer == lineclearduration or gamestate == "gameB") then
				--if key == "up" then --STOP ROTATION OF BLOCK (makes it too easy..)
				--	tetribodies[counter]:setAngularVelocity(0)
				--end
				if controls.check("left", key) or controls.check("right", key) then
					love.audio.stop(blockmove)
					love.audio.play(blockmove)
				elseif controls.check("rotateleft", key) or controls.check("rotateright", key) then
					love.audio.stop(blockturn)
					love.audio.play(blockturn)
				end
			end
		end
	elseif gamestate == "gameBmulti" and gamestarted == false then
		if controls.check("escape", key) then
			if not fullscreen then
				love.graphics.setMode( 160*scale, 144*scale, false, vsync, 0 )
			end
			gamestate = "multimenu"
			if musicno < 4 then
				love.audio.play(music[musicno])
			end
		end
	elseif gamestate == "gameBmulti" and gamestarted == true then
		if controls.check("escape", key) then
			if not fullscreen then
				love.graphics.setMode( 160*scale, 144*scale, false, vsync, 0 )
			end
			gamestate = "multimenu"
		end
		if controls.check("left", key) or controls.check("right", key) or controls.check("leftp2", key) or controls.check("rightp2", key) then
			love.audio.stop(blockmove)
			love.audio.play(blockmove)
		elseif controls.check("rotateleft", key) or controls.check("rotateright", key) or controls.check("rotaterightp2", key) or controls.check("rotateleftp2", key) then
			love.audio.stop(blockturn)
			love.audio.play(blockturn)
		end
		
	elseif gamestate == "gameBmulti_results" then
		if controls.check("return", key) or controls.check("escape", key) then
			if musicno < 4 then
				love.audio.stop(musicresults)
				love.audio.play(music[musicno])
			end
			if not fullscreen then
				love.graphics.setMode( 160*scale, 144*scale, false, vsync, 0 )
			end
			gamestate = "multimenu"
		end
		
	elseif gamestate == "failed" then
		if controls.check("return", key) or controls.check("escape", key) then 
			love.audio.stop(gameover2)
			rocket_load()
		end
	elseif gamestate == "highscoreentry" then
		if controls.check("return", key) then
			gamestate = "menu"
			savehighscores()
			if musicchanged == true then
				love.audio.stop(musichighscore)
			else
				love.audio.stop(highscoreintro)
			end
			if musicno < 4 then
				love.audio.play(music[musicno])
			end
		elseif key == "backspace" then
			if highscorename[highscoreno]:len() > 0 then
				cursorblink = true
				highscorename[highscoreno] = string.sub(highscorename[highscoreno], 1, highscorename[highscoreno]:len()-1)
			end
			
		elseif whitelist[unicode] == true then
			if highscorename[highscoreno]:len() < 6 then
				cursorblink = true
				highscorename[highscoreno] = highscorename[highscoreno] .. string.char(unicode)
				love.audio.stop(highscorebeep)
				love.audio.play(highscorebeep)
			end
		end
	elseif string.sub(gamestate, 1, 6) == "rocket" then
		if controls.check("return", key) then
			love.audio.stop(musicrocket1to3)
			love.audio.stop(musicrocket4)
			failed_checkhighscores()
		end
	end
end
