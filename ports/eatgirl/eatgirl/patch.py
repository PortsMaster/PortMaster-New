#!/usr/bin/env python3
"""
Apply Eat Girl PortMaster optimizations to a .love file.
"""
import sys, os, zipfile

P = {}  # filename -> list of (old, new) string pairs


P["lib/ripple.lua"] = [
    ("function Instance:__newindex(key, value)\n"
     "\tif key == 'pitch' then",
     "function Instance:__newindex(key, value)\n"
     "\tif type(value) == \"boolean\" then value = 1 end\n"
     "\tvalue = math.abs(value)\n"
     "\tif value == 0 then value = 1 end\n"
     "\tif key == 'pitch' then"),
]

P["class/game/barrier.lua"] = [
    ("function Barrier:drawWorld()\n"
     "\tlove.graphics.push 'all'",
     "function Barrier:drawWorld()\n"
     "\t--[[\n"
     "\t\tthe band spans the whole map horizontally so only its vertical extent can\n"
     "\t\tbe culled, but that alone skips it for nearly all of the world map.\n"
     "\t]]\n"
     "\tlocal top = self.y - self.canvasPadding\n"
     "\tlocal cameraY = self.drawWorldSystem.cameraY\n"
     "\tif top > cameraY + constant.screenHeight/2 then return end\n"
     "\tif top + constant.screenHeight < cameraY - constant.screenHeight/2 then return end\n"
     "\tlove.graphics.push 'all'"),
]

