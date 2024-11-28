local Mesh = {}
function Mesh.initialize(meshInfos)
    Mesh.defaultShader = love.graphics.newShader('Engine/mesh.frag', 'Engine/mesh.vert')
    Mesh.defaultGLTFShader = love.graphics.newShader("Engine/mesh.frag", "Engine/gltfmesh.vert")
    Mesh.solidColorGLTFShader = love.graphics.newShader("Engine/solidColor.frag", "Engine/gltfmesh.vert")
    Mesh.unlitGLTFShader = love.graphics.newShader("Engine/unlit.frag", "Engine/gltfmesh.vert")
    Mesh.modelMatrix = {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    }
    Mesh.meshes = {}
    Mesh.identityMatrix = {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    }
    for k = 1,#meshInfos do
        if not meshInfos[k].isGLTF then
            Mesh.meshes[k] = Mesh.readFromObj("Models/"..meshInfos[k].model)
        else
            Mesh.meshes[k] = GLTFModel.readFromFile("Models/"..meshInfos[k].model)
            Mesh.meshes[k].isGLTF = true
        end
        if meshInfos[k].texture then
            if not meshInfos[k].isGLTF then
                Mesh.meshes[k]:setTexture(love.graphics.newImage("Models/"..meshInfos[k].texture))
            else
                Mesh.meshes[k].loveMesh:setTexture(love.graphics.newImage("Models/"..meshInfos[k].texture))
            end
        end
    end
end

-- Call this if you're planning to load meshes in a loading screen instead of all at once pre-launch
function Mesh.initializePropsPreload()
    Mesh.defaultShader = love.graphics.newShader('Engine/mesh.frag', 'Engine/mesh.vert')
    Mesh.defaultGLTFShader = love.graphics.newShader("Engine/mesh.frag", "Engine/gltfmesh.vert")
    Mesh.solidColorGLTFShader = love.graphics.newShader("Engine/solidColor.frag", "Engine/gltfmesh.vert")
    Mesh.unlitGLTFShader = love.graphics.newShader("Engine/unlit.frag", "Engine/gltfmesh.vert")
    Mesh.modelMatrix = {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    }
    Mesh.identityMatrix = {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    }
end

