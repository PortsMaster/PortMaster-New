local Camera3D = {}
local defaultProjection = "perspective" -- "perspective" or "orthographic"
function Camera3D.initialize(fov, near, far, aspectRatio)
    fov = fov or math.pi/4
    near = near or 0.1
    far = far or 400
    aspectRatio = aspectRatio or love.graphics.getWidth()/love.graphics.getHeight()
    Camera3D.fov = fov
    Camera3D.near = near
    Camera3D.far = far
    Camera3D.aspectRatio = aspectRatio
    Camera3D.orthoSize = 80
    Camera3D.orthoSizeTarget = 80
    Camera3D.zoomOrtho = false

    Camera3D.projectionMatrix = Matrix.identityMatrix()
    Camera3D.setProjection(defaultProjection)

    Camera3D.sensitivity = 0.1
    Camera3D.position = {
        x=0,y=0,z=0
    }
    Camera3D.target = {
        x=0,y=0,z=0
    }
    Camera3D.down = {
        x=0,y=-1,z=0
    }
    Camera3D.viewMatrix = {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    }
    Camera3D.rotation = {
        pitch = 0,
        yaw = 90
    }
    -- obj = camera matrix determined by position and offset from target obj
    -- nil = camera matrix determined by position and rotations of camera itself
    Camera3D.targetObj = nil
    Camera3D.targetOffset = {x=0,y=0,z=0}
    Camera3D.followKP = 10
    Camera3D.ignoreDT = false
    -- These 3 are used for orbital cameras, i.e for a 3rd person camera.
    -- Instead of using an xyz offset, it uses an angle offset, a radial offset, and an anchor point.
    -- All tgt_properties are the targets, and non tgt properties lerp to the tgt properties.
    Camera3D.useAngleOffset = false
    Camera3D.angleOffset = 0
    Camera3D.tgtAngleOffset = 0
    Camera3D.angleKP = 10 -- for the camera angle lerp
    Camera3D.angleRadius = 0
    Camera3D.tgtAngleRadius = 0
    -- We can think of the anchorObj as the 'parent' in another game engine. This is the object that the camera's angle/radius offset are relative to.
    Camera3D.anchorObj = nil -- camera position relative to the anchor is determined by angle, radius, and a y offset (future: we could have it be determined by 2 angles and an offset for a fuly orbiting camera)
    Camera3D.anchorPos = {x=0,y=0,z=0} -- The camera's anchor position, which lerps to the anchorObj. This is the true position we use for angle/radius offsets
    Camera3D.anchorYOffset = 0 -- Currently we only have a camera that orbits in the x-z plane, so the Y position is described simply by an offset.
end

function Camera3D.setProjection(projection)
    local camProjMat = Camera3D.projectionMatrix
    local fov = Camera3D.fov
    local aspectRatio = Camera3D.aspectRatio
    local far = Camera3D.far
    local near = Camera3D.near
    local f = 1/math.tan(fov/2) -- cotangent fov/2

    if projection == "perspective" then -- for boss finishers
        -- https://registry.khronos.org/OpenGL-Refpages/gl2.1/xhtml/gluPerspective.xml
        camProjMat[1],camProjMat[2],camProjMat[3],camProjMat[4] = f/aspectRatio, 0, 0, 0
        camProjMat[5],camProjMat[6],camProjMat[7],camProjMat[8] = 0, f, 0, 0
        camProjMat[9],camProjMat[10],camProjMat[11],camProjMat[12] = 0, 0, (far + near)/(near - far), 2*far*near/(near-far)
        camProjMat[13],camProjMat[14],camProjMat[15],camProjMat[16] = 0, 0, -1, 0
    elseif projection == "orthographic" then
        -- https://registry.khronos.org/OpenGL-Refpages/gl2.1/xhtml/glOrtho.xml
        local top = Camera3D.orthoSize * math.tan(fov/2)
        local bottom = -top
        local right = top*aspectRatio
        local left = -right
        local tX = -(right+left)/(right-left)
        local tY = -(top + bottom) / (top - bottom)
        local tZ = -(far + near) / (far - near)
        camProjMat[1],camProjMat[2],camProjMat[3],camProjMat[4] = 2/(right-left), 0, 0, tX
        camProjMat[5],camProjMat[6],camProjMat[7],camProjMat[8] = 0, 2/(top-bottom), 0, tY
        camProjMat[9],camProjMat[10],camProjMat[11],camProjMat[12] = 0, 0, -2/(far-near), tZ
        camProjMat[13],camProjMat[14],camProjMat[15],camProjMat[16] = 0, 0, 0, 1
    end