#[[
#    processCollisions and wouldBeStopped scanned every physical entity, and
#    gridbound movement calls them once per pixel travelled. On the world map
#    (445 physical / 374 solid) that measured 3148 collides() per frame while
#    moving. A uniform-grid broadphase cuts it to the handful actually nearby.
#]]
P["system/physical.lua"] = [
    ("local util = require 'util'\n"
     "\n"
     "local physical = {}\n"
     "\n"
     "function physical:add(e)\n"
     "\tif not self.pool.groups.physical.hasEntity[e] then return end\n"
     "\te.collidesWith = {}\n"
     "\te.xRemainder = 0\n"
     "\te.yRemainder = 0\n"
     "\tself:processCollisions(e)\n"
     "end",
     "local util = require 'util'\n"
     "\n"
     "local physical = {}\n"
     "\n"
     "local CELL_SIZE = 64\n"
     "--[[\n"
     "\tthe index is rebuilt once per frame, so an entity can drift away from the\n"
     "\tcell it was filed under before the next rebuild. inflating queries by the\n"
     "\tfurthest anything can travel in one frame keeps that drift from hiding a\n"
     "\tcollision. 210 is the player's blue flame speed, 2 the fastest game speed rule.\n"
     "]]\n"
     "local MAX_ENTITY_SPEED = 210 * 2\n"
     "local WORST_CASE_FRAME_RATE = 15\n"
     "local QUERY_MARGIN = math.ceil(MAX_ENTITY_SPEED / WORST_CASE_FRAME_RATE)\n"
     "-- the world map barrier spans the entire map; smearing it over every cell\n"
     "-- would defeat the index, so outsized entities are tested unconditionally\n"
     "local MAX_INDEXED_CELLS = 64\n"
     "\n"
     "function physical:init()\n"
     "\tself.grid = {}\n"
     "\tself.gridOversized = {}\n"
     "\tself.gridIsBuilt = false\n"
     "end\n"
     "\n"
     "function physical:indexEntity(e)\n"
     "\tlocal cx1, cy1 = math.floor(e.x / CELL_SIZE), math.floor(e.y / CELL_SIZE)\n"
     "\tlocal cx2, cy2 = math.floor((e.x + e.w) / CELL_SIZE), math.floor((e.y + e.h) / CELL_SIZE)\n"
     "\tif (cx2 - cx1 + 1) * (cy2 - cy1 + 1) > MAX_INDEXED_CELLS then\n"
     "\t\tlocal oversized = self.gridOversized\n"
     "\t\toversized[#oversized + 1] = e\n"
     "\t\treturn\n"
     "\tend\n"
     "\tlocal grid = self.grid\n"
     "\tfor cx = cx1, cx2 do\n"
     "\t\tlocal column = grid[cx]\n"
     "\t\tif not column then column = {}; grid[cx] = column end\n"
     "\t\tfor cy = cy1, cy2 do\n"
     "\t\t\tlocal cell = column[cy]\n"
     "\t\t\tif not cell then cell = {}; column[cy] = cell end\n"
     "\t\t\tcell[#cell + 1] = e\n"
     "\t\tend\n"
     "\tend\n"
     "end\n"
     "\n"
     "function physical:buildGrid()\n"
     "\t-- cells are emptied rather than dropped so the tables survive between frames\n"
     "\tfor _, column in pairs(self.grid) do\n"
     "\t\tfor _, cell in pairs(column) do\n"
     "\t\t\tfor i = #cell, 1, -1 do cell[i] = nil end\n"
     "\t\tend\n"
     "\tend\n"
     "\tlocal oversized = self.gridOversized\n"
     "\tfor i = #oversized, 1, -1 do oversized[i] = nil end\n"
     "\tfor _, e in ipairs(self.pool.groups.physical.entities) do\n"
     "\t\tself:indexEntity(e)\n"
     "\tend\n"
     "\tself.gridIsBuilt = true\n"
     "end\n"
     "\n"
     "function physical:update(dt)\n"
     "\tself.gridIsBuilt = false\n"
     "end\n"
     "\n"
     "--[[\n"
     "\treturns a fresh list of entities that could overlap e (offset by dx, dy).\n"
     "\tthe list is not reused between calls because onCollide handlers can trigger\n"
     "\tnested queries, which would otherwise clobber a shared buffer.\n"
     "]]\n"
     "function physical:getNearby(e, dx, dy)\n"
     "\tif not self.gridIsBuilt then self:buildGrid() end\n"
     "\tlocal x, y = e.x + (dx or 0) - QUERY_MARGIN, e.y + (dy or 0) - QUERY_MARGIN\n"
     "\tlocal w, h = e.w + 2 * QUERY_MARGIN, e.h + 2 * QUERY_MARGIN\n"
     "\tlocal cx1, cy1 = math.floor(x / CELL_SIZE), math.floor(y / CELL_SIZE)\n"
     "\tlocal cx2, cy2 = math.floor((x + w) / CELL_SIZE), math.floor((y + h) / CELL_SIZE)\n"
     "\tlocal nearby, count, seen = {}, 0, {}\n"
     "\tlocal grid = self.grid\n"
     "\tfor cx = cx1, cx2 do\n"
     "\t\tlocal column = grid[cx]\n"
     "\t\tif column then\n"
     "\t\t\tfor cy = cy1, cy2 do\n"
     "\t\t\t\tlocal cell = column[cy]\n"
     "\t\t\t\tif cell then\n"
     "\t\t\t\t\tfor i = 1, #cell do\n"
     "\t\t\t\t\t\tlocal other = cell[i]\n"
     "\t\t\t\t\t\tif not seen[other] then\n"
     "\t\t\t\t\t\t\tseen[other] = true\n"
     "\t\t\t\t\t\t\tcount = count + 1\n"
     "\t\t\t\t\t\t\tnearby[count] = other\n"
     "\t\t\t\t\t\tend\n"
     "\t\t\t\t\tend\n"
     "\t\t\t\tend\n"
     "\t\t\tend\n"
     "\t\tend\n"
     "\tend\n"
     "\tlocal oversized = self.gridOversized\n"
     "\tfor i = 1, #oversized do\n"
     "\t\tlocal other = oversized[i]\n"
     "\t\tif not seen[other] then\n"
     "\t\t\tseen[other] = true\n"
     "\t\t\tcount = count + 1\n"
     "\t\t\tnearby[count] = other\n"
     "\t\tend\n"
     "\tend\n"
     "\treturn nearby, count\n"
     "end\n"
     "\n"
     "function physical:add(e)\n"
     "\tif not self.pool.groups.physical.hasEntity[e] then return end\n"
     "\te.collidesWith = {}\n"
     "\te.xRemainder = 0\n"
     "\te.yRemainder = 0\n"
     "\t-- file it immediately so entities spawned this frame are still collidable\n"
     "\tif self.gridIsBuilt then self:indexEntity(e) end\n"
     "\tself:processCollisions(e)\n"
     "end"),
    ("function physical:wouldBeStopped(e, dx, dy)\n"
     "\tfor _, solid in ipairs(self.pool.groups.solid.entities) do\n"
     "\t\tif self:wouldSolidStop(solid, e) and self:collides(e, solid, dx, dy) then\n"
     "\t\t\treturn true\n"
     "\t\tend\n"
     "\tend\n"
     "\treturn false\n"
     "end",
     "function physical:wouldBeStopped(e, dx, dy)\n"
     "\tlocal nearby, count = self:getNearby(e, dx, dy)\n"
     "\tfor i = 1, count do\n"
     "\t\tlocal solid = nearby[i]\n"
     "\t\tif solid.solid and self:wouldSolidStop(solid, e) and self:collides(e, solid, dx, dy) then\n"
     "\t\t\treturn true\n"
     "\t\tend\n"
     "\tend\n"
     "\treturn false\n"
     "end"),
    ("function physical:processCollisions(e, dx, dy)\n"
     "\tlocal stopped = false\n"
     "\tfor _, other in ipairs(self.pool.groups.physical.entities) do\n"
     "\t\tlocal collides = self:collides(e, other, dx, dy)\n"
     "\t\tif collides and not e.collidesWith[other] then\n"
     "\t\t\tself.pool:emit('onCollide', e, other)\n"
     "\t\t\tself.pool:emit('onCollide', other, e)\n"
     "\t\t\te.collidesWith[other] = true\n"
     "\t\t\tother.collidesWith[e] = true\n"
     "\t\telseif not collides and e.collidesWith[other] then\n"
     "\t\t\tself.pool:emit('onEndCollision', e, other)\n"
     "\t\t\tself.pool:emit('onEndCollision', other, e)\n"
     "\t\t\te.collidesWith[other] = nil\n"
     "\t\t\tother.collidesWith[e] = nil\n"
     "\t\tend\n"
     "\t\tif collides and other.solid and self:wouldSolidStop(other, e) then\n"
     "\t\t\tself.pool:emit('onStoppedBySolid', e, other)\n"
     "\t\t\tstopped = true\n"
     "\t\tend\n"
     "\tend\n"
     "\treturn stopped\n"
     "end",
     "function physical:processCollisions(e, dx, dy)\n"
     "\tlocal stopped = false\n"
     "\tlocal nearby, count = self:getNearby(e, dx, dy)\n"
     "\tlocal wasChecked = {}\n"
     "\tfor i = 1, count do\n"
     "\t\tlocal other = nearby[i]\n"
     "\t\twasChecked[other] = true\n"
     "\t\tlocal collides = self:collides(e, other, dx, dy)\n"
     "\t\tif collides and not e.collidesWith[other] then\n"
     "\t\t\tself.pool:emit('onCollide', e, other)\n"
     "\t\t\tself.pool:emit('onCollide', other, e)\n"
     "\t\t\te.collidesWith[other] = true\n"
     "\t\t\tother.collidesWith[e] = true\n"
     "\t\telseif not collides and e.collidesWith[other] then\n"
     "\t\t\tself.pool:emit('onEndCollision', e, other)\n"
     "\t\t\tself.pool:emit('onEndCollision', other, e)\n"
     "\t\t\te.collidesWith[other] = nil\n"
     "\t\t\tother.collidesWith[e] = nil\n"
     "\t\tend\n"
     "\t\tif collides and other.solid and self:wouldSolidStop(other, e) then\n"
     "\t\t\tself.pool:emit('onStoppedBySolid', e, other)\n"
     "\t\t\tstopped = true\n"
     "\t\tend\n"
     "\tend\n"
     "\t--[[\n"
     "\t\tthe broadphase covers everything within reach, so a partner it didn't\n"
     "\t\treturn has definitely separated and needs its collision ended here --\n"
     "\t\tthe full-pool scan used to do this implicitly.\n"
     "\t]]\n"
     "\tfor other in pairs(e.collidesWith) do\n"
     "\t\tif not wasChecked[other] then\n"
     "\t\t\tself.pool:emit('onEndCollision', e, other)\n"
     "\t\t\tself.pool:emit('onEndCollision', other, e)\n"
     "\t\t\te.collidesWith[other] = nil\n"
     "\t\t\tother.collidesWith[e] = nil\n"
     "\t\tend\n"
     "\tend\n"
     "\treturn stopped\n"
     "end"),
]

