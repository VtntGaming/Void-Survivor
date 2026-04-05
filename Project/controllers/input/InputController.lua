local C = require("utils.Constants")

local InputController = {}
InputController.__index = InputController

local function isAnyDown(keys)
    for _, k in ipairs(keys) do
        if love.keyboard.isDown(k) then return true end
    end
    return false
end

local function matchesBinding(key, bindingName)
    local keys = C.KEY_BINDINGS[bindingName]
    if not keys then return false end
    for _, k in ipairs(keys) do
        if k == key then return true end
    end
    return false
end

function InputController.new()
    local self = setmetatable({}, InputController)
    self.moveX = 0
    self.moveY = 0
    self.aimX = 0
    self.aimY = 0
    self.shooting = false
    self.keysPressed = {}
    self.autoFire = false
    return self
end

function InputController:update(dt)
    -- Movement (uses remappable key bindings)
    self.moveX, self.moveY = 0, 0
    if isAnyDown(C.KEY_BINDINGS.move_up) then self.moveY = -1 end
    if isAnyDown(C.KEY_BINDINGS.move_down) then self.moveY = self.moveY + 1 end
    if isAnyDown(C.KEY_BINDINGS.move_left) then self.moveX = -1 end
    if isAnyDown(C.KEY_BINDINGS.move_right) then self.moveX = self.moveX + 1 end

    -- Aim
    self.aimX, self.aimY = love.mouse.getPosition()

    -- Shooting (mouse click or auto-fire)
    self.shooting = love.mouse.isDown(1) or self.autoFire
end

function InputController:applyToPlayer(player)
    player.moveX = self.moveX
    player.moveY = self.moveY
    player.aimX = self.aimX
    player.aimY = self.aimY
    player.shooting = self.shooting
end

function InputController:keypressed(key)
    self.keysPressed[key] = true
end

function InputController:consumeKey(key)
    if self.keysPressed[key] then
        self.keysPressed[key] = nil
        return true
    end
    return false
end

function InputController:matchesBinding(key, bindingName)
    return matchesBinding(key, bindingName)
end

function InputController:consumeBinding(bindingName)
    local keys = C.KEY_BINDINGS[bindingName]
    if not keys then return false end
    for _, k in ipairs(keys) do
        if self.keysPressed[k] then
            self.keysPressed[k] = nil
            return true
        end
    end
    return false
end

function InputController:clearKeys()
    self.keysPressed = {}
end

return InputController
