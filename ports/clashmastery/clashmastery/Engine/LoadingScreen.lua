local LoadingScreen = {}
function LoadingScreen.loadingScreen(gameState)
    PauseMenu.canPause = false
    local using3DModels = #mainMeshes ~= 0
    local loadingIncrement = using3DModels and 0.35 or 0.5
    if useLoadingScreen then
        -- For now, loading 3D models and audio is probably the most expensive thing
        local loadingBar = GameObjects.newGameObject(-1, gameResolution.width/2, gameResolution.height/2, 0, true, GameObjects.DrawLayers.POSTCAMERA)
        local width, height = gameResolution.width/2, gameResolution.height / 16
        local margin = gameResolution.width/240
        loadingBar.currentProgress = 0
        loadingBar.totalProgress = 0
        loadingBar.loadingText = worldSpaceText("loading", gameResolution.width/2, gameResolution.height / 2 - gameResolution.height / 4, global_pallete.primary_color, GameObjects.DrawLayers.POSTCAMERA, picoFont)
        function loadingBar:draw()
            love.graphics.setColor(1,1,1,1)
            love.graphics.rectangle("line", loadingBar.x - width/2 - margin, loadingBar.y - height/2 - margin - gameResolution.height/24, width + margin*2, height + margin*2)
            love.graphics.rectangle("fill", loadingBar.x - width/2, loadingBar.y - height/2 - gameResolution.height/24, width * loadingBar.currentProgress, height)
            
            love.graphics.rectangle("line", loadingBar.x - width/2 - margin, loadingBar.y - height/2 - margin + gameResolution.height/24, width + margin*2, height + margin*2)
            love.graphics.rectangle("fill", loadingBar.x - width/2, loadingBar.y - height/2 + gameResolution.height/24, width * loadingBar.totalProgress, height)
        end

        local incrementallyLoad =
            function(loadRoutine, text)
                loadingBar.loadingText.text = "loading\n" .. text .. " 0%"
                loadingBar.currentProgress = 0
                loadingBar.loadingText.textWidth = loadingBar.loadingText.loveText:getWidth(loadingBar.loadingText.text)
                Mesh.meshInfos = mainMeshes
                local routine = coroutine.create(loadRoutine)
                coroutine.resume(routine)
                coroutine.yield(0) -- need to yield at least once to refresh the loading text to 0%
                while (coroutine.status(routine) ~= "dead") do
                    local status, progress = coroutine.resume(routine)
                    if progress then
                        loadingBar.loadingText.text = "loading\n" .. text .. " " .. math.ceil((progress * 100)) .. " %"
                        loadingBar.currentProgress = progress
                    end
                    coroutine.yield(0)
                end
            end
        loadingBar:startCoroutine(
            function()
                if using3DModels then
                    Mesh.meshInfos = mainMeshes
                    incrementallyLoad(Mesh.initializeRoutine, "3D Models")
                    loadingBar.totalProgress = loadingBar.totalProgress + loadingIncrement
                end
                incrementallyLoad(SoundManager.initializeRoutine, "Sounds")
                loadingBar.totalProgress = loadingBar.totalProgress + loadingIncrement
                MusicManager.musicDirectory, MusicManager.musicFileNames, MusicManager.extension = "Music", mainMusics, ".ogg"
                incrementallyLoad(MusicManager.initializeRoutine, "Music")
                loadingBar.totalProgress = 1
                coroutine.yield(0.5)
                loadingBar.loadingText.text = "You've got this!"
                loadingBar.loadingText.textWidth = loadingBar.loadingText.loveText:getWidth(loadingBar.loadingText.text)
                local pop = createCircularPop(gameResolution.width/2, gameResolution.height/2, global_pallete.secondary_color, gameResolution.width*2, gameResolution.width*2, 0, 1, 0.75, GameObjects.DrawLayers.POSTCAMERA)
                pop:setActive()
                coroutine.yield(0.5)
                local flash = createScreenFlash(global_pallete.secondary_color, 1, false, GameObjects.DrawLayers.POSTCAMERA)
                flash:setActive()
                coroutine.yield(0.25)
                gameState.goToNextLevel()
            end
        ,"loadContent")
    else
        local gm = GameObjects.newGameObject(-1,0,0,0,true)
        gm:startCoroutine(
            function()
                coroutine.yield(0.5)
                gameState.goToNextLevel()
            end
        , "goNext")
    end
end

return LoadingScreen