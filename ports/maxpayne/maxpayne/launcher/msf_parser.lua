-- MSF Audio Archive Parser for Max Payne custom sound format
-- File format (big-endian):
-- 0x00: Signature (4 bytes: 0x00, 0x00, 0x03, 0xE7)
-- 0x04: Version (uint32: expected value 2)
-- 0x08: Total files (uint32)
-- 0x0C: File offset (uint32)
-- 0x10: File size (uint32)
-- 0x14: File name length (uint8)
-- 0x15: File path name (ASCII)
local MSFParser = {}

local currentAudioSource = nil
local currentArchive = nil
local currentFileIndex = 1

-- Load archive once and cache it
function MSFParser.loadArchive()
    if not currentArchive then
        local archive, error = MSFParser.parseArchive("gamedata/MaxPayneSoundsv2.msf")
        if archive then
            currentArchive = archive
            currentFileIndex = 1
        end
        return archive, error
    end
    return currentArchive, nil
end

function MSFParser.readUInt32(file)
    local bytes = file:read(4)
    if not bytes or #bytes < 4 then
        return nil
    end
    local a, b, c, d = string.byte(bytes, 1, 4)
    return (a * 16777216) + (b * 65536) + (c * 256) + d
end

function MSFParser.readUInt8(file)
    local byte = file:read(1)
    if not byte then
        return nil
    end
    return string.byte(byte)
end

function MSFParser.parseArchive(filepath)
    local file = io.open(filepath, "rb")
    if not file then
        return nil, "Could not open MSF file: " .. filepath
    end

    local sig1 = MSFParser.readUInt8(file)
    local sig2 = MSFParser.readUInt8(file)
    local sig3 = MSFParser.readUInt8(file)
    local sig4 = MSFParser.readUInt8(file)

    if not sig1 or not sig2 or not sig3 or not sig4 then
        file:close()
        return nil, "Could not read MSF signature"
    end

    if sig1 ~= 0x00 or sig2 ~= 0x00 or sig3 ~= 0x03 or sig4 ~= 0xE7 then
        file:close()
        return nil, "Invalid MSF signature. Expected: 00 00 03 E7, got: " ..
            string.format("%02X %02X %02X %02X", sig1, sig2, sig3, sig4)
    end

    local version = MSFParser.readUInt32(file)
    local totalFiles = MSFParser.readUInt32(file)

    if not version or not totalFiles then
        file:close()
        return nil, "Could not read MSF header"
    end

    if version ~= 2 then
        file:close()
        return nil, "Unsupported MSF version: " .. tostring(version) .. " (expected 2)"
    end

    local files = {}

    -- Parse file entries
    for i = 1, totalFiles do
        local fileOffset = MSFParser.readUInt32(file)
        local fileSize = MSFParser.readUInt32(file)
        local nameLength = MSFParser.readUInt8(file)

        if not fileOffset or not fileSize or not nameLength then
            file:close()
            return nil, "Could not read file entry " .. i
        end

        local fileName = file:read(nameLength)
        if not fileName or #fileName < nameLength then
            file:close()
            return nil, "Could not read filename for entry " .. i
        end

        files[i] = {
            offset = fileOffset,
            size = fileSize,
            name = fileName:gsub("%z", ""), -- Remove null terminators
            index = i
        }
    end

    file:close()

    return {
        signature = {sig1, sig2, sig3, sig4},
        version = version,
        totalFiles = totalFiles,
        files = files,
        filepath = filepath
    }
end

function MSFParser.extractFile(archive, fileIndex, outputPath)
    if not archive or not archive.files[fileIndex] then
        return false, "Invalid file index"
    end

    local file = io.open(archive.filepath, "rb")
    if not file then
        return false, "Could not open MSF archive"
    end

    local fileInfo = archive.files[fileIndex]
    file:seek("set", fileInfo.offset)
    local data = file:read(fileInfo.size)
    file:close()

    if not data or #data < fileInfo.size then
        return false, "Could not read file data"
    end

    local outFile = io.open(outputPath, "wb")
    if not outFile then
        return false, "Could not create output file"
    end

    outFile:write(data)
    outFile:close()

    return true
end

