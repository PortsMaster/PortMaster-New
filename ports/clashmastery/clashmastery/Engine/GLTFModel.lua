-- TODO
local json = require("ThirdParty.json.json")
local GLTFModel = {}
local cachedFrameDT = web and 1/30 or 1/60
local blenderFrameDT = 1/24 -- blender exports at 24 FPS
local componentTypeBytes = {
    [5120] = 1,
	[5121] = 1,
	[5122] = 2,
	[5123] = 2,
	[5125] = 4,
	[5126] = 4,
}

local unpackTypes = {
    [5120] = 'b',
    [5121] = 'B',
    [5122] = 'h',
    [5123] = 'H',
    [5125] = 'I4',
    [5126] = 'f'
}

local typeSizes = {
    ['SCALAR'] = 1,
	['VEC2'] = 2,
	['VEC3'] = 3,
	['VEC4'] = 4,
	['MAT2'] = 4,
	['MAT3'] = 9,
	['MAT4'] = 16,
}

local attributeKeys = {
    ['NORMAL'] = 'normals',
    ['POSITION'] = 'positions',
    ['TEXCOORD_0'] = 'uvs',
    ['JOINTS_0'] = 'joints',
    ['WEIGHTS_0'] = 'weights'
}

function GLTFModel.initialize()
    GLTFModel.all_anim_objects = {}
    GLTFModel.num_anim_objects = 0
end

function GLTFModel.readBufferData(gltfData, accessorIndex, rawDataBuffers, isIndices)
    local accessor = gltfData.accessors[accessorIndex + 1]
    local bufferView = gltfData.bufferViews[accessor.bufferView + 1]

    local offset = (bufferView.byteOffset or 0) + (accessor.byteOffset or 0)
    local unpackType = unpackTypes[accessor.componentType]
    local numElementsPerRecord = typeSizes[accessor.type]
    local typeSize = componentTypeBytes[accessor.componentType]
    local count = accessor.count
    local stride = bufferView.byteStride or numElementsPerRecord * typeSize

    local bufferData = rawDataBuffers[bufferView.buffer+1]

    -- alright lets DO THIS shit
    local dataArray = {}
    for k = 0,count-1 do
        if numElementsPerRecord ~= 1 then
            local vector = {}
            local recordPos = offset + k * stride
            for k2 = 0,numElementsPerRecord-1 do
                local value = love.data.unpack(unpackType, bufferData, recordPos + k2*typeSize + 1)
                table.insert(vector, value)
            end
            table.insert(dataArray, vector)
        else
            local elementSize = typeSize * numElementsPerRecord
            local value = love.data.unpack(unpackType, bufferData, offset + (k)*elementSize + 1)
            if isIndices then
                table.insert(dataArray, value+1)
            else
                table.insert(dataArray, value)
            end
        end
    end
    return dataArray
end

function GLTFModel.traverseTreeAndUpdateTransforms(nodeShell, allNodes, parentTransform)
    local node = allNodes[nodeShell.nodeIndex+1]
    parentTransform = parentTransform or Mesh.identityMatrix
    Matrix.setFromTRS(node.transform,
        node.translation[1], node.translation[2], node.translation[3],
        node.rotation[1],node.rotation[2], node.rotation[3], node.rotation[4],
        node.scale[1], node.scale[2], node.scale[3])
    Matrix.multiplyInto(parentTransform, node.transform, node.transform)
    for k = 1,#nodeShell.children do
        GLTFModel.traverseTreeAndUpdateTransforms(nodeShell.children[k], allNodes, node.transform)
    end
end

