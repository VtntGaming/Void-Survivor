local C = require("utils.Constants")

local SaveController = {}
SaveController.__index = SaveController

function SaveController.new()
    local self = setmetatable({}, SaveController)
    self.data = {
        highScore = 0,
        difficulty = "normal",
        sfxVolume = C.SFX_VOLUME,
        screenShake = "full",
        firstRun = true,
        autoFire = false,
        musicVolume = 0.5,
        language = "en"
    }
    self:load()
    return self
end

function SaveController:save()
    local content = ""
    content = content .. "highScore=" .. tostring(self.data.highScore) .. "\n"
    content = content .. "difficulty=" .. tostring(self.data.difficulty) .. "\n"
    content = content .. "sfxVolume=" .. tostring(self.data.sfxVolume) .. "\n"
    content = content .. "screenShake=" .. tostring(self.data.screenShake) .. "\n"
    content = content .. "firstRun=" .. tostring(self.data.firstRun) .. "\n"
    content = content .. "autoFire=" .. tostring(self.data.autoFire) .. "\n"
    content = content .. "musicVolume=" .. tostring(self.data.musicVolume) .. "\n"
    content = content .. "language=" .. tostring(self.data.language) .. "\n"
    love.filesystem.write("save.dat", content)
end

function SaveController:load()
    if not love.filesystem.getInfo("save.dat") then return end
    local content = love.filesystem.read("save.dat")
    if not content then return end
    for line in content:gmatch("[^\r\n]+") do
        local key, value = line:match("^(%w+)=(.+)$")
        if key and value then
            if key == "highScore" then
                self.data.highScore = tonumber(value) or 0
            elseif key == "difficulty" then
                if value == "easy" or value == "normal" or value == "hard" then
                    self.data.difficulty = value
                end
            elseif key == "sfxVolume" then
                self.data.sfxVolume = tonumber(value) or C.SFX_VOLUME
            elseif key == "screenShake" then
                if value == "off" or value == "low" or value == "full" then
                    self.data.screenShake = value
                end
            elseif key == "firstRun" then
                self.data.firstRun = (value == "true")
            elseif key == "autoFire" then
                self.data.autoFire = (value == "true")
            elseif key == "musicVolume" then
                self.data.musicVolume = tonumber(value) or 0.5
            elseif key == "language" then
                if value == "en" or value == "vn" then
                    self.data.language = value
                end
            end
        end
    end
end

function SaveController:getHighScore()
    return self.data.highScore
end

function SaveController:setHighScore(score)
    if score > self.data.highScore then
        self.data.highScore = score
        self:save()
        return true -- new high score
    end
    return false
end

function SaveController:getDifficulty()
    return self.data.difficulty
end

function SaveController:setDifficulty(diff)
    self.data.difficulty = diff
    self:save()
end

function SaveController:getSfxVolume()
    return self.data.sfxVolume
end

function SaveController:setSfxVolume(vol)
    self.data.sfxVolume = vol
    self:save()
end

function SaveController:getScreenShake()
    return self.data.screenShake
end

function SaveController:setScreenShake(val)
    self.data.screenShake = val
    self:save()
end

function SaveController:isFirstRun()
    return self.data.firstRun
end

function SaveController:setFirstRunDone()
    self.data.firstRun = false
    self:save()
end

function SaveController:getAutoFire()
    return self.data.autoFire
end

function SaveController:setAutoFire(val)
    self.data.autoFire = val
    self:save()
end

function SaveController:getMusicVolume()
    return self.data.musicVolume
end

function SaveController:setMusicVolume(vol)
    self.data.musicVolume = math.max(0, math.min(1, vol))
    self:save()
end

function SaveController:getLanguage()
    return self.data.language
end

function SaveController:setLanguage(lang)
    self.data.language = lang
    self:save()
end

return SaveController
