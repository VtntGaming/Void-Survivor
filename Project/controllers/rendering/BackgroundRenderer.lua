local C = require("utils.Constants")

local BackgroundRenderer = {}
BackgroundRenderer.__index = BackgroundRenderer

function BackgroundRenderer.new()
    local self = setmetatable({}, BackgroundRenderer)
    self.gridOffset = 0
    -- Parallax stars
    self.slowStars = {}
    self.fastStars = {}
    for i = 1, C.STAR_COUNT_SLOW do
        table.insert(self.slowStars, {
            x = math.random(0, C.WINDOW_WIDTH),
            y = math.random(0, C.WINDOW_HEIGHT),
            size = 1 + math.random() * 1,
            brightness = 0.2 + math.random() * 0.3
        })
    end
    for i = 1, C.STAR_COUNT_FAST do
        table.insert(self.fastStars, {
            x = math.random(0, C.WINDOW_WIDTH),
            y = math.random(0, C.WINDOW_HEIGHT),
            size = 1 + math.random() * 1.5,
            brightness = 0.3 + math.random() * 0.4
        })
    end
    return self
end

function BackgroundRenderer:update(dt)
    self.gridOffset = self.gridOffset + dt * 10

    -- Move stars
    for _, s in ipairs(self.slowStars) do
        s.y = s.y + 8 * dt
        if s.y > C.WINDOW_HEIGHT then
            s.y = 0
            s.x = math.random(0, C.WINDOW_WIDTH)
        end
    end
    for _, s in ipairs(self.fastStars) do
        s.y = s.y + 20 * dt
        if s.y > C.WINDOW_HEIGHT then
            s.y = 0
            s.x = math.random(0, C.WINDOW_WIDTH)
        end
    end
end

function BackgroundRenderer:draw()
    -- Grid
    love.graphics.setColor(0.1, 0.1, 0.2, 0.3)
    local spacing = C.GRID_SPACING
    local offset = self.gridOffset % spacing
    for x = -spacing + offset, C.WINDOW_WIDTH + spacing, spacing do
        love.graphics.line(x, 0, x, C.WINDOW_HEIGHT)
    end
    for y = -spacing + offset, C.WINDOW_HEIGHT + spacing, spacing do
        love.graphics.line(0, y, C.WINDOW_WIDTH, y)
    end

    -- Slow stars (back layer)
    for _, s in ipairs(self.slowStars) do
        love.graphics.setColor(0.5, 0.5, 0.8, s.brightness)
        love.graphics.circle("fill", s.x, s.y, s.size)
    end

    -- Fast stars (front layer)
    for _, s in ipairs(self.fastStars) do
        love.graphics.setColor(0.8, 0.8, 1, s.brightness)
        love.graphics.circle("fill", s.x, s.y, s.size)
    end

    love.graphics.setColor(1, 1, 1)
end

return BackgroundRenderer
