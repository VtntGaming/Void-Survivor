-- Void Survivor v2.0
-- Controller Architecture

local GameController = require("controllers.GameController")

local game

function love.load()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)
    math.randomseed(os.time())
    game = GameController.new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    game:keypressed(key)
end