function MSFParser.playFile(archive, fileIndex, ui)
    if not archive or not archive.files[fileIndex] then
        if ui then
            ui.message, ui.message_t = "Invalid file index", 2.0
        end
        return false
    end

    local fileInfo = archive.files[fileIndex]
    local tempPath = "temp_audio_" .. fileIndex .. ".mp3"

    -- Extract file data to memory first
    local file = io.open(archive.filepath, "rb")
    if not file then
        if ui then
            ui.message, ui.message_t = "Could not open MSF archive", 2.0
        end
        return false
    end

    file:seek("set", fileInfo.offset)
    local data = file:read(fileInfo.size)
    file:close()

    if not data or #data < fileInfo.size then
        if ui then
            ui.message, ui.message_t = "Could not read file data", 2.0
        end
        return false
    end

    -- Write to Love2D's writable directory
    local success = love.filesystem.write(tempPath, data)
    if not success then
        if ui then
            ui.message, ui.message_t = "Could not write temp file", 2.0
        end
        return false
    end

    -- Check if file was written correctly
    local info = love.filesystem.getInfo(tempPath)
    if not info then
        if ui then
            ui.message, ui.message_t = "Temp file not created", 2.0
        end
        return false
    end

    if info.size == 0 then
        if ui then
            ui.message, ui.message_t = "Extracted file is empty", 2.0
        end
        love.filesystem.remove(tempPath)
        return false
    end

    if ui then
        ui.message, ui.message_t = "Extracted " .. info.size .. " bytes", 1.5
    end

    -- Try to load and play the audio with better error handling
    local success, result = pcall(love.audio.newSource, tempPath, "static")
    if success and result then
        if currentAudioSource then
            currentAudioSource:stop()
        end
        currentAudioSource = result

        local playSuccess, playError = pcall(function()
            result:play()
        end)
        if playSuccess then
            if ui then
                ui.message, ui.message_t = "Playing: " .. fileInfo.name, 2.0
            end
            -- Clean up temp file after a delay
            love.timer.sleep(0.5)
            love.filesystem.remove(tempPath)
            return true
        else
            if ui then
                ui.message, ui.message_t = "Play failed: " .. tostring(playError), 3.0
            end
            love.filesystem.remove(tempPath)
            return false
        end
    else
        if ui then
            ui.message, ui.message_t = "Load failed: " .. tostring(result), 3.0
        end
        love.filesystem.remove(tempPath)
        return false
    end
end

function MSFParser.stopAudio(ui)
    if currentAudioSource then
        currentAudioSource:stop()
        currentAudioSource = nil
        if ui then
            ui.message, ui.message_t = "Audio stopped", 1.0
        end
    end
end

function MSFParser.testPlayback(ui)
    local archive, error = MSFParser.parseArchive("gamedata/MaxPayneSoundsv2.msf")
    if not archive then
        if ui then
            ui.message, ui.message_t = "Parse error: " .. (error or "unknown"), 3.0
        end
        return
    end

    if ui then
        ui.message, ui.message_t = "Found " .. archive.totalFiles .. " files", 2.0
    end

    -- Debug: show first few files
    if archive.totalFiles > 0 then
        print("MSF Archive contents:")
        for i = 1, math.min(5, archive.totalFiles) do
            local file = archive.files[i]
            print(string.format("  %d: %s (%d bytes at offset %d)", i, file.name, file.size, file.offset))
        end

        -- Try to play the first file
        MSFParser.playFile(archive, 1, ui)
    end
end

-- Add a debug function to just extract a file without playing
function MSFParser.debugExtract(ui)
    local archive, error = MSFParser.parseArchive("gamedata/MaxPayneSoundsv2.msf")
    if not archive then
        if ui then
            ui.message, ui.message_t = "Parse error: " .. (error or "unknown"), 3.0
        end
        return
    end

    if archive.totalFiles > 0 then
        local fileInfo = archive.files[1]
        local outputPath = "debug_audio.mp3"

        -- Extract file data
        local file = io.open(archive.filepath, "rb")
        if not file then
            if ui then
                ui.message, ui.message_t = "Could not open MSF archive", 2.0
            end
            return
        end

        file:seek("set", fileInfo.offset)
        local data = file:read(fileInfo.size)
        file:close()

        if not data or #data < fileInfo.size then
            if ui then
                ui.message, ui.message_t = "Could not read file data", 2.0
            end
            return
        end

        -- Write using Love2D filesystem
        local success = love.filesystem.write(outputPath, data)
        if success then
            if ui then
                ui.message, ui.message_t = "Extracted to " .. outputPath, 2.0
            end
            print("Extracted file: " .. outputPath)
            print("Original name: " .. fileInfo.name)
            print("Size: " .. fileInfo.size .. " bytes")
        else
            if ui then
                ui.message, ui.message_t = "Failed to write debug file", 2.0
            end
        end
    end
end

-- File browsing functions
function MSFParser.listFiles(ui)
    local archive, error = MSFParser.loadArchive()
    if not archive then
        if ui then
            ui.message, ui.message_t = "Parse error: " .. (error or "unknown"), 3.0
        end
        return
    end

    print("MSF Archive: " .. archive.totalFiles .. " files")
    print("Current file: " .. currentFileIndex)

    -- Show current file and a few around it
    local startIdx = math.max(1, currentFileIndex - 2)
    local endIdx = math.min(archive.totalFiles, currentFileIndex + 2)

    for i = startIdx, endIdx do
        local file = archive.files[i]
        local marker = (i == currentFileIndex) and " > " or "   "
        print(string.format("%s%d: %s (%d bytes)", marker, i, file.name, file.size))
    end

    if ui then
        local currentFile = archive.files[currentFileIndex]
        ui.message, ui.message_t = string.format("%d/%d: %s", currentFileIndex, archive.totalFiles, currentFile.name),
            3.0
    end
end