P["class/game/vortex/vortex.lua"] = [
    ("Vortex.segments = 64",
     "Vortex.segments = 64\n"
     "-- keep vortexes alive slightly past the screen edge so particles don't pop in\n"
     "Vortex.cullPadding = 32\n"
     "Vortex.whiteCircleSegments = 64"),
    ("function Vortex:new(pool, x, y)\n"
     "\tself.timers = tick.group()\n"
     "\tself.tweens = flux.group()\n"
     "\tself.pool = pool",
     "function Vortex:new(pool, x, y)\n"
     "\tself.timers = tick.group()\n"
     "\tself.tweens = flux.group()\n"
     "\tself.pool = pool\n"
     "\tself.drawWorldSystem = pool:getSystem(require 'system.draw-world')"),
    #[[
    #    the world map holds 28 vortexes, each with 3 particle systems. simulating
    #    and drawing all 84 off-screen costs more than everything else on the map
    #    combined, so suspend the ones the camera can't see.
    #]]
    ("function Vortex:update(dt)\n"
     "\tself.timers:update(dt)\n"
     "\tself.tweens:update(dt)\n"
     "\n"
     "\tlocal radius = self:getRadius()\n"
     "\tfor _, particleSystem in ipairs(self.particleSystems) do\n"
     "\t\tparticleSystem:setEmissionArea('borderellipse', radius, radius, 0, true)\n"
     "\t\tparticleSystem:setEmissionRate(radius)\n"
     "\t\tparticleSystem:setRadialAcceleration(-radius * 2, -radius * 3)\n"
     "\t\tparticleSystem:setTangentialAcceleration(0, radius * .5)\n"
     "\t\tparticleSystem:update(dt)\n"
     "\t\tif self.emitParticles then\n"
     "\t\t\tparticleSystem:start()\n"
     "\t\telse\n"
     "\t\t\tparticleSystem:stop()\n"
     "\t\tend\n"
     "\tend\n"
     "end",
     "function Vortex:isNearCamera()\n"
     "\t-- the enter/circle-out animation covers the screen from an arbitrary position\n"
     "\tif self.animating or self.playingCircleOutAnimation then return true end\n"
     "\tlocal padding = math.max(self:getRadius(), self.whiteCircleRadius) + self.cullPadding\n"
     "\treturn self.drawWorldSystem:isNearCamera(self.x, self.y, padding)\n"
     "end\n"
     "\n"
     "function Vortex:update(dt)\n"
     "\tself.timers:update(dt)\n"
     "\tself.tweens:update(dt)\n"
     "\n"
     "\tif not self:isNearCamera() then\n"
     "\t\tself.particlesSuspended = true\n"
     "\t\treturn\n"
     "\tend\n"
     "\t-- drop the particles frozen at suspend time instead of resuming them mid-flight\n"
     "\tif self.particlesSuspended then\n"
     "\t\tself.particlesSuspended = false\n"
     "\t\tself.particleRadius = nil\n"
     "\t\tfor _, particleSystem in ipairs(self.particleSystems) do\n"
     "\t\t\tparticleSystem:reset()\n"
     "\t\tend\n"
     "\tend\n"
     "\n"
     "\tlocal radius = self:getRadius()\n"
     "\tlocal radiusChanged = radius ~= self.particleRadius\n"
     "\tself.particleRadius = radius\n"
     "\tfor _, particleSystem in ipairs(self.particleSystems) do\n"
     "\t\tif radiusChanged then\n"
     "\t\t\tparticleSystem:setEmissionArea('borderellipse', radius, radius, 0, true)\n"
     "\t\t\tparticleSystem:setEmissionRate(radius)\n"
     "\t\t\tparticleSystem:setRadialAcceleration(-radius * 2, -radius * 3)\n"
     "\t\t\tparticleSystem:setTangentialAcceleration(0, radius * .5)\n"
     "\t\tend\n"
     "\t\tparticleSystem:update(dt)\n"
     "\t\tif self.emitParticles then\n"
     "\t\t\tparticleSystem:start()\n"
     "\t\telse\n"
     "\t\t\tparticleSystem:stop()\n"
     "\t\tend\n"
     "\tend\n"
     "end"),
    # a radius-0 circle still tessellates 512 segments, once per vortex per frame
    ("function Vortex:drawWhiteCircle()\n"
     "\tlove.graphics.push 'all'\n"
     "\tlove.graphics.setColor(color.white)\n"
     "\tlove.graphics.circle('fill', self.x, self.y, self.whiteCircleRadius, 512)\n"
     "\tlove.graphics.pop()\n"
     "end",
     "function Vortex:drawWhiteCircle()\n"
     "\tif self.whiteCircleRadius <= 0 then return end\n"
     "\tlove.graphics.push 'all'\n"
     "\tlove.graphics.setColor(color.white)\n"
     "\tlove.graphics.circle('fill', self.x, self.y, self.whiteCircleRadius, self.whiteCircleSegments)\n"
     "\tlove.graphics.pop()\n"
     "end"),
    ("function Vortex:drawWorld()\n"
     "\tself:drawBody 'line'",
     "function Vortex:drawWorld()\n"
     "\tif not self:isNearCamera() then return end\n"
     "\tself:drawBody 'line'"),
]

