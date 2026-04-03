local C = require("utils.Constants")

local AudioController = {}
AudioController.__index = AudioController

function AudioController.new(eventBus)
    local self = setmetatable({}, AudioController)
    self.eventBus = eventBus
    self.volume = C.SFX_VOLUME
    self.sounds = {}
    self:generateSounds()
    self:registerEvents()
    return self
end

function AudioController:generateSounds()
    -- Generate 8-bit style sounds using SoundData
    self.sounds.shoot = self:makeTone(0.05, 880, "square", 0.15)
    self.sounds.hit = self:makeNoise(0.06, 440, 0.2)
    self.sounds.explosion = self:makeSweep(0.15, 200, 50, 0.3)
    self.sounds.powerup = self:makeArpeggio({523, 659, 784}, 0.08, 0.25)
    self.sounds.levelup = self:makeArpeggio({523, 587, 659, 784, 1047}, 0.1, 0.2)
    self.sounds.bossSpawn = self:makeSweep(0.4, 80, 300, 0.4)
    self.sounds.comboBreak = self:makeSweep(0.12, 400, 100, 0.25)
end

function AudioController:makeTone(duration, freq, waveType, vol)
    local sampleRate = 44100
    local samples = math.floor(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local env = 1 - (i / samples)
        local val
        if waveType == "square" then
            val = math.sin(2 * math.pi * freq * t) > 0 and 1 or -1
        else
            val = math.sin(2 * math.pi * freq * t)
        end
        data:setSample(i, val * env * (vol or 0.2))
    end
    return love.audio.newSource(data)
end

function AudioController:makeNoise(duration, freq, vol)
    local sampleRate = 44100
    local samples = math.floor(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local env = 1 - (i / samples)
        local val = (math.random() * 2 - 1) * env * (vol or 0.2)
        data:setSample(i, val)
    end
    return love.audio.newSource(data)
end

function AudioController:makeSweep(duration, startFreq, endFreq, vol)
    local sampleRate = 44100
    local samples = math.floor(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local progress = i / samples
        local env = 1 - progress
        local freq = startFreq + (endFreq - startFreq) * progress
        local val = math.sin(2 * math.pi * freq * t)
        data:setSample(i, val * env * (vol or 0.2))
    end
    return love.audio.newSource(data)
end

function AudioController:makeArpeggio(notes, noteDur, vol)
    local sampleRate = 44100
    local totalDur = #notes * noteDur
    local samples = math.floor(totalDur * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local noteIdx = math.floor(t / noteDur) + 1
        if noteIdx > #notes then noteIdx = #notes end
        local freq = notes[noteIdx]
        local localT = t - (noteIdx - 1) * noteDur
        local env = 1 - (localT / noteDur)
        local val = math.sin(2 * math.pi * freq * localT) > 0 and 1 or -1
        data:setSample(i, val * env * (vol or 0.2))
    end
    return love.audio.newSource(data)
end

function AudioController:play(name)
    local snd = self.sounds[name]
    if snd then
        snd:stop()
        snd:setVolume(self.volume)
        snd:play()
    end
end

function AudioController:setVolume(vol)
    self.volume = vol
end

function AudioController:registerEvents()
    self.eventBus:on("player:shoot", function()
        self:play("shoot")
    end)
    self.eventBus:on("enemy:killed", function()
        self:play("explosion")
    end)
    self.eventBus:on("player:damaged", function()
        self:play("hit")
    end)
    self.eventBus:on("player:powerup", function()
        self:play("powerup")
    end)
    self.eventBus:on("wave:start", function()
        self:play("levelup")
    end)
    self.eventBus:on("boss:spawned", function()
        self:play("bossSpawn")
    end)
    self.eventBus:on("combo:break", function()
        self:play("comboBreak")
    end)
end

return AudioController