end

function Camera3D.forward()
    return normalize3D(Camera3D.target.x - Camera3D.position.x, Camera3D.target.y - Camera3D.position.y, Camera3D.target.z - Camera3D.position.z)
end

function Camera3D.computeViewMatrix()
    if not Camera3D.targetObj then
        local dX, dY, dZ
        dX = math.cos(math.rad(Camera3D.rotation.yaw)) * math.cos(math.rad(Camera3D.rotation.pitch))
        dY = math.sin(math.rad(Camera3D.rotation.pitch))
        dZ = math.sin(math.rad(Camera3D.rotation.yaw)) * math.cos(math.rad(Camera3D.rotation.pitch))
        dX, dY, dZ = normalize3D(dX, dY, dZ)
        Camera3D.target.x = Camera3D.position.x + dX * 5
        Camera3D.target.y = Camera3D.position.y + dY * 5
        Camera3D.target.z = Camera3D.position.z + dZ * 5
    end

    -- https://www.geertarien.com/blog/2017/07/30/breakdown-of-the-lookAt-function-in-OpenGL/
    local zx, zy, zz = normalize3D(Camera3D.position.x - Camera3D.target.x, Camera3D.position.y - Camera3D.target.y, Camera3D.position.z - Camera3D.target.z)
    local xx, xy, xz = normalize3D(cross3D(Camera3D.down.x, Camera3D.down.y, Camera3D.down.z, zx, zy, zz))
    local yx, yy, yz = cross3D(zx, zy, zz, xx, xy, xz)
    Camera3D.viewMatrix[1] = xx
    Camera3D.viewMatrix[2] = xy
    Camera3D.viewMatrix[3] = xz
    Camera3D.viewMatrix[4] = -1*dot3D(xx, xy, xz, Camera3D.position.x, Camera3D.position.y, Camera3D.position.z)

    Camera3D.viewMatrix[5] = yx
    Camera3D.viewMatrix[6] = yy
    Camera3D.viewMatrix[7] = yz
    Camera3D.viewMatrix[8] = -1*dot3D(yx, yy, yz, Camera3D.position.x, Camera3D.position.y, Camera3D.position.z)

    Camera3D.viewMatrix[9] = zx
    Camera3D.viewMatrix[10] = zy
    Camera3D.viewMatrix[11] = zz
    Camera3D.viewMatrix[12] = -1*dot3D(zx, zy, zz, Camera3D.position.x, Camera3D.position.y, Camera3D.position.z)
end