#[[
#    The Temple (world map) and Escape backgrounds each build 3 parallax layers of
#    500 diamonds and redraw all 1500 every frame, with a full graphics-state push
#    per diamond and no culling -- they are spread across the map divided by the
#    parallax depth, tens of screens wide, so almost none are visible. This was the
#    single largest draw cost on the world map.
#]]
_BACKGROUND_FIXES = [
    ("\tself.rainShaderTime = love.math.random() * 100",
     "\tself.rainShaderTime = love.math.random() * 100\n"
     "\tself.elapsed = 0"),
    ("\tfor _, layer in ipairs(self.layers) do\n"
     "\t\tfor _, diamond in ipairs(layer.diamonds) do\n"
     "\t\t\tdiamond.angle = diamond.angle + diamond.angularVelocity * self.baseRotationSpeed * dt\n"
     "\t\tend\n"
     "\tend\n"
     "\tself.rainShaderTime = self.rainShaderTime + dt",
     "\t-- rotation is derived from elapsed time, so the diamonds need no per-frame pass\n"
     "\tself.elapsed = self.elapsed + dt\n"
     "\tself.rainShaderTime = self.rainShaderTime + dt"),
    ("\t\tlove.graphics.setColor(layer.color)\n"
     "\t\tlove.graphics.translate(-cameraX * layer.depth, -cameraY * layer.depth)\n"
     "\t\tfor _, diamond in ipairs(layer.diamonds) do\n"
     "\t\t\tself:drawDiamond(diamond)\n"
     "\t\tend",
     "\t\tlove.graphics.setColor(layer.color)\n"
     "\t\tlocal offsetX, offsetY = cameraX * layer.depth, cameraY * layer.depth\n"
     "\t\tlove.graphics.translate(-offsetX, -offsetY)\n"
     "\t\tfor _, diamond in ipairs(layer.diamonds) do\n"
     "\t\t\tlocal x, y = diamond.x - offsetX, diamond.y - offsetY\n"
     "\t\t\tif x + diamond.radius >= 0 and x - diamond.radius <= constant.screenWidth\n"
     "\t\t\t\t\tand y + diamond.radius >= 0 and y - diamond.radius <= constant.screenHeight then\n"
     "\t\t\t\tself:drawDiamond(diamond)\n"
     "\t\t\tend\n"
     "\t\tend"),
]

