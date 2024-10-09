-- tables.lua
local tables = {}

tables.bitrate = {
    "Normal",                    
    "High"
}

tables.settings = {
    mode = true,      -- true represents "On", false represents "Off"
    autoplay = false, -- true represents "On", false represents "Off"
    bitrate = 1,
    deviceName = "PORTMASTER" 
}

tables.menu = {"Mode", "Autoplay", "Bitrate", "Device Name"}

tables.descriptions = {
    "Turn Librespot Connect on/off.",
    "Automatically play similar songs when your selected music ends. Restart Librespot for changes to take effect.",
    "Select the streaming quality. Restart Librespot for changes to take effect.",
    "Configure the device's name that will show up in Spotify. Restart Librespot for changes to take effect."
}

return tables
