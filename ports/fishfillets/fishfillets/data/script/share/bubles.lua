
function stdBublesLoad()
    sound_addSound("bubles", "sound/share/sp-bubles_00.ogg")
    sound_addSound("bubles", "sound/share/sp-bubles_01.ogg")
    sound_addSound("bubles", "sound/share/sp-bubles_02.ogg")
    sound_addSound("bubles", "sound/share/sp-bubles_03.ogg")
    sound_addSound("bubles", "sound/share/sp-bubles_04.ogg")
    sound_addSound("bubles", "sound/share/sp-bubles_05.ogg")
end

function stdBubles()
    --NOTE: original was (random(100) < 5)
    if random(100) < 2 then
        sound_playSound("bubles", 15)
    end
end