# drawDiamond differs only in segment count between the two backgrounds
def _diamond_fix(segments):
    return (
        "\tlove.graphics.push 'all'\n"
        "\tlove.graphics.translate(diamond.x, diamond.y)\n"
        "\tlove.graphics.rotate(diamond.angle)\n"
        "\tlove.graphics.circle('fill', 0, 0, diamond.radius, %s)\n"
        "\tlove.graphics.pop()" % segments,
        "\t-- push 'all' saved the entire graphics state per diamond; only the transform changes\n"
        "\tlove.graphics.push()\n"
        "\tlove.graphics.translate(diamond.x, diamond.y)\n"
        "\tlove.graphics.rotate(diamond.angle\n"
        "\t\t+ diamond.angularVelocity * self.baseRotationSpeed * self.elapsed)\n"
        "\tlove.graphics.circle('fill', 0, 0, diamond.radius, %s)\n"
        "\tlove.graphics.pop()" % segments,
    )

P["background/temple.lua"] = _BACKGROUND_FIXES + [_diamond_fix(4)]
P["background/escape.lua"] = _BACKGROUND_FIXES + [_diamond_fix(8)]

P["class/game/maze-graphics.lua"] = [
    ("function MazeGraphics:new(map)\n"
     "\tself.map = map\n"
     "\tlocal geometryTileset = self.map.tilesets['geometry 1']\n"
     "\tlocal geometry = self.map.layers.geometry\n"
     "\tfor _, _, x, y in geometry:getTiles() do\n"
     "\t\tlocal left = not geometry:getTileAtGridPosition(x - 1, y)\n"
     "\t\tlocal right = not geometry:getTileAtGridPosition(x + 1, y)\n"
     "\t\tlocal top = not geometry:getTileAtGridPosition(x, y - 1)\n"
     "\t\tlocal bottom = not geometry:getTileAtGridPosition(x, y + 1)\n"
     "\t\tlocal tileType\n"
     "\t\tif left and right and top and bottom then\n"
     "\t\t\ttileType = 'island'\n"
     "\t\telseif left and right and top then\n"
     "\t\t\ttileType = 'top'\n"
     "\t\telseif left and right and bottom then\n"
     "\t\t\ttileType = 'bottom'\n"
     "\t\telseif left and top and bottom then\n"
     "\t\t\ttileType = 'left'\n"
     "\t\telseif right and top and bottom then\n"
     "\t\t\ttileType = 'right'\n"
     "\t\telseif top and left then\n"
     "\t\t\ttileType = 'topLeft'\n"
     "\t\telseif top and right then\n"
     "\t\t\ttileType = 'topRight'\n"
     "\t\telseif bottom and right then\n"
     "\t\t\ttileType = 'bottomRight'\n"
     "\t\telseif bottom and left then\n"
     "\t\t\ttileType = 'bottomLeft'\n"
     "\t\telse\n"
     "\t\t\ttileType = 'normal'\n"
     "\t\tend\n"
     "\t\tgeometry:setTileAtGridPosition(x, y, geometryTileset.firstgid + tileIds[tileType])\n"
     "\tend\n"
     "\tself.spikes = self.map.layers.spikes\n"
     "end",
     "function MazeGraphics:new(map)\n"
     "\tself.map = map\n"
     "\tlocal geometryTileset = self.map.tilesets['geometry 1']\n"
     "\tlocal geometry = self.map.layers.geometry\n"
     "\tif not self.map.properties.worldMap then\n"
     "\t\tfor _, _, x, y in geometry:getTiles() do\n"
     "\t\t\tlocal left = not geometry:getTileAtGridPosition(x - 1, y)\n"
     "\t\t\tlocal right = not geometry:getTileAtGridPosition(x + 1, y)\n"
     "\t\t\tlocal top = not geometry:getTileAtGridPosition(x, y - 1)\n"
     "\t\t\tlocal bottom = not geometry:getTileAtGridPosition(x, y + 1)\n"
     "\t\t\tlocal tileType\n"
     "\t\t\tif left and right and top and bottom then\n"
     "\t\t\t\ttileType = 'island'\n"
     "\t\t\telseif left and right and top then\n"
     "\t\t\t\ttileType = 'top'\n"
     "\t\t\telseif left and right and bottom then\n"
     "\t\t\t\ttileType = 'bottom'\n"
     "\t\t\telseif left and top and bottom then\n"
     "\t\t\t\ttileType = 'left'\n"
     "\t\t\telseif right and top and bottom then\n"
     "\t\t\t\ttileType = 'right'\n"
     "\t\t\telseif top and left then\n"
     "\t\t\t\ttileType = 'topLeft'\n"
     "\t\t\telseif top and right then\n"
     "\t\t\t\ttileType = 'topRight'\n"
     "\t\t\telseif bottom and right then\n"
     "\t\t\t\ttileType = 'bottomRight'\n"
     "\t\t\telseif bottom and left then\n"
     "\t\t\t\ttileType = 'bottomLeft'\n"
     "\t\t\telse\n"
     "\t\t\t\ttileType = 'normal'\n"
     "\t\t\tend\n"
     "\t\t\tgeometry:setTileAtGridPosition(x, y, geometryTileset.firstgid + tileIds[tileType])\n"
     "\t\tend\n"
     "\tend\n"
     "\tself.spikes = self.map.layers.spikes\n"
     "end"),
]