function Camera3D.update(dt, trueDT)
    if Camera3D.ignoreDT then
        dt = trueDT
    end
    if Camera3D.targetObj then
        Camera3D.target.x = lerp(Camera3D.target.x, Camera3D.targetObj.x, dt * Camera3D.followKP)
        Camera3D.target.y = lerp(Camera3D.target.y, Camera3D.targetObj.y, dt * Camera3D.followKP)
        Camera3D.target.z = lerp(Camera3D.target.z, Camera3D.targetObj.z, dt * Camera3D.followKP)

        if Camera3D.useAngleOffset then
            Camera3D.angleRadius = lerp(Camera3D.angleRadius, Camera3D.tgtAngleRadius, dt * Camera3D.followKP)
            Camera3D.angleOffset = lerpAngle(Camera3D.angleOffset, Camera3D.tgtAngleOffset, dt * Camera3D.angleKP)

            Camera3D.anchorPos.x = lerp(Camera3D.anchorPos.x, Camera3D.anchorObj.x, dt * Camera3D.followKP)
            Camera3D.anchorPos.y = lerp(Camera3D.anchorPos.y, Camera3D.anchorObj.y, dt * Camera3D.followKP)
            Camera3D.anchorPos.z = lerp(Camera3D.anchorPos.z, Camera3D.anchorObj.z, dt * Camera3D.followKP)

            local tgtX = Camera3D.anchorPos.x + math.sin(math.rad(Camera3D.angleOffset)) * Camera3D.angleRadius
            local tgtZ = Camera3D.anchorPos.z + math.cos(math.rad(Camera3D.angleOffset)) * Camera3D.angleRadius
            Camera3D.position.x = tgtX
            Camera3D.position.y = Camera3D.anchorPos.y + Camera3D.anchorYOffset
            Camera3D.position.z = tgtZ
        else
            Camera3D.position.x = lerp(Camera3D.position.x, Camera3D.targetObj.x + Camera3D.targetOffset.x, dt * Camera3D.followKP)
            Camera3D.position.y = lerp(Camera3D.position.y, Camera3D.targetObj.y + Camera3D.targetOffset.y, dt * Camera3D.followKP)
            Camera3D.position.z = lerp(Camera3D.position.z, Camera3D.targetObj.z + Camera3D.targetOffset.z, dt * Camera3D.followKP)
        end
    end
    if Camera3D.zoomOrtho then
        Camera3D.orthoSize = lerp(Camera3D.orthoSize, Camera3D.orthoSizeTarget, dt * Camera3D.followKP)
        Camera3D.setProjection("orthographic")
        if math.abs(Camera3D.orthoSize - Camera3D.orthoSizeTarget) < 0.5 then
            Camera3D.orthoSize = Camera3D.orthoSizeTarget
            Camera3D.zoomOrtho = false
        end
    end
    Camera3D.computeViewMatrix()
end

function Camera3D.FPSControls(dX, dY)
    -- Get rid of this if you want FPS controls
    if true then
        return
    end
    local xOffset = dX * Camera3D.sensitivity
    local yOffset = dY * Camera3D.sensitivity

    Camera3D.rotation.yaw = Camera3D.rotation.yaw - xOffset
    Camera3D.rotation.pitch = Camera3D.rotation.pitch - yOffset
    if Camera3D.rotation.pitch > 88 then
        Camera3D.rotation.pitch = 88
    elseif Camera3D.rotation.pitch < -88 then
        Camera3D.rotation.pitch = -88
    end
end

function Camera3D.jumpToTarget()
    Camera3D.target.x = Camera3D.targetObj.x
    Camera3D.target.y = Camera3D.targetObj.y
    Camera3D.target.z = Camera3D.targetObj.z


    if Camera3D.useAngleOffset then
        Camera3D.angleOffset = Camera3D.tgtAngleOffset
        local tgtX = Camera3D.targetObj.x + math.sin(math.rad(Camera3D.angleOffset)) * Camera3D.angleRadius
        local tgtZ = Camera3D.targetObj.z + math.cos(math.rad(Camera3D.angleOffset)) * Camera3D.angleRadius
        Camera3D.position.x = tgtX
        Camera3D.position.y = Camera3D.targetObj.y + Camera3D.targetOffset.y
        Camera3D.position.z = tgtZ
    else
        Camera3D.position.x = Camera3D.targetObj.x + Camera3D.targetOffset.x
        Camera3D.position.y = Camera3D.targetObj.y + Camera3D.targetOffset.y
        Camera3D.position.z = Camera3D.targetObj.z + Camera3D.targetOffset.z
    end
end


return Camera3D