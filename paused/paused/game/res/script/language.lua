local lang = {
    languages = {},
    strings = {},
    selected = ''
}

function lang:searchFolder(dir)
    for _, file in pairs(filesystem.getDirectoryItems(dir)) do
        self.languages[string.split(file, '.')[1]] = dir .. file
    end
end

function lang:readFile(file)
    if love.filesystem.getInfo(file) then
        return lume.deserialize(love.filesystem.read(file))
    end
    return {}
end

function lang:setLanguage(language)
    if self:hasLanguage(language) then
        self.strings = self:readFile(self.languages[language])
        return true
    end

    return false
end

function lang:getLanguage()
    return self.selected
end

function lang:hasLanguage(language)
    return self.languages[language]
end

function lang:getLanguages()
    return table.keys(self.languages)
end

function lang:get(id)
    return self.strings[id] or ''
end

return lang