P["system/draw-world.lua"] = [
    #[[
    #    shaderAmount tweens to 0 over the level intro, and wavy.glsl with amount 0
    #    displaces nothing -- interlace only flips the sign of a zero offset. So once
    #    the intro ends this is a full-screen pass that cannot change a pixel.
    #    Gating on the amount keeps the intro effect and drops the pass afterwards,
    #    on every level rather than only the world map.
    #]]
    ("\t-- update shader\n"
     "\tself.shaderTime = self.shaderTime + self.shaderSpeed * dt\n"
     "\tself.shader:send('amount', self.shaderAmount)\n"
     "\tself.shader:send('time', self.shaderTime)\n"
     "\n"
     "\t-- update screen shake",
     "\t-- update shader\n"
     "\tif self.shaderAmount > 0 then\n"
     "\t\tself.shaderTime = self.shaderTime + self.shaderSpeed * dt\n"
     "\t\tself.shader:send('amount', self.shaderAmount)\n"
     "\t\tself.shader:send('time', self.shaderTime)\n"
     "\tend\n"
     "\n"
     "\t-- update screen shake"),
    ("\t-- draw world\n"
     "\tlove.graphics.push 'all'\n"
     "\tlove.graphics.setShader(self.shader)\n"
     "\tlove.graphics.draw(self.worldCanvas)\n"
     "\tlove.graphics.pop()",
     "\t-- draw world\n"
     "\tlove.graphics.push 'all'\n"
     "\tif self.shaderAmount > 0 then\n"
     "\t\tlove.graphics.setShader(self.shader)\n"
     "\tend\n"
     "\tlove.graphics.draw(self.worldCanvas)\n"
     "\tlove.graphics.pop()"),
    ("function drawWorld:onPlayerHurt()\n"
     "\tself.screenShakeAmount = self.screenShakeAmount + 4\n"
     "end",
     "function drawWorld:onPlayerHurt()\n"
     "\tself.screenShakeAmount = self.screenShakeAmount + 4\n"
     "end\n"
     "\n"
     "function drawWorld:isNearCamera(x, y, padding)\n"
     "\tpadding = padding or 0\n"
     "\tif math.abs(x - self.cameraX) > constant.screenWidth/2 + padding then return false end\n"
     "\tif math.abs(y - self.cameraY) > constant.screenHeight/2 + padding then return false end\n"
     "\treturn true\n"
     "end"),
    ("function drawWorld:drawEntity(e)\n"
     "\tif e.hidden then return end\n"
     "\tif e.sprite then\n"
     "\t\te.sprite:draw(e.x, e.y)\n"
     "\tend\n"
     "\tif type(e.drawWorld) == 'function' then\n"
     "\t\te:drawWorld()\n"
     "\tend\n"
     "end",
     "function drawWorld:drawEntity(e)\n"
     "\tif e.hidden then return end\n"
     "\tif self.pool.data.worldMap and e.x and e.y and e.w and e.h then\n"
     "\t\tif e.x + e.w < self.cameraX - constant.screenWidth/2 then return end\n"
     "\t\tif e.x > self.cameraX + constant.screenWidth/2 then return end\n"
     "\t\tif e.y + e.h < self.cameraY - constant.screenHeight/2 then return end\n"
     "\t\tif e.y > self.cameraY + constant.screenHeight/2 then return end\n"
     "\tend\n"
     "\tif e.sprite then\n"
     "\t\te.sprite:draw(e.x, e.y)\n"
     "\tend\n"
     "\tif type(e.drawWorld) == 'function' then\n"
     "\t\te:drawWorld()\n"
     "\tend\n"
     "end"),
]

