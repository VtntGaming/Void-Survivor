-- Void Survivor
-- Controller Architecture

local GameController = require("controllers.GameController")
local Version = require("utils.Version")

local game

function love.load()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)
    math.randomseed(os.time())

    Version.load()
    love.window.setTitle("Void Survivor " .. Version.getDisplay())

    game = GameController.new(Version.get())
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

function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
end