-- Coroutine version of the above function that allows for loading bar
-- make sure to set Mesh.meshInfos first
function Mesh.initializeRoutine()
    local meshInfos = Mesh.meshInfos
    Mesh.meshes = {}
    coroutine.yield(0)
    for k = 1,#meshInfos do
        if not meshInfos[k].isGLTF then
            Mesh.meshes[k] = Mesh.readFromObj("Models/"..meshInfos[k].model)
        else
            Mesh.meshes[k] = GLTFModel.readFromFile("Models/"..meshInfos[k].model, {(k-1),#meshInfos})
            Mesh.meshes[k].isGLTF = true
        end
        if meshInfos[k].texture then
            if not meshInfos[k].isGLTF then
                Mesh.meshes[k]:setTexture(love.graphics.newImage("Models/"..meshInfos[k].texture))
            else
                Mesh.meshes[k].loveMesh:setTexture(love.graphics.newImage("Models/"..meshInfos[k].texture))
            end
        end
        coroutine.yield(k / (#meshInfos))
    end
end

function Mesh.resetModelMatrix()
    for k = 1,16 do
        Mesh.modelMatrix[k] = 0
    end
    Mesh.modelMatrix[1] = 1
    Mesh.modelMatrix[6] = 1
    Mesh.modelMatrix[11] = 1
    Mesh.modelMatrix[16] = 1
end

function Mesh.readFromObj(objfile)
    local vertexFormat = {
        {"VertexPosition", "float", 3},
        {"VertexTexCoord", "float", 2},
        {"VertexNormal", "float", 3}
    }
    local meshData = {
        vertices = {},
        uvs = {},
        normals = {},
        faces = {}
    }
    for line in love.filesystem.lines(objfile) do
        local splitLine = splitAlongDelimiterAndExtract(line, " ")
        if splitLine[1] == "v" then
            local vert = {tonumber(splitLine[2]), tonumber(splitLine[3]), tonumber(splitLine[4])}
            table.insert(meshData.vertices, vert)
        elseif splitLine[1] == "vt" then
            local uv = {tonumber(splitLine[2]), tonumber(splitLine[3])}
            table.insert(meshData.uvs, uv)
        elseif splitLine[1] == "vn" then
            local normal = {tonumber(splitLine[2]), tonumber(splitLine[3]), tonumber(splitLine[4])}
            table.insert(meshData.normals, normal)
        elseif splitLine[1] == "f" then
            for k = 2,4 do
                local face = splitAlongDelimiterAndExtract(splitLine[k], "/")
                face = {tonumber(face[1]), tonumber(face[2]), tonumber(face[3])}
                local vert = meshData.vertices[face[1]]
                local uv = meshData.uvs[face[2]]
                local norm = meshData.normals[face[3]]
                -- ignore normals for now
                local trueFace = {vert[1], vert[2], vert[3], uv[1], uv[2], norm[1], norm[2], norm[3]}
                table.insert(meshData.faces, trueFace)
            end
        end
    end

    -- uncomment to debug obj loading
    -- for k = 1,#meshData.faces do
    --     local currentFace = meshData.faces[k]
    --     local str = "face " .. k .. ":"
    --     for k2 = 1,#currentFace do
    --         str = str .. currentFace[k2] .. ","
    --     end
    --     print(str)
    -- end

    -- If you're missing triangles, it's likely because blender is using quads.
    -- Go to edit mode -> press A to select all -> hit CTRL+T to triangulate faces -> export as obj
    -- this will ensure we don't miss triangles in our obj loading.
    -- https://blender.stackexchange.com/questions/19253/how-to-make-all-polygons-into-triangles
    return love.graphics.newMesh(vertexFormat, meshData.faces, "triangles", "static")
end

function Mesh.drawGLTF(mesh, x, y, z, rx, ry, rz, sx, sy, sz, shader, fcn, obj)
    shader = shader or Mesh.defaultGLTFShader
    love.graphics.setColor(1,1,1,1)
    love.graphics.setShader(shader)
    local useViewMatrix = obj.useViewMatrix == nil and true or obj.useViewMatrix
    shader:send("viewMatrix", useViewMatrix and Camera3D.viewMatrix or Mesh.identityMatrix)
    shader:send("projectionMatrix", Camera3D.projectionMatrix)
    if not fcn then
        shader:send("ambientLighting", obj.ambientLighting or Lighting3D.ambientLighting)
        Lighting3D.sendShader(shader)
    elseif shader then
        fcn(shader, obj)
    end

    -- Send joint matrix data
    for k = 1,#mesh.jointMap do
        local currentJointNode = mesh.allNodes[mesh.jointMap[k]]
        -- We did it. Our original problem was that our matrix mult code was column major, not row major lol.
        -- We can just do:
        -- World transform * IBM and we get the joint matrix, as per the tutorial.
        Matrix.multiplyInto(currentJointNode.transform, currentJointNode.inverseBindMatrix, currentJointNode.tempMatrix)
        mesh.allJointMatrices[k] = currentJointNode.tempMatrix
    end
    -- This basically does the same thing as:
    -- shader:send('jointMatrices', mat1, mat2, mat3, ...) and so on
    shader:send("jointMatrices",  unpack(mesh.allJointMatrices))
    Matrix.setFromTRS(Mesh.modelMatrix, x, y, z, math.rad(rx), math.rad(ry), math.rad(rz), nil, sx, sy, sz)

    shader:send("modelMatrix", Mesh.modelMatrix)
    love.graphics.draw(mesh.loveMesh)
    love.graphics.setShader()

    Mesh.resetModelMatrix()
end

function Mesh.draw(mesh, x, y, z, rx, ry, rz, sx, sy, sz, shader, fcn, obj)
    shader = shader or Mesh.defaultShader
    love.graphics.setColor(1,1,1,1)
    love.graphics.setShader(shader)
    local useViewMatrix = obj.useViewMatrix == nil and true or obj.useViewMatrix
    shader:send("viewMatrix", useViewMatrix and Camera3D.viewMatrix or Mesh.identityMatrix)
    shader:send("projectionMatrix", Camera3D.projectionMatrix)
    if not fcn then
        shader:send("ambientLighting", obj.ambientLighting or Lighting3D.ambientLighting)
        Lighting3D.sendShader(shader)
    elseif shader then
        fcn(shader, obj)
    end

    Matrix.setFromTRS(Mesh.modelMatrix, x, y, z, math.rad(rx), math.rad(ry), math.rad(rz), nil, sx, sy, sz)

    if Mesh.modelMatrix then
        shader:send("modelMatrix", Mesh.modelMatrix)
    else
        print("something broke, the mesh model matrix is nil???")
        shader:send("modelMatrix", Mesh.identityMatrix)
    end
    love.graphics.draw(mesh)
    love.graphics.setShader()

    Mesh.resetModelMatrix()
end


return Mesh