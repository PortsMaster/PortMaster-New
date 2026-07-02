-- PortMaster: Disable image and audio preloading for low-memory handhelds.
--
-- The game preloads all PNG textures and OGG sound effects into memory at
-- startup (via tick handlers "preloadImages" and "preloadSounds"). On a 1GB
-- handheld this is catastrophic. Override both handlers to no-op them.

log.info("[PortMaster] DisablePreload mod loaded")

local imageOverrideHit = false
local audioOverrideHit = false

event.tick.override("preloadImages", { sequence = 1 }, function(originalFunc, ev)
    if not imageOverrideHit then
        log.info("[PortMaster] preloadImages override triggered — skipping image preload")
        imageOverrideHit = true
    end
    return
end)

event.tick.override("preloadSounds", { sequence = 1 }, function(originalFunc, ev)
    if not audioOverrideHit then
        log.info("[PortMaster] preloadSounds override triggered — skipping audio preload")
        audioOverrideHit = true
    end
    return
end)