P["util.lua"] = [
    ("'a' then return image.control.faceButtonDown",
     "'a' then return image.control.faceButtonRight"),
    ("'b' then return image.control.faceButtonRight",
     "'b' then return image.control.faceButtonDown"),
    ("'x' then return image.control.faceButtonLeft",
     "'x' then return image.control.faceButtonUp"),
    ("'y' then return image.control.faceButtonUp",
     "'y' then return image.control.faceButtonLeft"),
]

P["shader/glitch.glsl"] = [
    (" 100 +", " 100.0 +"),
    ("Wobble = .001", "Wobble"),
    (" 100)", " 100.0)"),
    (" 17 +", " 17.0 +"),
    (" 19)", " 19.0)"),
    (" 13)", " 13.0)"),
    (" = .005", ""),
]

P["shader/goop.glsl"] = [
    ("75 +", "75.0 +"),
    (" 50 +", " 50.0 +"),
    (" 4)", " 4.0)"),
    (" 1)", " 1.0)"),
]

P["shader/grate.glsl"] = [
    ("uniform int", "float"),
    ("= 2;", "= 2.0;"),
    ("> 1)", "> 1.0)"),
    ("= 0;", "= 0.0;"),
    ("uniform int", "float"),
    ("= 2;", "= 2.0;"),
    ("> 1)", "> 1.0)"),
    ("= 0;", "= 0.0;"),
]

