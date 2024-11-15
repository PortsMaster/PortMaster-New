
function planDelay(delay)
    game_planAction(function(count)
        return count >= delay
    end)
end

function planTalk(dialogName)
    game_planAction(function(count)
        model_talk(1, dialogName)
        return true
    end)
end

dialog_addDialog("dlg-x-SPACE", "en", "", "font_poster", " ")
function planSpace()
    planTalk("dlg-x-SPACE")
end

--NOTE: hack, dialog with space as filler
function planStop()
    game_planAction(function(count)
        model_talk(1, "dlg-x-SPACE")
        return false
    end)
end

dialog_addFont("font_poster", 255, 255, 255)
dialog_addFont("font_orange", 255, 204, 00)