function MSFParser.nextFile(ui)
    local archive, error = MSFParser.loadArchive()
    if not archive then
        return
    end

    currentFileIndex = currentFileIndex + 1
    if currentFileIndex > archive.totalFiles then
        currentFileIndex = 1
    end

    MSFParser.listFiles(ui)
end

function MSFParser.prevFile(ui)
    local archive, error = MSFParser.loadArchive()
    if not archive then
        return
    end

    currentFileIndex = currentFileIndex - 1
    if currentFileIndex < 1 then
        currentFileIndex = archive.totalFiles
    end

    MSFParser.listFiles(ui)
end

function MSFParser.playCurrentFile(ui)
    local archive, error = MSFParser.loadArchive()
    if not archive then
        if ui then
            ui.message, ui.message_t = "Parse error: " .. (error or "unknown"), 3.0
        end
        return
    end

    MSFParser.playFile(archive, currentFileIndex, ui)
end

function MSFParser.searchFiles(searchTerm, ui)
    local archive, error = MSFParser.loadArchive()
    if not archive then
        if ui then
            ui.message, ui.message_t = "Parse error: " .. (error or "unknown"), 3.0
        end
        return
    end

    print("Searching for: " .. searchTerm)
    local found = {}

    for i, file in ipairs(archive.files) do
        if string.find(string.lower(file.name), string.lower(searchTerm)) then
            table.insert(found, {
                index = i,
                file = file
            })
            print(string.format("  %d: %s", i, file.name))
        end
    end

    if #found > 0 then
        currentFileIndex = found[1].index
        if ui then
            ui.message, ui.message_t = string.format("Found %d matches, selected: %s", #found, found[1].file.name), 3.0
        end
    else
        if ui then
            ui.message, ui.message_t = "No matches found for: " .. searchTerm, 2.0
        end
    end
end

function MSFParser.writePlaylist(ui)
    local archive, error = MSFParser.loadArchive()
    if not archive then
        if ui then
            ui.message, ui.message_t = "Parse error: " .. (error or "unknown"), 3.0
        end
        return
    end

    local playlistContent = {}
    table.insert(playlistContent, "# Max Payne Audio Playlist")
    table.insert(playlistContent, "# Index: Filename (Size)")
    table.insert(playlistContent, "")

    for i, file in ipairs(archive.files) do
        table.insert(playlistContent, string.format("%d: %s (%d bytes)", i, file.name, file.size))
    end

    local content = table.concat(playlistContent, "\n")

    -- Write to current working directory using standard file I/O
    local file = io.open("playlist.txt", "w")
    if file then
        file:write(content)
        file:close()

        if ui then
            ui.message, ui.message_t = "Playlist written to playlist.txt (" .. archive.totalFiles .. " files)", 2.0
        end
        print("Playlist written to playlist.txt in current directory")
        print("Total files: " .. archive.totalFiles)
    else
        if ui then
            ui.message, ui.message_t = "Failed to write playlist.txt", 2.0
        end
    end
end

-- Convenience wrapper functions that use the global archive
function MSFParser.playFileSimple(fileIndex)
    local archive, error = MSFParser.loadArchive()
    if not archive then
        return false
    end
    return MSFParser.playFile(archive, fileIndex)
end

function MSFParser.extractFileSimple(fileIndex, archive)
    -- Use provided archive or load global one
    if not archive then
        local error
        archive, error = MSFParser.loadArchive()
        if not archive then
            return nil
        end
    end

    local fileInfo = archive.files[fileIndex]
    if not fileInfo then
        return nil
    end

    local tempPath = "temp_audio_" .. fileIndex .. ".mp3"

    -- Extract to Love2D's writable directory
    local file = io.open(archive.filepath, "rb")
    if not file then
        return nil
    end

    file:seek("set", fileInfo.offset)
    local data = file:read(fileInfo.size)
    file:close()

    if not data or #data < fileInfo.size then
        return nil
    end

    local success = love.filesystem.write(tempPath, data)
    if success then
        return tempPath -- Return the path relative to Love2D's writable directory
    end
    return nil
end

-- More efficient method for loading audio directly from data
function MSFParser.loadAudioSource(fileIndex, sourceType, archive)
    -- Use provided archive or load global one
    if not archive then
        local error
        archive, error = MSFParser.loadArchive()
        if not archive then
            return nil
        end
    end

    local fileInfo = archive.files[fileIndex]
    if not fileInfo then
        return nil
    end

    -- Extract file data
    local file = io.open(archive.filepath, "rb")
    if not file then
        return nil
    end

    file:seek("set", fileInfo.offset)
    local data = file:read(fileInfo.size)
    file:close()

    if not data or #data < fileInfo.size then
        return nil
    end

    -- Create temporary file
    local tempPath = "temp_audio_" .. fileIndex .. ".mp3"
    local success = love.filesystem.write(tempPath, data)
    if not success then
        return nil
    end

    -- Load audio source
    local audioSuccess, audioSource = pcall(love.audio.newSource, tempPath, sourceType or "static")
    if audioSuccess and audioSource then
        return audioSource, tempPath
    end

    return nil, tempPath
end

return MSFParser
