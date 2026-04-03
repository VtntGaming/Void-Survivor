local C = require("utils.Constants")

local SaveController = {}
SaveController.__index = SaveController

function SaveController.new()
    local self = setmetatable({}, SaveController)
    self.data = {
        highScore = 0,
        difficulty = "normal",
        sfxVolume = C.SFX_VOLUME
    }
    self:load()
    return self
end

function SaveController:save()
    local content = ""
    content = content .. "highScore=" .. tostring(self.data.highScore) .. "\n"
    content = content .. "difficulty=" .. tostring(self.data.difficulty) .. "\n"
    content = content .. "sfxVolume=" .. tostring(self.data.sfxVolume) .. "\n"
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

return SaveController