function GLTFModel.updateAllNodeAnimations(animationData, allNodes)
    local animFinished = false
    if animationData[animationData.currentAnimation] then
        local currentAnimationData = animationData[animationData.currentAnimation]
        for k = 1,#allNodes do
            local node = allNodes[k]
            if currentAnimationData.nodes[k] then
                local currentNodeData = currentAnimationData.nodes[k]
                for key,value in pairs(currentNodeData) do
                    if node[key] then
                        local currentTime = animationData.currentTime
                        if currentTime >= value.times[#value.times] then
                            currentTime = 0
                            animFinished = true
                        end
                        local frameIndex = binarySearch(value.times, currentTime)
                        -- Idea: instead of binary search here, we could use knowledge that blender exports animations at 24 fps
                        -- When testing this out on the web, it's about a 10% speedup. Not sure if it's worth it.
                        -- local frameIndex = math.floor(currentTime / (blenderFrameDT)) + 1
                        if frameIndex == #value.times or frameIndex == 0 then
                            frameIndex = 1
                        end
                        -- interpolate between the two frames
                        if value.times[frameIndex+1] then
                            local normalizedFrameDT = (currentTime - value.times[frameIndex]) / (value.times[frameIndex+1] - value.times[frameIndex])
                            local value1 = value.values[frameIndex]
                            local value2 = value.values[frameIndex+1]
                            for k2 = 1,#value1 do
                                node[key][k2] = value1[k2]
                            end
                            if #value1 == 4 then -- quaternion
                                slerpQuaternion(node[key], value2, normalizedFrameDT)
                            else -- not a quaternion
                                lerpVector(node[key], value2, normalizedFrameDT)
                            end
                        end
                    else
                        error("Animation parameter " .. key .. " not found in node. Something went wrong with gltf writing?")
                    end
                end
            end
        end

    else
        -- error("Animation " .. animationData.currentAnimation .. " not found. Does this animation exist? Did you make a typo?")
    end
    return animFinished
end

-- This function is too slow. Use cached animations instead
function GLTFModel.updateAnimations(dt)
    for k = 1,GLTFModel.num_anim_objects do
        local obj = GLTFModel.all_anim_objects[k]
        if obj.active then
            local gltfData = obj.mesh
            local animationSpeed = obj.Animator.animationSpeeds[obj.Animator.animation] or 1
            obj.Animator.currentTime = obj.Animator.currentTime + dt * animationSpeed
            
            gltfData.animationData.currentTime = obj.Animator.currentTime
            gltfData.animationData.currentAnimation = obj.Animator.animation
            local animationEnded = GLTFModel.updateAllNodeAnimations(gltfData.animationData, gltfData.allNodes)
            GLTFModel.traverseTreeAndUpdateTransforms(gltfData.rootNode, gltfData.allNodes)
            if animationEnded then
                if obj.Animator.toLoops[obj.Animator.animation] then
                    obj.Animator.currentTime = 0
                end
                if obj.Animator.animEndedFcns[obj.Animator.animation] then
                    obj.Animator.animEndedFcns[obj.Animator.animation](obj)
                end
            end
        end
    end
end

function GLTFModel.updateAnimationsCached(dt)
    for k = 1,GLTFModel.num_anim_objects do
        local obj = GLTFModel.all_anim_objects[k]
        if obj.active then
            local gltfData = obj.mesh
            local animationSpeed = obj.Animator.animationSpeeds[obj.Animator.animation] or 1
            obj.Animator.currentTime = obj.Animator.currentTime + dt * animationSpeed

            -- Compute a frame index and simply look up the animation transform
            local frameIndex = math.floor(obj.Animator.currentTime / (cachedFrameDT)) + 1
            local cachedData = gltfData.cachedAnimationData[obj.Animator.animation]
            local animationEnded = false
            -- This used to be ">" instead of ">=".
            -- We changed it to ">=" because it looks like our final frame of our animations was the same as our first frame.
            -- A more robust solution (when we do interpolation in the future) might be to ensure that the last frame of our
            -- cached animations is not the same as the first frame, i.e making sure our exit condition in the caching step uses >= instead of >.
            if frameIndex >= cachedData.maxFrameIndex then
                frameIndex = 1
                animationEnded = true
            end

            if not animationEnded then
                for k2 = 1,#gltfData.allNodes do
                    local node = gltfData.allNodes[k2]
                    Matrix.copyInto(cachedData.nodeTransforms[k2][frameIndex], node.transform)
                end
            end

            if animationEnded then
                if obj.Animator.toLoops[obj.Animator.animation] then
                    obj.Animator.currentTime = 0
                end
                if obj.Animator.animEndedFcns[obj.Animator.animation] then
                    obj.Animator.animEndedFcns[obj.Animator.animation](obj)
                end
            end
        end
    end
end

function GLTFModel.cacheAllAnimationData(gltfData, progressBar)
    -- Precomputes all node transforms for all animations at 60 FPS
    -- to avoid having to do this computation at runtime
    gltfData.cachedAnimationData = {}
    for animationIndex = 1,#gltfData.animationData.allAnimationNames do
        local animation = gltfData.animationData.allAnimationNames[animationIndex]
        local currentTime = 0
        local dT = cachedFrameDT
        local animationEnded = false
        gltfData.cachedAnimationData[animation] = {
            nodeTransforms = {}, -- each index is an array of transforms for that node for each frame of the animation
        }
        local frameIndex = 1
        while not animationEnded do
            gltfData.animationData.currentTime = currentTime
            gltfData.animationData.currentAnimation = animation
            animationEnded = GLTFModel.updateAllNodeAnimations(gltfData.animationData, gltfData.allNodes)
            GLTFModel.traverseTreeAndUpdateTransforms(gltfData.rootNode, gltfData.allNodes)
            for k = 1,#gltfData.allNodes do
                if not gltfData.cachedAnimationData[animation].nodeTransforms[k] then
                    gltfData.cachedAnimationData[animation].nodeTransforms[k] = {}
                end
                gltfData.cachedAnimationData[animation].nodeTransforms[k][frameIndex] = Matrix.identityMatrix()
                Matrix.copyInto(gltfData.allNodes[k].transform, gltfData.cachedAnimationData[animation].nodeTransforms[k][frameIndex])
            end
            currentTime = currentTime + dT
            frameIndex = frameIndex + 1
        end
        gltfData.cachedAnimationData[animation].maxFrameIndex = frameIndex - 1
        -- This allows the loading screen to be more granular
        if progressBar then
            coroutine.yield(progressBar[1]/progressBar[2] + (animationIndex / #gltfData.animationData.allAnimationNames) * (1/progressBar[2]))
        end
    end
end

function GLTFModel.addAnimator(obj)
    local gltfAnimator = {
        animation = obj.mesh.animationData.currentAnimation,
        currentTime = 0,
        toLoops = {},
        animEndedFcns = {},
        animationSpeeds = {}
    }
    obj.Animator = gltfAnimator
    GLTFModel.num_anim_objects = GLTFModel.num_anim_objects + 1
    GLTFModel.all_anim_objects[GLTFModel.num_anim_objects] = obj
end

function GLTFModel.changeAnimation(obj, animation, force)
    if obj.Animator.animation ~= animation or force then
        obj.Animator.animation = animation
        obj.Animator.currentTime = 0
    end
end

function GLTFModel.setAnimationProperties(obj, animation, speed, toLoop, animEndedFcn)
    local animator = obj.Animator
    animator.animationSpeeds[animation] = speed or 1
    animator.toLoops[animation] = toLoop
    animator.animEndedFcns[animation] = animEndedFcn or function(obj) end
end

function GLTFModel.readFromFile(filename, progressBar)
    local data = love.filesystem.read(filename)
    data = json.decode(data)

    local meshesRaw = data.meshes

    local rawDataBuffers = {}
    for k = 1,#data.buffers do
        rawDataBuffers[k] = love.filesystem.read("Models/"..data.buffers[k].uri)
    end

    -- read all vertex attributes
    local meshDatas = {}
    for k = 1,#meshesRaw do
        meshDatas[k] = {}
        local currentMesh = meshesRaw[k]
        local currentPrimitive = currentMesh.primitives[1]
        for key,value in pairs(currentPrimitive.attributes) do
            local attribute = attributeKeys[key]
            if attribute then
                meshDatas[k][attribute] = GLTFModel.readBufferData(data, value, rawDataBuffers)
            end
        end
        meshDatas[k].indices = GLTFModel.readBufferData(data, currentPrimitive.indices, rawDataBuffers, true)
    end

    -- Read animation data
    local animationData = {}
    animationData.allAnimationNames = {}
    animationData.currentTime = 0
    if data.animations then
        for k = 1,#data.animations do
            local currentAnimation = data.animations[k]
            local animationName = currentAnimation.name
            local channels = currentAnimation.channels
            local currentAnimationData = {
                nodes = {}
            }
            for k2 = 1,#channels do
                local currentChannel = channels[k2]
                local sampler = currentAnimation.samplers[currentChannel.sampler+1]
                local times = GLTFModel.readBufferData(data, sampler.input, rawDataBuffers)
                local values = GLTFModel.readBufferData(data, sampler.output, rawDataBuffers)
                if not currentAnimationData.nodes[currentChannel.target.node+1] then
                    currentAnimationData.nodes[currentChannel.target.node+1] = {}
                end
                local currentNodeData = currentAnimationData.nodes[currentChannel.target.node+1]
                currentNodeData[currentChannel.target.path] = {
                    times = times,
                    values = values
                }
            end
            animationData[animationName] = currentAnimationData
            table.insert(animationData.allAnimationNames, animationName)
            if not animationData.currentAnimation then -- the first animation is the default
                animationData.currentAnimation = animationName
            end
        end
    end

    -- Read the joint data
    local skinData = {}
    if data.skins then
        for k = 1,#data.skins do
            local currentSkin = data.skins[k]
            local currentSkinData = {}
            currentSkinData.joints = {}
            local inverseBindData = GLTFModel.readBufferData(data, currentSkin.inverseBindMatrices, rawDataBuffers)
            for k2 = 1,#currentSkin.joints do
                local currentJointData = {}
                currentJointData.node = currentSkin.joints[k2]
                -- need to transpose because gltf is column major
                currentJointData.inverseBindMatrix = inverseBindData[k2]
                Matrix.transpose(currentJointData.inverseBindMatrix)
                currentSkinData.joints[k2] = currentJointData
            end
            currentSkinData.jointMap = currentSkin.joints
            skinData[k] = currentSkinData
        end
    end
    -- Read the hierarchy so we can compute joint matrices.
    -- This is the only reason to use the hierarchy.
    local currentScene = data.scenes[1] -- assume just one scene
    -- Also assume only 1 root node
    local rootNode = {
        nodeIndex = currentScene.nodes[1],
        children = {}
    }
    local allNodes = {}
    local function recursivelyAddChildren(node, allNodes)
            local currentNode = data.nodes[node.nodeIndex+1]
            local childNodeData = currentNode.children
            allNodes[node.nodeIndex+1] = {
                translation = currentNode.translation or {0,0,0},
                rotation = currentNode.rotation or {0,0,0,1},
                scale = currentNode.scale or {1,1,1},
                transform = Matrix.identityMatrix(),
                parentIndex = -1
            }
            if childNodeData then
                for k = 1,#childNodeData do
                    node.children[k] = {
                        nodeIndex = childNodeData[k],
                        children = {}
                    }
                    recursivelyAddChildren(node.children[k], allNodes)
                    allNodes[childNodeData[k]+1].parentIndex = node.nodeIndex
                end
            end
            node.name = currentNode.name
        end
    recursivelyAddChildren(rootNode, allNodes)

    -- Return the final gltf data
    local gltfData = {}
    local mesh = meshDatas[1]
    -- Mesh data
    local vertexData = {}
    for k = 1,#mesh.positions do
        local position = mesh.positions[k]
        local normal = mesh.normals[k]
        local uvs
        if not mesh.uvs then
            uvs = {0.0, 0.0}
        else
            -- GLTF UVs are flipped vertically
            uvs = {mesh.uvs[k][1], 1 - mesh.uvs[k][2]}
        end
        local joint = mesh.joints[k]
        local weight = mesh.weights[k]
        vertexData[k] = {
            position[1], position[2], position[3],
            uvs[1], uvs[2],
            normal[1], normal[2], normal[3],
            joint[1], joint[2], joint[3], joint[4],
            weight[1], weight[2], weight[3], weight[4]}
    end
    -- Node hierarchy
    gltfData.rootNode = rootNode
    -- Joint info
    gltfData.allJointMatrices = {} -- This will also be populated by mesh code
    local skin = skinData[1]
    for k = 1,#skin.joints do
        local nodeIndex = skin.joints[k].node+1
        allNodes[nodeIndex].inverseBindMatrix = skin.joints[k].inverseBindMatrix
        allNodes[nodeIndex].tempMatrix = Matrix.identityMatrix()
    end

    gltfData.allNodes = allNodes
    -- Update the transforms for the default pose of the model
    GLTFModel.traverseTreeAndUpdateTransforms(gltfData.rootNode, gltfData.allNodes)
    animationData.currentTime = 0
    animationData.animationSpeed = 1
    GLTFModel.updateAllNodeAnimations(animationData, gltfData.allNodes)
    GLTFModel.traverseTreeAndUpdateTransforms(gltfData.rootNode, gltfData.allNodes)

    gltfData.jointMap = {}
    for k = 1,#skin.jointMap do
        gltfData.jointMap[k] = skin.jointMap[k] + 1
    end
    gltfData.animationData = animationData
    local vertexFormat = {
        {"VertexPosition", "float", 3},
        {"VertexTexCoord", "float", 2},
        {"VertexNormal", "float", 3},
        {"VertexJoint", "float", 4,},
        {"VertexJointWeights", "float", 4}
    }
    gltfData.loveMesh = love.graphics.newMesh(vertexFormat, vertexData, "triangles", "stream")
    gltfData.loveMesh:setVertexMap(mesh.indices)

    -- cache all animation data so we don't have to do expensive operations at runtime
    GLTFModel.cacheAllAnimationData(gltfData, progressBar)
    return gltfData
end

return GLTFModel