P["shader/polar.glsl"] = [
    ("= 1", ""),
    ("= 1", ""),
    ("= 1", ""),
    (" = 0", ""),
    ("< 0 ? 0 :", "< 0.0 ? 0.0 :"),
    ("< 0 ? 0 :", "< 0.0 ? 0.0 :"),
    ("> 1 ? 1 :", "> 1.0 ? 1.0 :"),
    ("> 1 ? 1 :", "> 1.0 ? 1.0 :"),
]

P["shader/scramble.glsl"] = [
    ("amount = 0.0", "amount"),
]

P["shader/splat.glsl"] = [
    (" = .1", ""),
    (" = 10", ""),
    (" = 0", ""),
    (" = 0", ""),
    (" = 0", ""),
    ("= 1 +", "= 1.0 +"),
    ("= 1 +", "= 1.0 +"),
    (", 1)", ", 1.0)"),
    (", 1)", ", 1.0)"),
]

P["shader/wavy.glsl"] = [
    (" = .1", ""),
    (" = .05", ""),
    (" = 5", ""),
    (", 2)", ", 2.0)"),
    (", 1)", ", 1.0)"),
    (", 1)", ", 1.0)"),
    ("> 1)", "> 1.0)"),
    ("= -1;", "= -1.0;"),
]


def patch(original, output=None):
    if output is None:
        base, ext = os.path.splitext(original)
        output = base + "-portmaster" + ext

    changed = 0
    with zipfile.ZipFile(original, 'r') as zin:
        with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                if item.filename in P:
                    content = zin.read(item.filename).decode('utf-8')
                    content = content.replace('\r\n', '\n')  # normalize CRLF
                    for old, new in P[item.filename]:
                        if old not in content:
                            print(f"  FAIL   {item.filename}: pattern not found")
                            sys.exit(1)
                        content = content.replace(old, new, 1)
                    # normalize line endings for consistent output
                    content = content.replace('\r\n', '\n')
                    print(f"  PATCH  {item.filename}")
                    changed += 1
                    zout.writestr(item, content.encode('utf-8'))
                else:
                    zout.writestr(item, zin.read(item.filename))

    osz = os.path.getsize(original)
    nsz = os.path.getsize(output)
    print(f"\n{changed} files changed ({osz/1024/1024:.1f}MB -> {nsz/1024/1024:.1f}MB, delta {nsz-osz:+d}B)")
    print(f"Output: {output}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 patch.py eatgirl.love [output.love]")
        sys.exit(1)
    patch(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
