local InputController = {}
InputController.__index = InputController

function InputController.new()
    local self = setmetatable({}, InputController)
    self.moveX = 0
    self.moveY = 0
    self.aimX = 0
    self.aimY = 0
    self.shooting = false
    self.keysPressed = {}
    return self
end

function InputController:update(dt)
    -- Movement
    self.moveX, self.moveY = 0, 0
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then self.moveY = -1 end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then self.moveY = self.moveY + 1 end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then self.moveX = -1 end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then self.moveX = self.moveX + 1 end

    -- Aim
    self.aimX, self.aimY = love.mouse.getPosition()

    -- Shooting
    self.shooting = love.mouse.isDown(1)
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

function InputController:clearKeys()
    self.keysPressed = {}
end

return InputController
